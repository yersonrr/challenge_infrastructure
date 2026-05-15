import {
  ForbiddenException,
  GoneException,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { AppConfig } from '../../config/configuration';
import { ShortCodeConflictError } from '../short-code-conflict.error';
import { UrlsRepository } from '../urls.repository';
import { UrlsService } from '../urls.service';

const baseAppConfig: AppConfig = {
  nodeEnv: 'test',
  jwtSecret: 'secret',
  usersTableName: 'users',
  urlsTableName: 'urls',
  awsRegion: 'eu-west-1',
};

function createConfigServiceMock(
  overrides: Partial<AppConfig> = {},
): ConfigService<AppConfig, true> {
  const config: AppConfig = { ...baseAppConfig, ...overrides };
  return {
    get: jest.fn(
      <K extends keyof AppConfig>(key: K, _options?: { infer: true }): AppConfig[K] =>
        config[key],
    ),
  } as unknown as ConfigService<AppConfig, true>;
}

describe('UrlsService', () => {
  const urlsRepository = {
    findByShortCode: jest.fn(),
    findByOwnerId: jest.fn(),
    create: jest.fn(),
    deleteByShortCode: jest.fn(),
  };

  let service: UrlsService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new UrlsService(
      urlsRepository as unknown as UrlsRepository,
      createConfigServiceMock(),
    );
    service.onModuleInit();
  });

  describe('create', () => {
    it('creates a short link for the owner', async () => {
      urlsRepository.create.mockResolvedValue(undefined);

      const result = await service.create('user-1', {
        longUrl: 'https://example.com/long-path',
      });

      expect(result.shortCode).toHaveLength(7);
      expect(result.longUrl).toBe('https://example.com/long-path');
      expect(result.ownerId).toBe('user-1');
      expect(urlsRepository.create).toHaveBeenCalledWith(
        expect.objectContaining({
          ownerId: 'user-1',
          longUrl: 'https://example.com/long-path',
        }),
      );
    });

    it('retries when DynamoDB reports a short code collision', async () => {
      urlsRepository.create
        .mockRejectedValueOnce(new ShortCodeConflictError())
        .mockResolvedValueOnce(undefined);

      const result = await service.create('user-1', {
        longUrl: 'https://example.com',
      });

      expect(result.shortCode).toHaveLength(7);
      expect(urlsRepository.create).toHaveBeenCalledTimes(2);
    });

    it('sets expiresAt when expiresInDays is provided', async () => {
      urlsRepository.create.mockResolvedValue(undefined);
      const nowSeconds = Math.floor(Date.now() / 1000);

      const result = await service.create('user-1', {
        longUrl: 'https://example.com',
        expiresInDays: 7,
      });

      expect(result.expiresAt).toBeGreaterThanOrEqual(nowSeconds + 7 * 86_400 - 5);
    });
  });

  describe('deleteByOwner', () => {
    it('deletes when the caller owns the link', async () => {
      urlsRepository.findByShortCode.mockResolvedValue({
        shortCode: 'abc1234',
        longUrl: 'https://example.com',
        ownerId: 'user-1',
        createdAt: new Date().toISOString(),
      });
      urlsRepository.deleteByShortCode.mockResolvedValue(undefined);

      await expect(service.deleteByOwner('user-1', 'abc1234')).resolves.toBeUndefined();
      expect(urlsRepository.deleteByShortCode).toHaveBeenCalledWith('abc1234');
    });

    it('forbids delete when the caller is not the owner', async () => {
      urlsRepository.findByShortCode.mockResolvedValue({
        shortCode: 'abc1234',
        longUrl: 'https://example.com',
        ownerId: 'other-user',
        createdAt: new Date().toISOString(),
      });

      await expect(service.deleteByOwner('user-1', 'abc1234')).rejects.toBeInstanceOf(
        ForbiddenException,
      );
      expect(urlsRepository.deleteByShortCode).not.toHaveBeenCalled();
    });

    it('returns not found when short code does not exist', async () => {
      urlsRepository.findByShortCode.mockResolvedValue(null);

      await expect(service.deleteByOwner('user-1', 'missing')).rejects.toBeInstanceOf(
        NotFoundException,
      );
    });
  });

  describe('resolveForRedirect', () => {
    it('returns the long URL for a valid public short code', async () => {
      urlsRepository.findByShortCode.mockResolvedValue({
        shortCode: 'abc1234',
        longUrl: 'https://destination.example',
        ownerId: 'user-1',
        createdAt: new Date().toISOString(),
      });

      await expect(service.resolveForRedirect('abc1234')).resolves.toBe(
        'https://destination.example/',
      );
    });

    it('rejects reserved paths', async () => {
      await expect(service.resolveForRedirect('health')).rejects.toBeInstanceOf(
        NotFoundException,
      );
      expect(urlsRepository.findByShortCode).not.toHaveBeenCalled();
    });

    it('hides unsafe stored URLs as not found', async () => {
      urlsRepository.findByShortCode.mockResolvedValue({
        shortCode: 'unsafe1',
        longUrl: 'javascript:alert(1)',
        ownerId: 'user-1',
        createdAt: new Date().toISOString(),
      });

      await expect(service.resolveForRedirect('unsafe1')).rejects.toBeInstanceOf(
        NotFoundException,
      );
    });

    it('returns gone when the link is expired', async () => {
      urlsRepository.findByShortCode.mockResolvedValue({
        shortCode: 'expired',
        longUrl: 'https://example.com',
        ownerId: 'user-1',
        createdAt: new Date().toISOString(),
        expiresAt: Math.floor(Date.now() / 1000) - 60,
      });

      await expect(service.resolveForRedirect('expired')).rejects.toBeInstanceOf(
        GoneException,
      );
    });
  });

  describe('listByOwner', () => {
    it('excludes expired links from the owner list', async () => {
      const now = Math.floor(Date.now() / 1000);
      urlsRepository.findByOwnerId.mockResolvedValue([
        {
          shortCode: 'active1',
          longUrl: 'https://active.example',
          ownerId: 'user-1',
          createdAt: new Date().toISOString(),
        },
        {
          shortCode: 'expired',
          longUrl: 'https://expired.example',
          ownerId: 'user-1',
          createdAt: new Date().toISOString(),
          expiresAt: now - 10,
        },
      ]);

      const result = await service.listByOwner('user-1');
      expect(result).toHaveLength(1);
      expect(result[0].shortCode).toBe('active1');
    });
  });
});
