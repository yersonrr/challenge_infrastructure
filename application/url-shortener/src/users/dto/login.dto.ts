import { Transform } from 'class-transformer';
import { IsSafeEmail } from '../../common/validation/is-safe-email.validator';
import { IsSafePassword } from '../../common/validation/is-safe-password.validator';

export class LoginDto {
  @Transform(({ value }) => (typeof value === 'string' ? value.trim().toLowerCase() : value))
  @IsSafeEmail()
  email: string;

  @IsSafePassword()
  password: string;
}
