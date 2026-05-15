import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AuthModule } from './auth/auth.module';
import { AppConfigModule } from './config/config.module';
import { DynamoDbModule } from './dynamodb/dynamodb.module';
import { UrlsModule } from './urls/urls.module';
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    AppConfigModule,
    DynamoDbModule,
    UsersModule,
    AuthModule,
    UrlsModule,
  ],
  controllers: [AppController],
})
export class AppModule {}
