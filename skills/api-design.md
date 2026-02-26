---
name: api-design
description: Guidelines for designing consistent, secure, and well-documented REST APIs.
---

# API Design Guidelines

## General Rules
Always design APIs following REST principles.
Always use JSON as the default data format.
Always version all APIs from the start — never release an unversioned API.
Always document every endpoint using OpenAPI 3.0 / Swagger.
Write all comments and documentation in English.
Never expose internal implementation details in API responses.
Never expose raw database errors or stack traces to the client.

## URL Conventions
Always use kebab-case for URL paths.
Always use plural nouns for resource names — never verbs.
Never use verbs in URLs — the HTTP method defines the action.

Examples:
✅ GET    /api/v1/users
✅ GET    /api/v1/users/:id
✅ POST   /api/v1/users
✅ PATCH  /api/v1/users/:id
✅ DELETE /api/v1/users/:id
✅ GET    /api/v1/users/:id/orders
❌ GET    /api/v1/getUsers
❌ POST   /api/v1/createUser
❌ GET    /api/v1/user (singular)

## Versioning
Always prefix all API routes with /api/v[n]/.
Always increment the version when introducing breaking changes.
Never modify an existing versioned API in a breaking way.
Always maintain at least one previous version during transition periods.
Deprecate old versions with a Deprecation header and sunset date.

Versioning format:
- Current: /api/v1/
- Next breaking change: /api/v2/
- Deprecation header: Deprecation: true, Sunset: 2026-12-31

## HTTP Methods
Always use the correct HTTP method for each operation:
- GET    — retrieve a resource or collection (never mutate data)
- POST   — create a new resource
- PUT    — replace a resource entirely
- PATCH  — partially update a resource (preferred over PUT for partial updates)
- DELETE — remove a resource

Never use GET for mutations.
Never use POST for everything — use the appropriate method.

## HTTP Status Codes
Always return the most semantically accurate status code.

Success:
- 200 OK             — successful GET, PATCH, PUT
- 201 Created        — successful POST (always include the created resource)
- 204 No Content     — successful DELETE (no body)

Client Errors:
- 400 Bad Request    — invalid input, validation errors
- 401 Unauthorized   — missing or invalid authentication
- 403 Forbidden      — authenticated but not authorized
- 404 Not Found      — resource does not exist
- 409 Conflict       — duplicate resource, version conflict
- 422 Unprocessable  — semantically invalid input
- 429 Too Many Reqs  — rate limit exceeded

Server Errors:
- 500 Internal Error — unexpected server error
- 502 Bad Gateway    — upstream service failure
- 503 Unavailable    — service temporarily down

Never return 200 with an error message in the body.
Never return 500 for client mistakes.

## Response Format
Always use a consistent response envelope for all endpoints.

Success response:
{
  "success": true,
  "data": { ... },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "version": "v1"
  }
}

Error response:
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request contains invalid fields.",
    "details": [
      {
        "field": "email",
        "message": "Must be a valid email address."
      }
    ]
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "version": "v1"
  }
}

Paginated response:
{
  "success": true,
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "perPage": 20,
    "total": 150,
    "totalPages": 8,
    "hasNextPage": true,
    "hasPreviousPage": false
  },
  "meta": {
    "timestamp": "2025-01-01T00:00:00Z",
    "version": "v1"
  }
}

Never return arrays at the root level of a response.
Never return different response shapes for the same endpoint.

## Pagination
Always paginate collection endpoints — never return unbounded lists.
Use cursor-based pagination for large datasets or realtime data.
Use offset-based pagination for standard admin or dashboard use cases.

Query parameters for offset pagination:
- page (default: 1)
- perPage (default: 20, max: 100)

Query parameters for cursor pagination:
- cursor (opaque string)
- limit (default: 20, max: 100)

## Filtering, Sorting & Searching
Use query parameters for filtering:
  GET /api/v1/users?status=active&role=admin
Use sort and order for sorting:
  GET /api/v1/users?sort=createdAt&order=desc
Use q or search for full-text search:
  GET /api/v1/users?q=john

Always whitelist allowed filter and sort fields — never pass raw query params to the database.

## Input Validation
Always validate all input at the API boundary using Zod (TypeScript) or 
Bean Validation (Spring Boot).
Always return 400 or 422 with detailed field-level error messages on validation failure.
Never trust client-provided data — always validate and sanitize server-side.

## Security
Always require authentication for all non-public endpoints.
Always implement rate limiting on all endpoints:
- Public endpoints: 60 requests/minute
- Authenticated endpoints: 300 requests/minute
- Auth endpoints (login, register): 10 requests/minute

Always configure CORS explicitly — never use wildcard (*) in production.
Always use HTTPS — never serve APIs over plain HTTP.
Always strip sensitive fields (password, token, secret) from responses.
Always log all API requests with: method, path, status, duration, user ID.

## Authentication in APIs
Use JWT Bearer tokens for stateless APIs consumed by mobile or third-party clients.
Use session cookies for web applications (React Router v7).
Always validate token expiry, signature, and issuer on every request.
Always implement token refresh logic for long-lived sessions.
Include auth details in the Authorization header — never in query parameters.

## Documentation — OpenAPI 3.0
Always document every endpoint with:
- Summary and description
- All path, query, and body parameters with types and examples
- All possible response codes with response schemas
- Authentication requirements
- Deprecation notices when applicable

Always keep documentation in sync with the actual implementation.
Use tools like Swagger UI or Scalar for interactive documentation.

## Naming Conventions
Always use camelCase for JSON field names.
Always use SCREAMING_SNAKE_CASE for error codes.
Always use ISO 8601 for all date and datetime fields (e.g. 2025-01-01T00:00:00Z).
Always use consistent field names across all endpoints:
- id — primary identifier
- createdAt — creation timestamp
- updatedAt — last update timestamp
- deletedAt — soft delete timestamp
