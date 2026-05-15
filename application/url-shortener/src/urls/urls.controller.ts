import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { CurrentUser } from '../auth/current-user.decorator';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import type { JwtPayload } from '../auth/jwt-payload.interface';
import { ShortCodeValidationPipe } from '../common/pipes/short-code.pipe';
import { CreateUrlDto } from './dto/create-url.dto';
import type { PublicUrl } from './entities/url.entity';
import { UrlsService } from './urls.service';

@Controller('urls')
@UseGuards(JwtAuthGuard)
export class UrlsController {
  constructor(private readonly urlsService: UrlsService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateUrlDto,
  ): Promise<PublicUrl> {
    return this.urlsService.create(user.sub, dto);
  }

  @Get()
  list(@CurrentUser() user: JwtPayload): Promise<PublicUrl[]> {
    return this.urlsService.listByOwner(user.sub);
  }

  @Delete(':shortCode')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(
    @CurrentUser() user: JwtPayload,
    @Param('shortCode', ShortCodeValidationPipe) shortCode: string,
  ): Promise<void> {
    await this.urlsService.deleteByOwner(user.sub, shortCode);
  }
}
