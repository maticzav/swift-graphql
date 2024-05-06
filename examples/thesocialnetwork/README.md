# The Social Network

A sample server for a social network that

- supports authentication,
- implements file upload using signed links,
- uses subscriptions,
- lets users write to a shared feed.

```bash
# Start Server
yarn start

# Generate Prisma Client
yarn prisma generate

# Generate TypeGen
yarn generate
```


### Development Setup

Start local Postgres database using Docker Compose.

```bash
# Start DB in the background
docker-compose up -d

# Setup Environment variables
cp .env.example .env
```
