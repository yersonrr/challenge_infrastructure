export interface AppConfig {
  nodeEnv: string;
  jwtSecret: string;
  dbEndpoint?: string;
  usersTableName: string;
  urlsTableName: string;
  awsRegion: string;
}

export default (): AppConfig => ({
  nodeEnv: process.env.NODE_ENV ?? 'development',
  jwtSecret: process.env.JWT_SECRET ?? '',
  dbEndpoint: process.env.DB_ENDPOINT,
  usersTableName: process.env.USERS_TABLE_NAME ?? '',
  urlsTableName: process.env.URLS_TABLE_NAME ?? '',
  awsRegion:
    process.env.AWS_REGION ?? process.env.AWS_DEFAULT_REGION ?? 'eu-west-1',
});
