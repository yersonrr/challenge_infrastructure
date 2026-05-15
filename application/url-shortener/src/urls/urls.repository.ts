import {
  DeleteCommand,
  DynamoDBDocumentClient,
  GetCommand,
  PutCommand,
  QueryCommand,
} from '@aws-sdk/lib-dynamodb';
import { Inject, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { AppConfig } from '../config/configuration';
import { DYNAMODB_DOCUMENT_CLIENT } from '../dynamodb/dynamodb.constants';
import { isConditionalCheckFailed } from '../dynamodb/dynamodb-errors';
import type { UrlRecord } from './entities/url.entity';
import { ShortCodeConflictError } from './short-code-conflict.error';

const OWNER_INDEX_NAME = 'ownerId-createdAt-index';

@Injectable()
export class UrlsRepository {
  private readonly tableName: string;

  constructor(
    @Inject(DYNAMODB_DOCUMENT_CLIENT)
    private readonly documentClient: DynamoDBDocumentClient,
    configService: ConfigService<AppConfig, true>,
  ) {
    this.tableName = configService.get('urlsTableName', { infer: true });
  }

  async findByShortCode(shortCode: string): Promise<UrlRecord | null> {
    const result = await this.documentClient.send(
      new GetCommand({
        TableName: this.tableName,
        Key: { shortCode },
      }),
    );

    return result.Item ? (result.Item as UrlRecord) : null;
  }

  async findByOwnerId(ownerId: string): Promise<UrlRecord[]> {
    const result = await this.documentClient.send(
      new QueryCommand({
        TableName: this.tableName,
        IndexName: OWNER_INDEX_NAME,
        KeyConditionExpression: 'ownerId = :ownerId',
        ExpressionAttributeValues: {
          ':ownerId': ownerId,
        },
        ScanIndexForward: false,
      }),
    );

    return (result.Items ?? []) as UrlRecord[];
  }

  async create(record: UrlRecord): Promise<void> {
    try {
      await this.documentClient.send(
        new PutCommand({
          TableName: this.tableName,
          Item: record,
          ConditionExpression: 'attribute_not_exists(shortCode)',
        }),
      );
    } catch (error: unknown) {
      if (isConditionalCheckFailed(error)) {
        throw new ShortCodeConflictError();
      }

      throw error;
    }
  }

  async deleteByShortCode(shortCode: string): Promise<void> {
    await this.documentClient.send(
      new DeleteCommand({
        TableName: this.tableName,
        Key: { shortCode },
      }),
    );
  }
}
