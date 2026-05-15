export interface UrlRecord {
  shortCode: string;
  longUrl: string;
  ownerId: string;
  createdAt: string;
  expiresAt?: number;
}

export interface PublicUrl {
  shortCode: string;
  longUrl: string;
  ownerId: string;
  createdAt: string;
  expiresAt?: number;
}
