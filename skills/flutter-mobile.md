---
name: flutter-mobile
description: Guidelines for building mobile applications with Flutter.
---

# Flutter Mobile Guidelines

## General Rules
Always use Flutter for mobile development (iOS and Android).
Always use Dart — never mix with other languages except for platform-specific code.
Always use TypeScript-equivalent strictness in Dart: enable strict mode in analysis_options.yaml.
Write all comments in English.
Use camelCase for variables, functions, and parameters.
Use PascalCase for classes, enums, and types.
Use snake_case for file names and folder names.
Never use Material Design standard widgets as-is — always customize to match the design system.

## Project Structure (Clean Architecture)
lib/
├── main.dart
├── app/
│   ├── app.dart               # Root widget and providers
│   ├── router.dart            # GoRouter configuration
│   └── theme/                 # App theme and design tokens
│       ├── app_theme.dart
│       ├── app_colors.dart
│       ├── app_typography.dart
│       └── app_spacing.dart
├── features/
│   └── [feature]/
│       ├── presentation/
│       │   ├── screens/
│       │   ├── widgets/
│       │   └── providers/     # Riverpod providers for this feature
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/  # Abstract interfaces
│       │   └── usecases/
│       └── data/
│           ├── models/        # DTOs with fromJson/toJson
│           ├── repositories/  # Concrete implementations
│           └── datasources/   # Remote and local data sources
├── core/
│   ├── error/                 # Failures and exceptions
│   ├── network/               # Dio client and interceptors
│   ├── storage/               # Local storage (Hive, SharedPreferences)
│   ├── utils/                 # Global utilities and helpers
│   └── widgets/               # Shared reusable widgets
└── generated/                 # Generated files (assets, translations)

## State Management — Riverpod
Always use Riverpod for state management. Never use Provider, Bloc, or GetX.
Always use code generation with riverpod_generator (@riverpod annotation).
Always use AsyncNotifier for async state and Notifier for sync state.
Never use StateProvider or StateNotifierProvider — they are deprecated patterns.

Provider rules:
- Define providers close to their feature (inside features/[feature]/presentation/providers/)
- Always handle loading, error, and data states explicitly
- Always use ref.watch() in build methods and ref.read() in callbacks
- Never call ref.watch() inside callbacks or async functions
- Use family modifier for parameterized providers

Example provider pattern:
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<User> build(String userId) async {
    return ref.watch(userRepositoryProvider).findById(userId);
  }

  Future<void> updateProfile(UpdateProfileParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(userRepositoryProvider).updateProfile(params),
    );
  }
}

## Navigation — GoRouter
Always use GoRouter for navigation. Never use Navigator.push() directly.
Define all routes in app/router.dart.
Use named routes for all navigation calls.
Use ShellRoute for bottom navigation bar layouts.
Use redirect for auth guards — never guard inside screens.
Always handle 404 with an errorBuilder.

Route naming convention:
- Use kebab-case for route paths (e.g. /user-profile/:id)
- Use camelCase for route names (e.g. userProfile)

## Design System Integration
Always apply the design-system skill rules in Flutter.
Never use hardcoded colors, font sizes, or spacing values.
Always reference design tokens defined in app/theme/.

### Typography
Always use Plus Jakarta Sans as the default font.
Import via google_fonts package:
GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w400)

Define a complete TextTheme in app_typography.dart covering:
- displayLarge, displayMedium, displaySmall
- headlineLarge, headlineMedium, headlineSmall
- titleLarge, titleMedium, titleSmall
- bodyLarge, bodyMedium, bodySmall
- labelLarge, labelMedium, labelSmall

### Colors
Define all colors as static constants in app_colors.dart.
Never use Flutter's Colors.blue or any predefined Material colors directly.
Always define light and dark variants for every color token.

### Spacing — 4px Rule
All spacing must be multiples of 4px.
Define spacing constants in app_spacing.dart:
- AppSpacing.xs = 4.0
- AppSpacing.sm = 8.0
- AppSpacing.mdSm = 12.0
- AppSpacing.md = 16.0
- AppSpacing.lg = 24.0
- AppSpacing.xl = 32.0
- AppSpacing.xxl = 48.0
- AppSpacing.xxxl = 64.0

Never use arbitrary spacing values like 5, 7, 13, or 22.

### Border Radius
- Small elements (badges, chips): 4px
- Buttons and inputs: 6px
- Cards and containers: 8px
- Bottom sheets and modals: 12px
- Avatars: circular (999px)

Never use fully rounded buttons (stadium shape) unless explicitly requested.

### Icons
Use icons consistent with Tabler Icons style — prefer flutter_tabler_icons package.
Default icon size: 20px (inline) / 24px (standalone).
Never mix icon libraries in the same project.

## Network Layer — Dio
Always use Dio for HTTP calls. Never use http package.
Configure a single Dio instance in core/network/ with:
- BaseOptions (baseUrl, connectTimeout, receiveTimeout)
- AuthInterceptor for token injection
- ErrorInterceptor for global error handling
- LogInterceptor for debug logging (disable in production)

Always abstract Dio calls behind a datasource class.
Never call Dio directly from repositories or use cases.
Always map HTTP errors to domain Failures before returning to the domain layer.

## Error Handling
Use Either<Failure, T> pattern from dartz package for all repository return types.
Define domain-specific Failure classes in core/error/failures.dart.
Never throw exceptions from repositories — always return Left(Failure).
Always handle all failure cases in the presentation layer.

## Local Storage
Use Hive for structured local data (user session, cached entities).
Use SharedPreferences for simple key-value storage (settings, flags).
Always abstract local storage behind a datasource interface.
Never access Hive or SharedPreferences directly from repositories.

## Performance
Always use const constructors wherever possible.
Always use ListView.builder() for long lists — never ListView() with children.
Always dispose controllers, animation controllers, and subscriptions properly.
Use RepaintBoundary for complex custom painted widgets.
Avoid rebuilding large widget trees — use Consumer or select() to narrow rebuilds.

## Testing
Write unit tests for all use cases and repositories.
Write widget tests for critical UI components.
Use mocktail for mocking dependencies.
Organize tests mirroring the lib/ folder structure under test/.

## Code Conventions
- Maximum file length: 200 lines — split into smaller widgets or classes if exceeded
- Always extract widgets into separate files when they exceed 50 lines
- Always define explicit return types for all functions
- Never use dynamic type — always define proper Dart types
- Always organize imports: Flutter → Dart → external packages → internal modules
- Always run flutter analyze and fix all warnings before considering code complete
