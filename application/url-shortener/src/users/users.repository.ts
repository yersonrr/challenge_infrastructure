import {
  DynamoDBDocumentClient,
  GetCommand,
  PutCommand,
  QueryCommand,
} from '@aws-sdk/lib-dynamodb';
import { ConflictException, Inject, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { AppConfig } from '../config/configuration';
import { DYNAMODB_DOCUMENT_CLIENT } from '../dynamodb/dynamodb.constants';
import type { UserRecord } from './entities/user.entity';

const EMAIL_INDEX_NAME = 'email-index';

@Injectable()
export class UsersRepository {
  private readonly tableName: string;

  constructor(
    @Inject(DYNAMODB_DOCUMENT_CLIENT)
    private readonly documentClient: DynamoDBDocumentClient,
    configService: ConfigService<AppConfig, true>,
  ) {
    this.tableName = configService.get('usersTableName', { infer: true });
  }

  async findByEmail(email: string): Promise<UserRecord | null> {
    const normalizedEmail = email.trim().toLowerCase();

    const result = await this.documentClient.send(
      new QueryCommand({
        TableName: this.tableName,
        IndexName: EMAIL_INDEX_NAME,
        KeyConditionExpression: 'email = :email',
        ExpressionAttributeValues: {
          ':email': normalizedEmail,
        },
        Limit: 1,
      }),
    );

    const item = result.Items?.[0];
    return item ? (item as UserRecord) : null;
  }

  async findById(userId: string): Promise<UserRecord | null> {
    const result = await this.documentClient.send(
      new GetCommand({
        TableName: this.tableName,
        Key: { userId },
      }),
    );

    return result.Item ? (result.Item as UserRecord) : null;
  }

  async create(user: UserRecord): Promise<void> {
    try {
      await this.documentClient.send(
        new PutCommand({
          TableName: this.tableName,
          Item: user,
          ConditionExpression: 'attribute_not_exists(userId)',
        }),
      );
    } catch (error: unknown) {
      if (
        error &&
        typeof error === 'object' &&
        'name' in error &&
        error.name === 'ConditionalCheckFailedException'
      ) {
        throw new ConflictException('User already exists');
      }
      throw error;
    }
  }
}
