-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Run in order
\i database_objects/create_tables.sql
\i database_objects/create_constraints.sql
\i database_objects/create_indexes.sql
\i database_objects/insert_data.sql
\i queries/queries_basic.sql
\i queries/queries_advanced.sql
