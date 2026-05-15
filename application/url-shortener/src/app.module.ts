import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppConfigModule } from './config/config.module';
import { DynamoDbModule } from './dynamodb/dynamodb.module';
import { UsersModule } from './users/users.module';

@Module({
  imports: [AppConfigModule, DynamoDbModule, UsersModule],
  controllers: [AppController],
  providers: [],
})
export class AppModule {}
