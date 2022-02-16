# Marvel Server

> This demo server is inspired by GraphQL's StarWars example server.

The data used in the demo is taken from Marvel's API.

> "Data provided by Marvel. © 2014 Marvel"

Do not share it with anyone! This is solely intended to be used for development purposes as is and shouldn't be reused in any comercial way.

### Development Setup

Start local Postgres database using Docker Compose.

```bash
docker-compose up -d

export DATABASE_URL="postgresql://prisma:prisma@localhost:5432/marvel"
```

Obtain public and private key from [Marvel Developer's website](https://developer.marvel.com/account) and export them as

```bash
export MARVEL_PUBLIC_KEY=""
export MARVEL_PRIVATE_KEY=""
```
