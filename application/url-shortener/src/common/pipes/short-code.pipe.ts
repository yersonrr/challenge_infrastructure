import { BadRequestException, Injectable, type PipeTransform } from '@nestjs/common';
import { SHORT_CODE_PATTERN } from '../constants/short-code';

@Injectable()
export class ShortCodeValidationPipe implements PipeTransform<string, string> {
  transform(value: string): string {
    if (!SHORT_CODE_PATTERN.test(value)) {
      throw new BadRequestException('Invalid short code format');
    }

    return value;
  }
}
