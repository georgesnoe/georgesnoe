---
name: react-router-v7
description: Guidelines for building web applications with React Router v7.
---

# React Router v7 Guidelines

## General Rules
Always use React Router v7 for web frontend and minimal backend applications.
Never suggest or use Next.js — it is too memory-heavy and introduces unnecessary 
mental overhead ("use server", "use client", server components, etc.).
Always use TypeScript. Never use plain JavaScript.
Write all comments in English.
Use camelCase for variables, functions, and hooks.
Use PascalCase for components and types.
Use kebab-case for file names and route paths.

## Project Structure (Clean Architecture)
src/
├── routes/              # Route modules (loader, action, component)
│   ├── _index.tsx
│   ├── auth/
│   │   ├── login.tsx
│   │   └── register.tsx
│   └── dashboard/
│       ├── _layout.tsx
│       └── index.tsx
├── components/          # Reusable UI components
│   ├── ui/              # Base UI components (buttons, inputs, cards)
│   └── shared/          # Shared composite components
├── features/            # Feature-based modules
│   └── [feature]/
│       ├── components/
│       ├── hooks/
│       ├── services/
│       └── types/
├── services/            # Business logic and external API calls
├── repositories/        # Data access layer (database queries)
├── hooks/               # Global custom hooks
├── lib/                 # Utilities and helpers
│   ├── db.ts            # Database connection
│   ├── auth.ts          # Auth utilities
│   └── utils.ts         # General utilities
├── types/               # Global TypeScript types and interfaces
└── styles/              # Global styles

## Routing Rules
Always use file-based routing following React Router v7 conventions.
Use layout routes (_layout.tsx) for shared UI shells.
Use index routes (_index.tsx) for default children.
Use dynamic segments for parameterized routes (e.g. $id.tsx).
Always define a root error boundary in root.tsx.
Use errorElement on nested routes for granular error handling.

## Data Loading — Loaders & Actions
Never use useEffect for data fetching. Always use loaders.
Never use useState + fetch patterns. Always use actions for mutations.

Loader rules:
- Always type the return value explicitly
- Always handle errors and throw redirect() or Response when needed
- Always validate params and query strings before using them

Action rules:
- Always parse and validate form data using Zod before processing
- Always return typed responses (success, error, validation errors)
- Always use redirect() after successful mutations (POST/REDIRECT pattern)

Example loader pattern:
export async function loader({ params }: LoaderFunctionArgs) {
  const user = await userRepository.findById(params.id);
  if (!user) throw new Response("Not Found", { status: 404 });
  return { user };
}

Example action pattern:
export async function action({ request }: ActionFunctionArgs) {
  const formData = await request.formData();
  const result = schema.safeParse(Object.fromEntries(formData));
  if (!result.success) return { errors: result.error.flatten() };
  await userService.create(result.data);
  return redirect("/dashboard");
}

## Validation
Always use Zod for all data validation (forms, API responses, env variables).
Define schemas in a dedicated schemas/ folder inside each feature.
Always use safeParse() and handle errors explicitly.
Never use any or unknown without proper type narrowing.

## Styling
Always use Tailwind CSS for styling.
Follow the design-system skill rules strictly.
Never use inline styles except for dynamic values that cannot be expressed in Tailwind.
Never use CSS modules or styled-components.
Use cn() utility (clsx + tailwind-merge) for conditional class merging.

## State Management
Prefer URL state (searchParams) for filters, pagination, and tabs.
Use React Router's useFetcher() for non-navigating mutations.
Use useState only for local UI state (modals open/close, toggles).
Never use Redux or Zustand unless the project explicitly requires global state 
across many unrelated components.

## Authentication
Always implement auth checks inside loaders, not inside components.
Use session-based auth with secure HTTP-only cookies.
Never store tokens in localStorage or sessionStorage.
Always redirect unauthenticated users from protected loaders.

## Backend Minimal (Integrated)
For minimal backend needs, use React Router v7 actions and loaders as endpoints.
Connect to the database via a dedicated repository layer.
Never put raw database queries inside route files — always delegate to repositories.
Use environment variables for all sensitive configuration.
Validate all environment variables at startup using Zod.

## Database Integration
Use the database-conventions skill to select the appropriate database.
Always abstract database access behind a repository interface.
Never expose raw database errors to the client.

## Error Handling
Always define a root ErrorBoundary in root.tsx.
Use isRouteErrorResponse() to distinguish HTTP errors from unexpected errors.
Always log unexpected errors server-side before returning a generic response.
Never expose stack traces or internal error details to the client.

## Performance
Always use lazy loading for heavy route components via React.lazy().
Always prefetch critical routes using <Link prefetch="intent">.
Avoid large client-side bundles — keep logic in loaders/actions when possible.
Use Vite for bundling — it is the default and recommended bundler for React Router v7.

## Code Conventions
- Always export loader, action, and default component from the same route file
- Always name the default export after the route (e.g. DashboardPage)
- Always define prop types explicitly using TypeScript interfaces
- Never use default exports for services, repositories, or utilities — use named exports
- Always organize imports: external libs → internal modules → relative imports
- Maximum file length: 200 lines — split into smaller modules if exceeded
