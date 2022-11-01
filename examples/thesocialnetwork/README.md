# The Social Network

A sample server for a social network that

- supports authentication,
- implements file upload using signed links,
- uses subscriptions,
- lets users write to a shared feed.

### Development Setup

Start local Postgres database using Docker Compose.

```bash
docker-compose up -d

export DATABASE_URL="postgresql://prisma:prisma@localhost:5432/prisma"
```
