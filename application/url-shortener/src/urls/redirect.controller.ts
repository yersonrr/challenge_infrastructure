import { Controller, Get, Param, Res } from '@nestjs/common';
import type { Response } from 'express';
import { ShortCodeValidationPipe } from '../common/pipes/short-code.pipe';
import { UrlsService } from './urls.service';

@Controller()
export class RedirectController {
  constructor(private readonly urlsService: UrlsService) {}

  @Get(':shortCode')
  async redirect(
    @Param('shortCode', ShortCodeValidationPipe) shortCode: string,
    @Res() response: Response,
  ): Promise<void> {
    const longUrl = await this.urlsService.resolveForRedirect(shortCode);
    response.redirect(302, longUrl);
  }
}
