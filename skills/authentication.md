---
name: authentication
description: Guidelines for implementing secure authentication across web and mobile applications.
---

# Authentication Guidelines

## General Rules
Never implement custom authentication from scratch — always use 
established libraries.
Never store sensitive credentials in plain text.
Never expose authentication errors that reveal system internals.
Always use HTTPS for all authentication flows.
Always implement proper session invalidation on logout.
Write all comments in English.

## Web Authentication — React Router v7 + Better Auth + Drizzle ORM

### Stack
- Authentication library: better-auth (always use it for React Router v7 projects)
- ORM: Drizzle ORM (always couple better-auth with Drizzle ORM)
- Session storage: HTTP-only secure cookies (never localStorage or sessionStorage)
- Database: PostgreSQL / Neon Postgres / MySQL (via Drizzle ORM)

### Better Auth Setup
Always initialize better-auth in a dedicated lib/auth.ts file.
Always configure better-auth with the Drizzle ORM adapter.
Always define all auth options (session, cookies, providers) in one place.

File structure:
lib/
├── auth.ts          # Better Auth server instance
├── auth-client.ts   # Better Auth client instance
└── db/
    ├── schema.ts    # Drizzle schema including auth tables
    └── index.ts     # Drizzle client

Auth server setup pattern:
// lib/auth.ts
import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { db } from "./db";

export const auth = betterAuth({
  database: drizzleAdapter(db, {
    provider: "pg", // or "mysql"
  }),
  session: {
    expiresIn: 60 * 60 * 24 * 7, // 7 days
    updateAge: 60 * 60 * 24,      // refresh if older than 1 day
    cookieCache: {
      enabled: true,
      maxAge: 60 * 5,             // cache for 5 minutes
    },
  },
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: true,
  },
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    },
    github: {
      clientId: process.env.GITHUB_CLIENT_ID!,
      clientSecret: process.env.GITHUB_CLIENT_SECRET!,
    },
  },
});

Auth client setup pattern:
// lib/auth-client.ts
import { createAuthClient } from "better-auth/react";

export const authClient = createAuthClient({
  baseURL: process.env.BETTER_AUTH_URL!,
});

### Drizzle ORM Schema for Auth
Always let better-auth generate its required tables via the CLI:
  npx better-auth generate

Always integrate auth tables into the main Drizzle schema file.
Never manually create auth tables — always use better-auth's generated schema.
Always run migrations after generating the schema:
  npx drizzle-kit migrate

### Route Protection
Always protect routes inside loaders — never inside components.
Always create a reusable requireAuth() helper:

// lib/auth.server.ts
export async function requireAuth(request: Request) {
  const session = await auth.api.getSession({
    headers: request.headers,
  });
  if (!session) {
    throw redirect("/login");
  }
  return session;
}

// Usage in loader
export async function loader({ request }: LoaderFunctionArgs) {
  const session = await requireAuth(request);
  return { user: session.user };
}

Always redirect to /login for unauthenticated access.
Always redirect authenticated users away from /login and /register.

### Authentication Methods
Always support the following by default:
- Email + Password (with email verification)
- OAuth: Google
- OAuth: GitHub
- Magic Link (when explicitly requested)

Always hash passwords using better-auth's built-in hashing (argon2).
Never implement custom password hashing.

### Session Management
Always use HTTP-only secure cookies for session storage.
Never store session tokens in localStorage or sessionStorage.
Always set the following cookie attributes in production:
- HttpOnly: true
- Secure: true
- SameSite: Lax
- Path: /

Always invalidate the session server-side on logout.
Always rotate session tokens after privilege escalation.

### CSRF Protection
Always enable CSRF protection via better-auth's built-in middleware.
Never disable CSRF protection in production.
Always validate the origin header on state-changing requests.

### Environment Variables
Always define the following for better-auth:
- BETTER_AUTH_SECRET — random 32+ character secret
- BETTER_AUTH_URL — full base URL of the application
- GOOGLE_CLIENT_ID / GOOGLE_CLIENT_SECRET
- GITHUB_CLIENT_ID / GITHUB_CLIENT_SECRET
- DATABASE_URL — Drizzle ORM connection string

Always validate all environment variables at startup using Zod.

## Mobile Authentication — Flutter

### Stack
- HTTP client: Dio
- Secure storage: flutter_secure_storage
- State management: Riverpod
- Navigation guard: GoRouter redirect

### Token Storage
Always store tokens in flutter_secure_storage — never in SharedPreferences.
Never store tokens in plain text or in-memory only (lost on app restart).
Always encrypt sensitive data before storing:
  await secureStorage.write(key: 'access_token', value: token);

### Auth State Management
Always manage auth state with a Riverpod AsyncNotifier.
Always expose an authStateProvider that other providers and GoRouter can watch.
Always initialize auth state on app startup by checking stored tokens.

Auth provider pattern:
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthState> build() async {
    return _checkStoredSession();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(email, password),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(AuthState.unauthenticated());
  }
}

### Route Protection with GoRouter
Always use GoRouter's redirect callback for auth guards.
Never guard routes inside screen widgets.

GoRouter redirect pattern:
redirect: (context, state) {
  final authState = ref.read(authNotifierProvider);
  final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
  final isAuthRoute = state.matchedLocation == '/login' || 
                      state.matchedLocation == '/register';

  if (!isAuthenticated && !isAuthRoute) return '/login';
  if (isAuthenticated && isAuthRoute) return '/dashboard';
  return null;
},

### Token Refresh
Always implement automatic token refresh using a Dio interceptor.
Always retry the original request after a successful token refresh.
Always redirect to login if the refresh token is expired or invalid.

Dio interceptor pattern:
class AuthInterceptor extends Interceptor {
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry original request
        return handler.resolve(await _retry(err.requestOptions));
      }
      // Redirect to login
      ref.read(authNotifierProvider.notifier).logout();
    }
    return handler.next(err);
  }
}

## Security Rules (All Platforms)
Always enforce strong password requirements:
- Minimum 8 characters
- At least one uppercase, one lowercase, one number
- At least one special character

Always implement rate limiting on auth endpoints:
- Login: 10 attempts per minute per IP
- Register: 5 attempts per minute per IP
- Password reset: 3 attempts per minute per IP

Always lock accounts after 10 consecutive failed login attempts.
Always send email notifications for:
- New login from unrecognized device
- Password change
- Email change

Never reveal whether an email exists during login or password reset flows.
Always use timing-safe comparison for token validation.
