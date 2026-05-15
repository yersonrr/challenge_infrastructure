import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';
import { Global, Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { AppConfig } from '../config/configuration';
import { DYNAMODB_DOCUMENT_CLIENT } from './dynamodb.constants';

@Global()
@Module({
  providers: [
    {
      provide: DYNAMODB_DOCUMENT_CLIENT,
      inject: [ConfigService],
      useFactory: (configService: ConfigService<AppConfig, true>) => {
        const awsRegion = configService.get('awsRegion', { infer: true });
        const endpoint = configService.get('dbEndpoint', { infer: true });

        const client = new DynamoDBClient({
          region: awsRegion,
          ...(endpoint ? { endpoint } : {}),
        });

        return DynamoDBDocumentClient.from(client, {
          marshallOptions: { removeUndefinedValues: true },
        });
      },
    },
  ],
  exports: [DYNAMODB_DOCUMENT_CLIENT],
})
export class DynamoDbModule {}
