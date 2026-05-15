import {
  ConflictException,
  Injectable,
  OnModuleInit,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { randomUUID } from 'crypto';
import type { AppConfig } from '../config/configuration';
import { normalizeSafeEmail } from '../common/validation/safe-email';
import type { AuthResponseDto } from './dto/auth-response.dto';
import { LoginDto } from './dto/login.dto';
import { SignUpDto } from './dto/sign-up.dto';
import type { PublicUser, UserRecord, UserRole } from './entities/user.entity';
import { UsersRepository } from './users.repository';

const BCRYPT_ROUNDS = 12;
const DEFAULT_ROLE: UserRole = 'user';

@Injectable()
export class UsersService implements OnModuleInit {
  constructor(
    private readonly usersRepository: UsersRepository,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService<AppConfig, true>,
  ) {}

  onModuleInit(): void {
    const jwtSecret = this.configService.get('jwtSecret', { infer: true });
    const usersTableName = this.configService.get('usersTableName', {
      infer: true,
    });

    if (!jwtSecret) {
      throw new Error('JWT_SECRET environment variable is required');
    }
    if (!usersTableName) {
      throw new Error('USERS_TABLE_NAME environment variable is required');
    }
  }

  async signUp(dto: SignUpDto): Promise<PublicUser> {
    const email = normalizeSafeEmail(dto.email);
    const existing = await this.usersRepository.findByEmail(email);

    if (existing) {
      throw new ConflictException('Email is already registered');
    }

    const passwordHash = await bcrypt.hash(dto.password, BCRYPT_ROUNDS);
    const user: UserRecord = {
      userId: randomUUID(),
      email,
      passwordHash,
      role: DEFAULT_ROLE,
    };

    await this.usersRepository.create(user);
    return this.toPublicUser(user);
  }

  async login(dto: LoginDto): Promise<AuthResponseDto> {
    const email = normalizeSafeEmail(dto.email);
    const user = await this.usersRepository.findByEmail(email);

    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const passwordMatches = await bcrypt.compare(dto.password, user.passwordHash);
    if (!passwordMatches) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const publicUser = this.toPublicUser(user);
    const accessToken = await this.jwtService.signAsync({
      sub: user.userId,
      email: user.email,
      role: user.role,
    });

    return {
      accessToken,
      tokenType: 'Bearer',
      user: publicUser,
    };
  }

  private toPublicUser(user: UserRecord): PublicUser {
    return {
      userId: user.userId,
      email: user.email,
      role: user.role,
    };
  }
}
