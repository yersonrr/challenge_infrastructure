import { Module } from '@nestjs/common';
import { RedirectController } from './redirect.controller';
import { UrlsController } from './urls.controller';
import { UrlsRepository } from './urls.repository';
import { UrlsService } from './urls.service';

@Module({
  controllers: [UrlsController, RedirectController],
  providers: [UrlsRepository, UrlsService],
  exports: [UrlsService],
})
export class UrlsModule {}
