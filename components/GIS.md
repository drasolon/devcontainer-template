# GIS Components

## PostGIS

### Why PostGIS?
- Geographic extension for PostgreSQL
- Store and query spatial data (points, lines, polygons, etc.)
- Essential for GIS-oriented fullstack apps
- Perfect for mapping applications

### Supported Versions
- PostGIS 3.2
- PostGIS 3.3 (Current)
- PostGIS 3.4 (Latest)

### Installation (Docker)
```yaml
services:
  postgres:
    image: postgis/postgis:16-3.4  # PostgreSQL 16 + PostGIS 3.4
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

### Initialization SQL
Create `init-gis.sql`:
```sql
-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;

-- Create example table
CREATE TABLE locations (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  geom GEOMETRY(Point, 4326)
);

-- Create spatial index
CREATE INDEX idx_locations_geom ON locations USING GIST(geom);
```

### Backend Integration

#### Python (GeoAlchemy2)
```python
from geoalchemy2 import Geometry
from sqlalchemy import Column, Integer, String, create_engine
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class Location(Base):
    __tablename__ = "locations"
    id = Column(Integer, primary_key=True)
    name = Column(String(255))
    geom = Column(Geometry("POINT", srid=4326))

# Connection
engine = create_engine("postgresql://user:password@postgres:5432/gisdb")
```

#### Node.js (Sequelize + PostGIS)
```javascript
const { DataTypes } = require('sequelize');

const Location = sequelize.define('Location', {
  name: DataTypes.STRING,
  geom: {
    type: DataTypes.GEOMETRY('POINT', 4326)
  }
});
```

#### TypeScript (Typeorm + PostGIS)
```typescript
import { Entity, PrimaryGeneratedColumn, Column } from "typeorm";

@Entity()
export class Location {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column({
    type: "geometry",
    spatialFeatureType: "Point",
    srid: 4326
  })
  geom: string;
}
```

### Testing PostGIS
```bash
# Connect to database
psql -U devuser -d appdb -h postgres

# Test PostGIS
SELECT PostGIS_version();
SELECT ST_AsText(ST_GeomFromText('POINT(0 0)', 4326));
```

### Common Spatial Queries
```sql
-- Find points within distance
SELECT * FROM locations 
WHERE ST_DWithin(geom, ST_Point(-73.97, 40.77, 4326)::geography, 1000);

-- Calculate distance
SELECT name, ST_Distance(geom::geography, ST_Point(-73.97, 40.77, 4326)::geography) 
FROM locations;

-- Buffer geometry
SELECT name, ST_Buffer(geom::geography, 500)
FROM locations;
```

### Environment Variables (.env)
```
# PostGIS Database
DB_HOST=postgres
DB_PORT=5432
DB_USER=devuser
DB_PASSWORD=devpass123
DB_NAME=gisdb
DATABASE_URL=postgresql://devuser:devpass123@postgres:5432/gisdb
```

---

## GeoServer

### Why GeoServer?
- Web map server (WMS, WFS, WCS)
- Publish spatial data on maps
- REST API for layer management
- Great for complex GIS applications

### Supported Versions
- 2.22.x (Stable)
- 2.23.x (Latest)

### Docker Configuration
```yaml
services:
  geoserver:
    image: kartoza/geoserver:2.23.0
    ports:
      - "8080:8080"
    environment:
      GEOSERVER_ADMIN_USER: ${GEO_ADMIN_USER}
      GEOSERVER_ADMIN_PASSWORD: ${GEO_ADMIN_PASSWORD}
      GEOSERVER_DATA_DIR: /opt/geoserver/data_dir
    volumes:
      - geoserver_data:/opt/geoserver/data_dir
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/geoserver/web/"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Web Interface Access
- **URL**: `http://localhost:8080/geoserver`
- **Default User**: `admin` / `geoserver` (change via env)

### Environment Variables (.env)
```
GEO_ADMIN_USER=admin
GEO_ADMIN_PASSWORD=securepass123
GEO_SERVER_HOST=geoserver
GEO_SERVER_PORT=8080
```

### Creation of Layer (PostGIS + GeoServer)
1. In GeoServer Web UI
2. Data > Data Stores > New Data Store
3. Select "PostGIS" type
4. Configure connection to PostgreSQL
5. Create layer from table (e.g., `locations`)

### Frontend Integration (Leaflet example)
```javascript
// Load WMS layer from GeoServer
L.tileLayer.wms('http://localhost:8080/geoserver/wms', {
  layers: 'workspace:locations',
  transparent: true,
  version: '1.1.0'
}).addTo(map);
```

### Testing GeoServer
```bash
# Check if GeoServer is running
curl http://geoserver:8080/geoserver/web/

# Query WFS endpoint
curl "http://geoserver:8080/geoserver/ows?service=wfs&version=1.0.0&request=GetFeature&typeName=workspace:locations&outputFormat=json"
```

---

## QGIS Server

### Why QGIS Server?
- Lightweight alternative to GeoServer
- Uses QGIS projects (.qgs files)
- Good for smaller datasets
- Less resource-intensive

### Docker Configuration
```yaml
services:
  qgis-server:
    image: kartoza/qgis-server:3.28
    ports:
      - "9080:80"
    environment:
      QGIS_PROJECT_FILE: /data/project.qgs
    volumes:
      - ./qgis-projects:/data
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Project Setup
1. Create QGIS project file (.qgs)
2. Add layers (PostGIS, Shapefile, etc.)
3. Mount to container at `/data/project.qgs`
4. Server automatically loads and serves

### Environment Variables (.env)
```
QGIS_PROJECT_FILE=/data/project.qgs
QGIS_SERVER_PORT=9080
```

### Testing QGIS Server
```bash
# WMS GetCapabilities
curl "http://localhost:9080/?service=wms&version=1.3.0&request=GetCapabilities"

# WFS GetFeature
curl "http://localhost:9080/?service=wfs&version=1.0.0&request=GetFeature&typeName=layername&outputFormat=json"
```

---

## GIS Stack Recommendations

### Minimal (Small dataset, simple app)
- **Database**: PostgreSQL + PostGIS
- **Server**: QGIS Server (lighter footprint)
- **Best for**: Prototype, small team

### Standard (Growing app, multiple users)
- **Database**: PostgreSQL + PostGIS
- **Server**: GeoServer (more features)
- **Best for**: Production apps, complex workflows

### Full Stack (Enterprise, complex)
- **Database**: PostgreSQL + PostGIS
- **Server**: GeoServer + QGIS Server (redundancy)
- **Cache**: Redis (for tile caching)
- **Best for**: Large-scale applications

---

## Testing GIS Components

### PostGIS Connection Test
```bash
psql -h postgres -U devuser -d gisdb -c "SELECT PostGIS_version();"
```

### WMS Server Test
```bash
curl -v "http://geoserver:8080/geoserver/wms?service=wms&version=1.1.0&request=GetCapabilities"
```

### End-to-End GIS Test
1. Data stored in PostGIS ✓
2. Published via WMS/WFS ✓
3. Accessible from frontend ✓
4. Map displays correctly ✓
