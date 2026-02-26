---
name: database-conventions
description: Guidelines for database selection and usage.
---

# Database Conventions

## General Rules
Always follow Clean Architecture — never expose raw database queries 
beyond the data layer.
Always abstract database access behind a repository interface.
Never put database logic inside route files, controllers, or UI components.
Always use environment variables for all database credentials.
Never hardcode connection strings, passwords, or API keys.
Write all comments in English.

## Database Selection Guide

### PostgreSQL / Neon Postgres
Use when:
- The project requires complex relational data with joins and transactions
- You need advanced SQL features (CTEs, window functions, JSONB, full-text search)
- The project is a large-scale web or backend application
- You need strong ACID compliance
- Use Neon Postgres specifically for serverless or edge deployments

Preferred ORM: Drizzle ORM (lightweight, TypeScript-first)

### MySQL / MariaDB
Use when:
- The project requires a battle-tested relational database
- The hosting environment favors MySQL (shared hosting, legacy infrastructure)
- The project is a medium-scale web application

Preferred ORM: Drizzle ORM

### Supabase
Use when:
- The project needs a backend-as-a-service with built-in auth
- You need realtime subscriptions out of the box
- Rapid prototyping or MVP development is required
- The project benefits from auto-generated REST and GraphQL APIs
- Row Level Security (RLS) policies are needed

Note: Supabase runs on PostgreSQL — all PostgreSQL conventions apply.
Always enable RLS on all tables when using Supabase.
Never bypass RLS by using the service role key on the client side.

### Firebase (Firestore)
Use when:
- The project is mobile-first (Flutter) and requires offline sync
- You need realtime listeners across multiple clients
- The data model is document-based and hierarchical
- Rapid prototyping with minimal backend setup is required

Avoid Firebase when:
- The data is highly relational and requires complex queries
- You need strong consistency and transactions across multiple collections

### Redis
Use when:
- You need caching for expensive database queries or API responses
- You need session storage (always prefer Redis over database sessions)
- You need rate limiting, pub/sub, or job queues
- You need leaderboards or real-time counters

Never use Redis as a primary database.
Always set TTL (expiration) on all cached keys.
Always define a key naming convention:
  Format: [app]:[entity]:[identifier]
  Example: myapp:user:123, myapp:session:abc456

## Schema Conventions

### Naming
Always use snake_case for table names, column names, indexes, and constraints.
Always use plural names for tables (users, orders, products).
Never use reserved SQL keywords as table or column names.
Never abbreviate column names — always use full descriptive names.

### Primary Keys
Always use id as the primary key column name.
Prefer UUID (uuid_generate_v4()) over auto-increment integers for:
- Distributed systems
- Public-facing IDs (never expose sequential integers)
Use auto-increment (SERIAL / BIGSERIAL) only for internal, high-volume tables
where performance is critical.

### Foreign Keys
Always define explicit foreign key constraints.
Naming convention: fk_[table]_[referenced_table]
Example: fk_orders_users
Always define ON DELETE behavior explicitly:
- ON DELETE CASCADE — when child records have no meaning without parent
- ON DELETE RESTRICT — when child records must be reassigned before deletion
- ON DELETE SET NULL — when the relationship is optional

### Timestamps
Always include created_at and updated_at on every table.
Always use TIMESTAMPTZ (timestamp with time zone) — never TIMESTAMP without TZ.
Always set default values:
- created_at: DEFAULT NOW()
- updated_at: updated via trigger or ORM hook

### Soft Deletes
Use deleted_at TIMESTAMPTZ NULL for soft deletes when data must be retained.
Always filter deleted_at IS NULL in queries when soft deletes are enabled.
Never use a boolean is_deleted column — always prefer deleted_at.

### Indexes
Always index foreign key columns.
Always index columns used in WHERE, ORDER BY, and JOIN clauses frequently.
Use partial indexes for filtered queries (e.g. WHERE deleted_at IS NULL).
Use composite indexes when multiple columns are always queried together.
Naming convention: idx_[table]_[column(s)]
Example: idx_users_email, idx_orders_user_id_created_at

## Security Rules
Always use parameterized queries or ORM query builders — never string concatenation.
Never expose raw database errors to the client — always map to domain errors.
Always validate and sanitize all user input before passing to queries.
Always use the principle of least privilege for database users:
- Read-only user for SELECT operations
- Write user for INSERT/UPDATE/DELETE
- Migration user for schema changes only
Always encrypt sensitive columns (passwords, tokens, PII) at the application level.
Never store plain text passwords — always use bcrypt or argon2.

## Migrations
Always use a migration tool — never modify the schema manually in production.
Recommended tools:
- Drizzle Kit for Drizzle ORM projects
- Prisma Migrate for Prisma projects
- Flyway or Liquibase for Spring Boot projects

Migration rules:
- Always version migrations sequentially (e.g. 001_create_users.sql)
- Never modify a migration file after it has been applied in production
- Always write both up (apply) and down (rollback) migrations
- Always test migrations on a staging environment before production
- Never run migrations automatically on app startup in production —
  run them as a separate deployment step

## Repository Pattern
Always define an abstract repository interface in the domain layer.
Always implement the concrete repository in the data layer.
Never return raw database models from repositories —
always map to domain entities.

Example structure:
// Domain layer — abstract interface
abstract class UserRepository {
  Future<User> findById(String id);
  Future<User> create(CreateUserParams params);
  Future<User> update(String id, UpdateUserParams params);
  Future<void> delete(String id);
}

// Data layer — concrete implementation
class UserRepositoryImpl implements UserRepository {
  final Database _db;
  // implementation using ORM or raw queries
}

## Connection Management
Always use connection pooling in production.
Recommended pool sizes:
- Small app: 5-10 connections
- Medium app: 10-25 connections
- Large app: 25-100 connections (use PgBouncer for PostgreSQL)
Always close connections properly — never leak database connections.
Always configure connection timeouts and retry logic.
