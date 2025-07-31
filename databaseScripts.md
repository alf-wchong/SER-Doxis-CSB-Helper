```
CREATE ROLE fips WITH LOGIN PASSWORD 'redacted';


CREATE DATABASE fips
    WITH
    OWNER = fips
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

ALTER DATABASE fips
    SET deadlock_timeout TO '30s';
GRANT ALL ON DATABASE fips TO fips;


CREATE SCHEMA IF NOT EXISTS fips
    AUTHORIZATION fips;
GRANT ALL ON SCHEMA fips TO fips;
```

The above creates the database, database owner and database schema for the FIPS. The same can be used for CSB.
Run the above either in PSQL or pgAdmin's QueryTool.
