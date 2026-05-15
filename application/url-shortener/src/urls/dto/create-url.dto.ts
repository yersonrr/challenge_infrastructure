import { Transform } from 'class-transformer';
import { IsInt, IsOptional, Max, MaxLength, Min } from 'class-validator';
import { IsSafeHttpUrl } from '../../common/validation/is-safe-http-url.validator';

export class CreateUrlDto {
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @MaxLength(2048)
  @IsSafeHttpUrl()
  longUrl: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(365)
  expiresInDays?: number;
}
