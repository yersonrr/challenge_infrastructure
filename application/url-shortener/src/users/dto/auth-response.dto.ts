import type { PublicUser } from '../entities/user.entity';

export class AuthResponseDto {
  accessToken: string;
  tokenType: 'Bearer';
  user: PublicUser;
}
