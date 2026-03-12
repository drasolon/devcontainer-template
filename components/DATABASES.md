# Database Components

## PostgreSQL

### Why PostgreSQL?
- Powerful, open-source, reliable
- Perfect for relational data
- PostGIS extension for geographic data
- Excellent for fullstack/GIS applications

### Supported Versions
- 12 (EOL: Oct 2024)
- 13 (EOL: Nov 2025)
- 14 (EOL: Nov 2026)
- 15 (Current stable)
- 16 (Latest)

### Docker Configuration
```yaml
services:
  postgres:
    image: postgres:16-alpine
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_NAME}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
```

### Connection Configuration
- **Host**: `postgres` (in compose) or remote IP
- **Port**: 5432 (default)
- **Connection String**: `postgresql://user:password@host:5432/dbname`

### Environment Variables (.env)
```
DB_HOST=postgres
DB_PORT=5432
DB_USER=devuser
DB_PASSWORD=devpass123
DB_NAME=appdb
DATABASE_URL=postgresql://devuser:devpass123@postgres:5432/appdb
```

### Backend Integration Examples

#### Python (FastAPI/Django)
```python
# .env variables
SQLALCHEMY_DATABASE_URL = "postgresql://user:password@postgres:5432/dbname"
```

#### Node.js (TypeORM example)
```javascript
// .env variables
DB_HOST=postgres
DB_PORT=5432
DB_USERNAME=devuser
DB_PASSWORD=devpass123
DB_NAME=appdb
```

#### Go (GORM example)
```go
dsn := os.Getenv("DATABASE_URL")
// or construct from env vars
dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
  os.Getenv("DB_HOST"), os.Getenv("DB_PORT"), os.Getenv("DB_USER"),
  os.Getenv("DB_PASSWORD"), os.Getenv("DB_NAME"))
```

---

## MongoDB

### Why MongoDB?
- NoSQL, flexible schema
- Great for document-based data
- Scalability, horizontal distribution

### Supported Versions
- 5.0 (EOL: April 2024)
- 6.0 (EOL: April 2025)
- 7.0 (Current)

### Docker Configuration
```yaml
services:
  mongodb:
    image: mongo:7.0
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_USER}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD}
      MONGO_INITDB_DATABASE: ${MONGO_DB}
    volumes:
      - mongodb_data:/data/db
    healthcheck:
      test: echo 'db.runCommand("ping").ok' | mongosh localhost:27017/test --quiet
      interval: 10s
      timeout: 5s
      retries: 5
```

### Connection Configuration
- **Connection String**: `mongodb://user:password@host:27017/dbname`
- **Port**: 27017 (default)

### Environment Variables (.env)
```
MONGO_HOST=mongodb
MONGO_PORT=27017
MONGO_USER=devuser
MONGO_PASSWORD=devpass123
MONGO_DB=appdb
MONGODB_URI=mongodb://devuser:devpass123@mongodb:27017/appdb
```

---

## MySQL

### Why MySQL?
- Lightweight, fast
- ACID compliance
- Wide framework support

### Supported Versions
- 5.7 (EOL: Oct 2023)
- 8.0 (Current)
- 8.1 (Latest)

### Docker Configuration
```yaml
services:
  mysql:
    image: mysql:8.0
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
    volumes:
      - mysql_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
```

### Connection Configuration
- **Connection String**: `mysql://user:password@host:3306/dbname`
- **Port**: 3306 (default)

### Environment Variables (.env)
```
DB_HOST=mysql
DB_PORT=3306
DB_USER=devuser
DB_PASSWORD=devpass123
DB_NAME=appdb
DATABASE_URL=mysql://devuser:devpass123@mysql:3306/appdb
```

---

## Redis

### Why Redis?
- In-memory caching
- Session storage
- Real-time features (pub/sub)
- Message queuing complement

### Supported Versions
- 6.x (EOL: April 2024)
- 7.x (Current)

### Docker Configuration
```yaml
services:
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
```

### Connection Configuration
- **Connection String**: `redis://user:password@host:6379`
- **Port**: 6379 (default)

### Environment Variables (.env)
```
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=devpass123
REDIS_URL=redis://:devpass123@redis:6379
```

---

## Remote Database Configuration (Semi-Dev Setup)

For app local, DB on remote servers:

### Configuration
```yaml
# docker-compose.yml - NO database service defined locally
# Instead, use environment variables pointing to remote

environment:
  DB_HOST: your-production-db.example.com
  DB_PORT: 5432
  DB_USER: ${REMOTE_DB_USER}
  DB_PASSWORD: ${REMOTE_DB_PASSWORD}
  DB_NAME: ${REMOTE_DB_NAME}
```

### .env Template
```
# Remote Database Configuration
REMOTE_DB_HOST=your-db-server.example.com
REMOTE_DB_PORT=5432
REMOTE_DB_USER=username
REMOTE_DB_PASSWORD=your-secure-password
REMOTE_DB_NAME=production_db
```

### Important Notes:
- Remote DB must be accessible from devcontainer
- Network connectivity required (VPN, IP whitelisting, etc.)
- Keep credentials in `.env` (never commit)
- Test connectivity: `telnet host port` or `nc -zv host port`

---

## Volume Persistence

### Local Development (keep data)
```yaml
volumes:
  postgres_data:
    driver: local
```

### Fresh Start (no persistence)
```yaml
# Don't define volumes, data lost on container restart
```

### Choice Decision:
- **Start fresh each time?** No volumes
- **Keep data between sessions?** Use named volumes
