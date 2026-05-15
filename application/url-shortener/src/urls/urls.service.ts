import { randomBytes } from 'crypto';
import {
  ForbiddenException,
  GoneException,
  Injectable,
  NotFoundException,
  OnModuleInit,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { AppConfig } from '../config/configuration';
import { SHORT_CODE_LENGTH } from '../common/constants/short-code';
import { normalizeSafeHttpUrl } from '../common/validation/safe-http-url';
import { CreateUrlDto } from './dto/create-url.dto';
import type { PublicUrl, UrlRecord } from './entities/url.entity';
import { ShortCodeConflictError } from './short-code-conflict.error';
import { UrlsRepository } from './urls.repository';
const SHORT_CODE_ALPHABET =
  'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
const MAX_SHORT_CODE_ATTEMPTS = 8;
const RESERVED_SHORT_CODES = new Set(['auth', 'health', 'urls']);

@Injectable()
export class UrlsService implements OnModuleInit {
  constructor(
    private readonly urlsRepository: UrlsRepository,
    private readonly configService: ConfigService<AppConfig, true>,
  ) {}

  onModuleInit(): void {
    const urlsTableName = this.configService.get('urlsTableName', {
      infer: true,
    });
    if (!urlsTableName) {
      throw new Error('URLS_TABLE_NAME environment variable is required');
    }
  }

  async create(ownerId: string, dto: CreateUrlDto): Promise<PublicUrl> {
    const longUrl = normalizeSafeHttpUrl(dto.longUrl);
    const now = new Date();
    const createdAt = now.toISOString();
    const expiresAt = dto.expiresInDays
      ? Math.floor(now.getTime() / 1000) + dto.expiresInDays * 86_400
      : undefined;

    for (let attempt = 0; attempt < MAX_SHORT_CODE_ATTEMPTS; attempt += 1) {
      const shortCode = this.randomShortCode();
      if (RESERVED_SHORT_CODES.has(shortCode)) {
        continue;
      }

      const record: UrlRecord = {
        shortCode,
        longUrl,
        ownerId,
        createdAt,
        ...(expiresAt !== undefined ? { expiresAt } : {}),
      };

      try {
        await this.urlsRepository.create(record);
        return this.toPublicUrl(record);
      } catch (error: unknown) {
        if (error instanceof ShortCodeConflictError) {
          continue;
        }

        throw error;
      }
    }

    throw new Error('Unable to generate a unique short code');
  }

  async listByOwner(ownerId: string): Promise<PublicUrl[]> {
    const records = await this.urlsRepository.findByOwnerId(ownerId);
    return records
      .filter((record) => !this.isExpired(record))
      .map((record) => this.toPublicUrl(record));
  }

  async deleteByOwner(ownerId: string, shortCode: string): Promise<void> {
    const record = await this.urlsRepository.findByShortCode(shortCode);

    if (!record) {
      throw new NotFoundException('Short link not found');
    }

    if (record.ownerId !== ownerId) {
      throw new ForbiddenException('You can only delete your own short links');
    }

    await this.urlsRepository.deleteByShortCode(shortCode);
  }

  async resolveForRedirect(shortCode: string): Promise<string> {
    if (RESERVED_SHORT_CODES.has(shortCode)) {
      throw new NotFoundException('Short link not found');
    }

    const record = await this.urlsRepository.findByShortCode(shortCode);

    if (!record) {
      throw new NotFoundException('Short link not found');
    }

    if (this.isExpired(record)) {
      throw new GoneException('Short link has expired');
    }

    try {
      return normalizeSafeHttpUrl(record.longUrl);
    } catch {
      throw new NotFoundException('Short link not found');
    }
  }

  private randomShortCode(): string {
    const bytes = randomBytes(SHORT_CODE_LENGTH);
    return Array.from(
      bytes,
      (byte) => SHORT_CODE_ALPHABET[byte % SHORT_CODE_ALPHABET.length],
    ).join('');
  }

  private isExpired(record: UrlRecord): boolean {
    if (record.expiresAt === undefined) {
      return false;
    }
    return record.expiresAt <= Math.floor(Date.now() / 1000);
  }

  private toPublicUrl(record: UrlRecord): PublicUrl {
    return {
      shortCode: record.shortCode,
      longUrl: record.longUrl,
      ownerId: record.ownerId,
      createdAt: record.createdAt,
      ...(record.expiresAt !== undefined
        ? { expiresAt: record.expiresAt }
        : {}),
    };
  }
}
