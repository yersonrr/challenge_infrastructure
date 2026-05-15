import { ConflictException, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import type { AppConfig } from '../../config/configuration';
import { UsersRepository } from '../users.repository';
import { UsersService } from '../users.service';

const baseAppConfig: AppConfig = {
  nodeEnv: 'test',
  jwtSecret: 'test-secret',
  dbEndpoint: 'https://dynamodb.eu-west-1.amazonaws.com',
  usersTableName: 'challenge-staging-users',
  urlsTableName: 'challenge-staging-urls',
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

describe('UsersService', () => {
  const usersRepository = {
    findByEmail: jest.fn(),
    create: jest.fn(),
    findById: jest.fn(),
  };

  const jwtService = {
    signAsync: jest.fn().mockResolvedValue('token-123'),
  };

  let configService: ConfigService<AppConfig, true>;
  let service: UsersService;

  const createService = (configOverrides: Partial<AppConfig> = {}): UsersService => {
    configService = createConfigServiceMock(configOverrides);
    return new UsersService(
      usersRepository as unknown as UsersRepository,
      jwtService as unknown as JwtService,
      configService,
    );
  };

  beforeEach(() => {
    jest.clearAllMocks();
    service = createService();
    service.onModuleInit();
  });

  describe('onModuleInit', () => {
    it('throws when JWT_SECRET is missing', () => {
      const uninitialized = createService({ jwtSecret: '' });
      expect(() => uninitialized.onModuleInit()).toThrow(
        'JWT_SECRET environment variable is required',
      );
    });

    it('throws when USERS_TABLE_NAME is missing', () => {
      const uninitialized = createService({ usersTableName: '' });
      expect(() => uninitialized.onModuleInit()).toThrow(
        'USERS_TABLE_NAME environment variable is required',
      );
    });

    it('does not throw when required config is present', () => {
      expect(() => service.onModuleInit()).not.toThrow();
    });
  });

  describe('signUp', () => {
    it('creates a user when email is available', async () => {
      usersRepository.findByEmail.mockResolvedValue(null);
      usersRepository.create.mockResolvedValue(undefined);

      const result = await service.signUp({
        email: 'user@example.com',
        password: 'password123',
      });

      expect(result.email).toBe('user@example.com');
      expect(result.userId).toMatch(
        /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i,
      );
      expect(result.role).toBe('user');
      expect(usersRepository.create).toHaveBeenCalledTimes(1);
    });

    it('normalizes email to lowercase before persisting', async () => {
      usersRepository.findByEmail.mockResolvedValue(null);
      usersRepository.create.mockResolvedValue(undefined);

      await service.signUp({
        email: '  User@Example.COM  ',
        password: 'password123',
      });

      expect(usersRepository.findByEmail).toHaveBeenCalledWith('user@example.com');
      expect(usersRepository.create).toHaveBeenCalledWith(
        expect.objectContaining({ email: 'user@example.com' }),
      );
    });

    it('stores a bcrypt hash, not the plain password', async () => {
      usersRepository.findByEmail.mockResolvedValue(null);
      usersRepository.create.mockResolvedValue(undefined);

      await service.signUp({
        email: 'user@example.com',
        password: 'password123',
      });

      const createdUser = usersRepository.create.mock.calls[0][0];
      expect(createdUser.passwordHash).not.toBe('password123');
      expect(createdUser.passwordHash).toMatch(/^\$2[aby]\$/);
      await expect(bcrypt.compare('password123', createdUser.passwordHash)).resolves.toBe(
        true,
      );
    });

    it('does not expose passwordHash in the response', async () => {
      usersRepository.findByEmail.mockResolvedValue(null);
      usersRepository.create.mockResolvedValue(undefined);

      const result = await service.signUp({
        email: 'user@example.com',
        password: 'password123',
      });

      expect(result).not.toHaveProperty('passwordHash');
    });

    it('rejects duplicate email', async () => {
      usersRepository.findByEmail.mockResolvedValue({
        userId: 'existing',
        email: 'user@example.com',
        passwordHash: 'hash',
        role: 'user',
      });

      await expect(
        service.signUp({ email: 'user@example.com', password: 'password123' }),
      ).rejects.toBeInstanceOf(ConflictException);

      expect(usersRepository.create).not.toHaveBeenCalled();
    });
  });

  describe('login', () => {
    it('returns a JWT for valid credentials', async () => {
      const passwordHash = await bcrypt.hash('password123', 4);
      usersRepository.findByEmail.mockResolvedValue({
        userId: 'user-1',
        email: 'user@example.com',
        passwordHash,
        role: 'user',
      });

      const result = await service.login({
        email: 'user@example.com',
        password: 'password123',
      });

      expect(result.accessToken).toBe('token-123');
      expect(result.tokenType).toBe('Bearer');
      expect(result.user).toEqual({
        userId: 'user-1',
        email: 'user@example.com',
        role: 'user',
      });
      expect(jwtService.signAsync).toHaveBeenCalledWith({
        sub: 'user-1',
        email: 'user@example.com',
        role: 'user',
      });
    });

    it('normalizes email before lookup', async () => {
      const passwordHash = await bcrypt.hash('password123', 4);
      usersRepository.findByEmail.mockResolvedValue({
        userId: 'user-1',
        email: 'user@example.com',
        passwordHash,
        role: 'user',
      });

      await service.login({
        email: '  User@Example.COM  ',
        password: 'password123',
      });

      expect(usersRepository.findByEmail).toHaveBeenCalledWith('user@example.com');
    });

    it('rejects unknown email', async () => {
      usersRepository.findByEmail.mockResolvedValue(null);

      await expect(
        service.login({ email: 'user@example.com', password: 'password123' }),
      ).rejects.toBeInstanceOf(UnauthorizedException);

      expect(jwtService.signAsync).not.toHaveBeenCalled();
    });

    it('rejects wrong password', async () => {
      const passwordHash = await bcrypt.hash('other-password', 4);
      usersRepository.findByEmail.mockResolvedValue({
        userId: 'user-1',
        email: 'user@example.com',
        passwordHash,
        role: 'user',
      });

      await expect(
        service.login({ email: 'user@example.com', password: 'password123' }),
      ).rejects.toBeInstanceOf(UnauthorizedException);

      expect(jwtService.signAsync).not.toHaveBeenCalled();
    });
  });
});
