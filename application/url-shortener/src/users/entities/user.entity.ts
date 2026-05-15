export type UserRole = 'user' | 'admin';

export interface UserRecord {
  userId: string;
  email: string;
  passwordHash: string;
  role: UserRole;
}

export interface PublicUser {
  userId: string;
  email: string;
  role: UserRole;
}
