# Node LTS on Alpine with pnpm
FROM node:22-alpine AS base
RUN corepack enable && corepack prepare pnpm@9.15.4 --activate
WORKDIR /app

# Dependencies using lockfile
FROM base AS deps
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# build
FROM base AS build
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN pnpm run build

# Production runtime
FROM node:22-alpine AS production
RUN corepack enable && corepack prepare pnpm@9.15.4 --activate
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

RUN addgroup -g 1001 -S nodejs \
  && adduser -S nestjs -u 1001 -G nodejs

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod --frozen-lockfile \
  && pnpm store prune \
  && rm -rf /root/.local/share/pnpm/store

COPY --from=build /app/dist ./dist

USER nestjs
EXPOSE 3000

# App Runner health checks
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD node -e "require('http').get('http://127.0.0.1:' + (process.env.PORT || 3000) + '/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

CMD ["node", "dist/main.js"]
