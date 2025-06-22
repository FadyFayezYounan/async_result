# AsyncResult

A type-safe state management solution for handling asynchronous operations in Flutter applications with Bloc. AsyncResult provides four clear states: **initial**, **loading**, **success**, and **error** - perfect for managing UI states in reactive applications.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start with Bloc](#quick-start-with-bloc)
- [Core Methods (Most Important)](#core-methods-most-important)
- [State Checking Properties](#state-checking-properties)
- [Data Transformation Methods](#data-transformation-methods)
- [Error Handling Methods](#error-handling-methods)
- [Advanced Methods](#advanced-methods)
- [Best Practices](#best-practices)
- [API Reference](#api-reference)

## Features

- ✅ **Perfect for Bloc**: Designed specifically for reactive state management
- ✅ **Four clear states**: Initial, Loading, Data (Success), Error  
- ✅ **Type-safe**: Compile-time guarantees prevent runtime errors
- ✅ **Pattern matching**: Handle all states with `when()` method
- ✅ **UI-friendly**: Direct mapping to Flutter widget states
- ✅ **Functional utilities**: Transform data with `map()`, handle errors with `recover()`

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  async_result: ^1.1.2
```

## Quick Start with Bloc

Here's a complete example showing AsyncResult with Bloc:

```dart
import 'package:async_result/async_result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 1. Define your state type
typedef UserState = AsyncResult<User, String>;

// 2. Create your Cubit  
class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const AsyncResult.initial());

  Future<void> loadUser(String id) async {
    emit(const AsyncResult.loading());
    
    try {
      final user = await _repository.fetchUser(id);
      emit(AsyncResult.data(user));
    } catch (e) {
      emit(AsyncResult.error('Failed to load user: $e'));
    }
  }
}

// 3. Use in your UI
class UserWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return state.when(
          initial: () => Text('Press button to load user'),
          loading: () => CircularProgressIndicator(),
          data: (user) => Text('Hello, ${user.name}!'),
          error: (error) => Text('Error: $error'),
        );
      },
    );
  }
}
```

## Core Methods (Most Important)

These are the methods you'll use most frequently when working with AsyncResult in Bloc applications.

### 1. `when()` - Handle All States ⭐⭐⭐⭐⭐

**Most important method** - handles all possible states with required callbacks.

```dart
// In your Bloc Builder
BlocBuilder<UserCubit, UserState>(
  builder: (context, state) {
    return state.when(
      initial: () => ElevatedButton(
        onPressed: () => context.read<UserCubit>().loadUser('123'),
        child: Text('Load User'),
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      data: (user) => Column(
        children: [
          Text('Name: ${user.name}'),
          Text('Email: ${user.email}'),
        ],
      ),
      error: (error) => Column(
        children: [
          Text('Error: $error', style: TextStyle(color: Colors.red)),
          ElevatedButton(
            onPressed: () => context.read<UserCubit>().loadUser('123'),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  },
)
```

### 2. State Constructors ⭐⭐⭐⭐⭐

Create AsyncResult instances in your Cubit methods:

```dart
class PostsCubit extends Cubit<AsyncResult<List<Post>, String>> {
  PostsCubit() : super(const AsyncResult.initial()); // Start in initial state

  Future<void> loadPosts() async {
    emit(const AsyncResult.loading()); // Show loading
    
    try {
      final posts = await _repository.fetchPosts();
      emit(AsyncResult.data(posts)); // Success with data
    } catch (e) {
      emit(AsyncResult.error('Failed to load posts')); // Error state
    }
  }
  
  void reset() {
    emit(const AsyncResult.initial()); // Reset to initial
  }
}
```

### 3. `maybeWhen()` - Handle Specific States ⭐⭐⭐⭐

Handle only the states you care about:

```dart
// Show loading indicator only when loading, otherwise show nothing
Widget loadingIndicator = state.maybeWhen(
  loading: () => LinearProgressIndicator(),
  orElse: () => SizedBox.shrink(),
);

// Show data count if available
Widget dataInfo = state.maybeWhen(
  data: (posts) => Text('${posts.length} posts loaded'),
  orElse: () => Text('No data'),
);

// Complete widget with multiple maybeWhen calls
Column(
  children: [
    loadingIndicator,
    dataInfo,
    // Other widgets...
  ],
)
```

## State Checking Properties

Quick boolean checks for state types:

### Basic State Checks ⭐⭐⭐⭐

```dart
class PostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostsCubit, AsyncResult<List<Post>, String>>(
      builder: (context, state) {
        // Show floating action button only when not loading
        return Scaffold(
          body: _buildBody(state),
          floatingActionButton: state.isLoading 
            ? null 
            : FloatingActionButton(
                onPressed: () => context.read<PostsCubit>().loadPosts(),
                child: Icon(Icons.refresh),
              ),
        );
      },
    );
  }
  
  Widget _buildBody(AsyncResult<List<Post>, String> state) {
    if (state.hasData) {
      final posts = state.dataOrNull!;
      return ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) => PostCard(posts[index]),
      );
    }
    
    if (state.hasError) {
      return ErrorWidget(state.errorOrNull!);
    }
    
    return Center(child: Text('Ready to load posts'));
  }
}
```

### Safe Data Access ⭐⭐⭐

```dart
// Safe access - returns null if no data
final userData = state.dataOrNull;
if (userData != null) {
  return UserProfile(userData);
}

// Safe access with default
final userCount = state.dataOrNull?.length ?? 0;

// Unsafe access - throws if no data (use only when you're sure)
if (state.hasData) {
  final userData = state.dataOrThrow; // Safe here because we checked
  return UserProfile(userData);
}
```

## Data Transformation Methods

Transform successful data while preserving state information.

### 1. `map()` - Transform Success Data ⭐⭐⭐⭐

Transform the data when the operation succeeds:

```dart
class UserCubit extends Cubit<AsyncResult<User, String>> {
  // ...existing code...

  // Transform user data to display format
  AsyncResult<String, String> getUserDisplayName() {
    return state.map((user) => '${user.firstName} ${user.lastName}');
  }
  
  // Use in another Cubit or method
  void updateDisplayName() {
    final displayNameResult = getUserDisplayName();
    
    displayNameResult.when(
      initial: () => print('No user loaded'),
      loading: () => print('User loading...'),
      data: (displayName) => print('Display name: $displayName'),
      error: (error) => print('Error: $error'),
    );
  }
}

// In your widget
BlocBuilder<UserCubit, AsyncResult<User, String>>(
  builder: (context, state) {
    // Transform data directly in UI
    final greetingState = state.map((user) => 'Hello, ${user.name}!');
    
    return greetingState.when(
      initial: () => Text('Welcome! Please log in.'),
      loading: () => Text('Loading user...'),
      data: (greeting) => Text(greeting, style: TextStyle(fontSize: 24)),
      error: (error) => Text('Failed to load user'),
    );
  },
)
```

### 2. `flatMap()` - Chain Async Operations ⭐⭐⭐

Chain operations that return AsyncResult:

```dart
class UserCubit extends Cubit<AsyncResult<UserProfile, String>> {
  UserCubit() : super(const AsyncResult.initial());

  Future<void> loadUserProfile(String userId) async {
    emit(const AsyncResult.loading());
    
    try {
      // First operation: load user
      final userResult = await _loadUser(userId);
      
      // Chain second operation: load user's posts
      final profileResult = await userResult.flatMap((user) async {
        final postsResult = await _loadUserPosts(user.id);
        return postsResult.map((posts) => UserProfile(user, posts));
      });
      
      emit(profileResult);
    } catch (e) {
      emit(AsyncResult.error('Failed to load profile'));
    }
  }
  
  Future<AsyncResult<User, String>> _loadUser(String id) async {
    try {
      final user = await repository.fetchUser(id);
      return AsyncResult.data(user);
    } catch (e) {
      return AsyncResult.error('User not found');
    }
  }
  
  Future<AsyncResult<List<Post>, String>> _loadUserPosts(String userId) async {
    try {
      final posts = await repository.fetchUserPosts(userId);
      return AsyncResult.data(posts);
    } catch (e) {
      return AsyncResult.error('Posts not found');
    }
  }
}
```

## Error Handling Methods

Handle and transform errors gracefully.

### 1. `recover()` - Provide Fallback Data ⭐⭐⭐⭐

Convert errors to success states with fallback data:

```dart
class PostsCubit extends Cubit<AsyncResult<List<Post>, String>> {
  PostsCubit() : super(const AsyncResult.initial());

  Future<void> loadPosts() async {
    emit(const AsyncResult.loading());
    
    try {
      final posts = await repository.fetchPosts();
      emit(AsyncResult.data(posts));
    } catch (e) {
      // Instead of emitting error, recover with cached data
      final cachedPosts = await _getCachedPosts();
      final recoveredResult = AsyncResult<List<Post>, String>
          .error('Network failed')
          .recover((error) => cachedPosts);
      
      emit(recoveredResult);
    }
  }
  
  // Recover from errors in UI layer
  Widget buildPostsList(AsyncResult<List<Post>, String> state) {
    final safeState = state.recover((error) => <Post>[]);
    
    return safeState.when(
      initial: () => Text('Press refresh to load posts'),
      loading: () => CircularProgressIndicator(),
      data: (posts) => posts.isEmpty
          ? Text('No posts available')
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) => PostCard(posts[index]),
            ),
      error: (error) => Text('This should never show due to recover()'),
    );
  }
}
```

### 2. `mapError()` - Transform Error Messages ⭐⭐⭐

Make error messages more user-friendly:

```dart
class AuthCubit extends Cubit<AsyncResult<User, String>> {
  AuthCubit() : super(const AsyncResult.initial());

  Future<void> login(String email, String password) async {
    emit(const AsyncResult.loading());
    
    try {
      final user = await authService.login(email, password);
      emit(AsyncResult.data(user));
    } catch (e) {
      // Transform technical errors to user-friendly messages
      final errorResult = AsyncResult<User, String>
          .error(e.toString())
          .mapError(_mapToUserFriendlyError);
      
      emit(errorResult);
    }
  }
  
  String _mapToUserFriendlyError(String technicalError) {
    if (technicalError.contains('network')) {
      return 'Please check your internet connection';
    } else if (technicalError.contains('401')) {
      return 'Invalid email or password';
    } else if (technicalError.contains('timeout')) {
      return 'Request timed out. Please try again';
    } else {
      return 'Something went wrong. Please try again later';
    }
  }
}

// In your widget
BlocBuilder<AuthCubit, AsyncResult<User, String>>(
  builder: (context, state) {
    return state.when(
      initial: () => LoginForm(),
      loading: () => CircularProgressIndicator(),
      data: (user) => HomePage(user),
      error: (friendlyError) => Column(
        children: [
          Text(friendlyError, style: TextStyle(color: Colors.red)),
          ElevatedButton(
            onPressed: () => _showLoginDialog(context),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  },
)
```

## Advanced Methods

Less frequently used but powerful methods for specific scenarios.

### 1. `bimap()` - Transform Both Data and Error ⭐⭐

Transform both success and error cases:

```dart
class SettingsCubit extends Cubit<AsyncResult<AppSettings, AppError>> {
  // Transform both success data and errors to different types
  AsyncResult<SettingsViewModel, String> getSettingsViewModel() {
    return state.bimap(
      data: (settings) => SettingsViewModel(
        darkMode: settings.darkMode,
        notifications: settings.notifications,
        displayName: '${settings.user.name} Settings',
      ),
      error: (appError) => 'Settings error: ${appError.message}',
    );
  }
}
```

### 2. `validate()` - Add Data Validation ⭐⭐

Validate success data and convert to error if invalid:

```dart
class FormCubit extends Cubit<AsyncResult<FormData, String>> {
  void submitForm(String email, int age) {
    emit(const AsyncResult.loading());
    
    final formData = FormData(email: email, age: age);
    final validatedResult = AsyncResult.data(formData)
        .validate(
          (data) => data.email.contains('@') && data.age >= 18,
          (data) => 'Invalid form: Email must contain @ and age must be 18+',
        );
    
    emit(validatedResult);
  }
}
```

### 3. `swap()` - Swap Success and Error ⭐

Invert success and error states:

```dart
// Useful when you want to treat success as an error condition
final result = AsyncResult<String, String>.data('success');
final swapped = result.swap(); // Now 'success' is in error state

swapped.when(
  initial: () => print('Initial'),
  loading: () => print('Loading'),
  data: (data) => print('This was originally an error: $data'),
  error: (error) => print('This was originally success: $error'),
);
```

### 4. State Transformation Utilities ⭐

```dart
// whenOrNull - returns null for unhandled states
final result = state.whenOrNull(
  data: (posts) => posts.length,
  // Returns null for initial, loading, and error states
);

// Individual state handlers
final dataWidget = state.whenData((posts) => PostsList(posts));
final errorWidget = state.whenError((error) => ErrorMessage(error));
final loadingWidget = state.whenLoading(() => CircularProgressIndicator());
```

## Best Practices

### 1. Start with Initial State

```dart
// ✅ Good: Always start with initial
class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const AsyncResult.initial());
}

// ❌ Avoid: Starting with loading or other states
class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const AsyncResult.loading()); // Confusing UX
}
```

### 2. Emit Loading Before Async Operations

```dart
// ✅ Good: Clear state transitions
Future<void> loadUser() async {
  emit(const AsyncResult.loading()); // User sees loading immediately
  
  try {
    final user = await repository.fetchUser();
    emit(AsyncResult.data(user));
  } catch (e) {
    emit(AsyncResult.error("Failed to load user"));
  }
}

// ❌ Avoid: Not showing loading state
Future<void> loadUser() async {
  try {
    final user = await repository.fetchUser(); // User doesn't know what's happening
    emit(AsyncResult.data(user));
  } catch (e) {
    emit(AsyncResult.error("Failed to load user"));
  }
}
```

### 3. Use Type Aliases for Complex States

```dart
// ✅ Good: Clear and reusable
typedef UserProfileState = AsyncResult<UserProfile, String>;
typedef PostsState = AsyncResult<List<Post>, AppError>;

class UserProfileCubit extends Cubit<UserProfileState> {
  // Implementation
}

// ❌ Avoid: Repeating complex types
class UserProfileCubit extends Cubit<AsyncResult<UserProfile, String>> {
  // Implementation
}
```

## API Reference

### Core Factory Constructors

| Constructor | Description | Parameters | Returns | Example |
|-------------|-------------|------------|---------|---------|
| `AsyncResult.initial()` | Creates an AsyncResult in the initial state | None | `AsyncResult<T, E>` | `AsyncResult<String, Exception>.initial()` |
| `AsyncResult.loading()` | Creates an AsyncResult in the loading state | None | `AsyncResult<T, E>` | `AsyncResult<String, Exception>.loading()` |
| `AsyncResult.data(T data)` | Creates an AsyncResult in the success state | `data: T` - The successful result data | `AsyncResult<T, E>` | `AsyncResult<String, Exception>.data('Hello')` |
| `AsyncResult.error(E error)` | Creates an AsyncResult in the error state | `error: E` - The error that occurred | `AsyncResult<T, E>` | `AsyncResult<String, Exception>.error(Exception('Failed'))` |

### State Properties Reference

| Property | Description | Returns | Example |
|----------|-------------|---------|---------|
| `isInitial` | Returns true if in initial state | `bool` | `result.isInitial` |
| `isLoading` | Returns true if in loading state | `bool` | `result.isLoading` |
| `isSuccess` | Returns true if in success state | `bool` | `result.isSuccess` |
| `isError` | Returns true if in error state | `bool` | `result.isError` |
| `hasData` | Alias for isSuccess | `bool` | `result.hasData` |
| `hasError` | Alias for isError | `bool` | `result.hasError` |
| `isLoadingOrInitial` | Returns true if loading or initial | `bool` | `result.isLoadingOrInitial` |
| `isDataOrError` | Returns true if has data or error | `bool` | `result.isDataOrError` |
| `isCompleted` | Returns true if completed (success or error) | `bool` | `result.isCompleted` |

### Data Access Methods

| Method | Description | Parameters | Returns | Throws | Example |
|--------|-------------|------------|---------|--------|---------|
| `dataOrNull` | Returns data if successful, null otherwise | None | `T?` | None | `result.dataOrNull` |
| `dataOrThrow` | Returns data if successful, throws otherwise | None | `T` | `AsyncResultDataNotFoundException` | `result.dataOrThrow` |
| `errorOrNull` | Returns error if present, null otherwise | None | `E?` | None | `result.errorOrNull` |
| `errorOrThrow` | Returns error if present, throws otherwise | None | `E` | `AsyncResultErrorNotFoundException` | `result.errorOrThrow` |
| `getDataOrElse(T defaultValue)` | Returns data or default value | `defaultValue: T` | `T` | None | `result.getDataOrElse('default')` |
| `getErrorOrElse(E defaultValue)` | Returns error or default value | `defaultValue: E` | `E` | None | `result.getErrorOrElse('no error')` |

### Pattern Matching Methods

| Method | Description | Parameters | Returns | Example |
|--------|-------------|------------|---------|---------|
| `when<R>()` | Handle all states with required callbacks | `initial: R Function()`, `loading: R Function()`, `data: R Function(T)`, `error: R Function(E)` | `R` | `result.when(initial: () => 'init', ...)` |
| `maybeWhen<R>()` | Handle specific states with fallback | `initial?: R Function()`, `loading?: R Function()`, `data?: R Function(T)`, `error?: R Function(E)`, `orElse: R Function()` | `R` | `result.maybeWhen(data: (x) => x, orElse: () => 0)` |
| `whenOrNull<R>()` | Handle specific states, return null for others | `initial?: R Function()`, `loading?: R Function()`, `data?: R Function(T)`, `error?: R Function(E)` | `R?` | `result.whenOrNull(data: (x) => x)` |
| `whenInitial<R>(R Function())` | Handle only initial state | `whenInitial: R Function()` | `R?` | `result.whenInitial(() => 'initial')` |
| `whenLoading<R>(R Function())` | Handle only loading state | `whenLoading: R Function()` | `R?` | `result.whenLoading(() => 'loading')` |
| `whenData<R>(R Function(T))` | Handle only success state | `whenData: R Function(T)` | `R?` | `result.whenData((data) => data)` |
| `whenError<R>(R Function(E))` | Handle only error state | `whenError: R Function(E)` | `R?` | `result.whenError((err) => err)` |

### Transformation Methods

| Method | Description | Parameters | Returns | Example |
|--------|-------------|------------|---------|---------|
| `map<R>(R Function(T))` | Transform data if successful | `mapper: R Function(T)` | `AsyncResult<R, E>` | `result.map((x) => x * 2)` |
| `mapError<F>(F Function(E))` | Transform error if present | `mapper: F Function(E)` | `AsyncResult<T, F>` | `result.mapError((e) => 'Error: $e')` |
| `bimap<R, F>()` | Transform both data and error | `data: R Function(T)`, `error: F Function(E)` | `AsyncResult<R, F>` | `result.bimap(data: (x) => x.toString(), error: (e) => e.length)` |
| `flatMap<R>(AsyncResult<R, E> Function(T))` | Chain AsyncResult operations | `mapper: AsyncResult<R, E> Function(T)` | `AsyncResult<R, E>` | `result.flatMap((x) => AsyncResult.data(x * 2))` |
| `recover(T Function(E))` | Convert error to success | `recovery: T Function(E)` | `AsyncResult<T, E>` | `result.recover((err) => -1)` |
| `swap()` | Swap success and error types | None | `AsyncResult<E, T>` | `result.swap()` |

### Conditional Transformation Methods

| Method | Description | Parameters | Returns | Example |
|--------|-------------|------------|---------|---------|
| `mapWhere()` | Transform data conditionally | `test: bool Function(T)`, `mapper: T Function(T)` | `AsyncResult<T, E>` | `result.mapWhere((x) => x > 0, (x) => x * 2)` |
| `mapErrorWhere()` | Transform error conditionally | `test: bool Function(E)`, `mapper: E Function(E)` | `AsyncResult<T, E>` | `result.mapErrorWhere((e) => e.startsWith('net'), (e) => 'Network Error')` |
| `validate()` | Validate data, convert to error if invalid | `predicate: bool Function(T)`, `errorBuilder: E Function(T)` | `AsyncResult<T, E>` | `result.validate((x) => x >= 0, (x) => 'Negative: $x')` |
| `filter()` | Filter data, convert to error if fails | `predicate: bool Function(T)`, `errorBuilder: E Function()` | `AsyncResult<T, E>` | `result.filter((x) => x > 0, () => 'Not positive')` |

### Testing and Utilities

| Method | Description | Parameters | Returns | Example |
|--------|-------------|------------|---------|---------|
| `any(bool Function(T))` | Test if data satisfies predicate | `predicate: bool Function(T)` | `bool` | `result.any((x) => x > 10)` |
| `tap()` | Execute side effects without changing result | `onData?: void Function(T)`, `onError?: void Function(E)`, `onLoading?: void Function()`, `onInitial?: void Function()` | `AsyncResult<T, E>` | `result.tap(onData: (x) => print(x))` |

### Static Collection Methods

| Method | Description | Parameters | Returns | Example |
|--------|-------------|------------|---------|---------|
| `allComplete<T, E>(Iterable<AsyncResult<T, E>>)` | Check if all results are completed | `iterable: Iterable<AsyncResult<T, E>>` | `bool` | `AsyncResult.allComplete(results)` |
| `allSuccess<T, E>(Iterable<AsyncResult<T, E>>)` | Check if all results are successful | `iterable: Iterable<AsyncResult<T, E>>` | `bool` | `AsyncResult.allSuccess(results)` |
| `allError<T, E>(Iterable<AsyncResult<T, E>>)` | Check if all results are errors | `iterable: Iterable<AsyncResult<T, E>>` | `bool` | `AsyncResult.allError(results)` |
| `anyError<T, E>(Iterable<AsyncResult<T, E>>)` | Check if any result is error | `iterable: Iterable<AsyncResult<T, E>>` | `bool` | `AsyncResult.anyError(results)` |
| `anyLoading<T, E>(Iterable<AsyncResult<T, E>>)` | Check if any result is loading | `iterable: Iterable<AsyncResult<T, E>>` | `bool` | `AsyncResult.anyLoading(results)` |
| `anyComplete<T, E>(Iterable<AsyncResult<T, E>>)` | Check if any result is completed | `iterable: Iterable<AsyncResult<T, E>>` | `bool` | `AsyncResult.anyComplete(results)` |
| `anySuccess<T, E>(Iterable<AsyncResult<T, E>>)` | Check if any result is successful | `iterable: Iterable<AsyncResult<T, E>>` | `bool` | `AsyncResult.anySuccess(results)` |

### Static Data Extraction Methods

| Method | Description | Parameters | Returns | Example |
|--------|-------------|------------|---------|---------|
| `getAllData<T, E>(Iterable<AsyncResult<T, E>>)` | Extract all successful data values | `iterable: Iterable<AsyncResult<T, E>>` | `Iterable<T>` | `AsyncResult.getAllData(results).toList()` |
| `getAllError<T, E>(Iterable<AsyncResult<T, E>>)` | Extract all error values | `iterable: Iterable<AsyncResult<T, E>>` | `Iterable<E>` | `AsyncResult.getAllError(results).toList()` |
| `getFirstError<T, E>(Iterable<AsyncResult<T, E>>)` | Get first error or null | `iterable: Iterable<AsyncResult<T, E>>` | `E?` | `AsyncResult.getFirstError(results)` |
| `getFirstData<T, E>(Iterable<AsyncResult<T, E>>)` | Get first data or null | `iterable: Iterable<AsyncResult<T, E>>` | `T?` | `AsyncResult.getFirstData(results)` |

### Static Combination Methods

| Method | Description | Parameters | Returns | Example |
|--------|-------------|------------|---------|---------|
| `combine2<T, U, E>()` | Combine two AsyncResults into record | `result1: AsyncResult<T, E>`, `result2: AsyncResult<U, E>` | `AsyncResult<({T first, U second}), E>` | `AsyncResult.combine2(result1, result2)` |
| `combine3<T, U, V, E>()` | Combine three AsyncResults into record | `result1: AsyncResult<T, E>`, `result2: AsyncResult<U, E>`, `result3: AsyncResult<V, E>` | `AsyncResult<({T first, U second, V third}), E>` | `AsyncResult.combine3(r1, r2, r3)` |
| `combine4<T, U, V, W, E>()` | Combine four AsyncResults into record | Four AsyncResult parameters | `AsyncResult<({T first, U second, V third, W fourth}), E>` | `AsyncResult.combine4(r1, r2, r3, r4)` |
| `combine5<T, U, V, W, X, E>()` | Combine five AsyncResults into record | Five AsyncResult parameters | `AsyncResult<({T first, U second, V third, W fourth, X fifth}), E>` | `AsyncResult.combine5(r1, r2, r3, r4, r5)` |
| `combineIterable<E>(Iterable<AsyncResult<dynamic, E>>)` | Combine iterable of AsyncResults into list | `results: Iterable<AsyncResult<dynamic, E>>` | `AsyncResult<List<dynamic>, E>` | `AsyncResult.combineIterable(results)` |

### Usage Examples

```dart
// Basic state creation in Cubit
class UserCubit extends Cubit<AsyncResult<User, String>> {
  UserCubit() : super(const AsyncResult.initial());

  Future<void> loadUser() async {
    emit(const AsyncResult.loading());
    
    try {
      final user = await repository.fetchUser();
      emit(AsyncResult.data(user));
    } catch (e) {
      emit(AsyncResult.error('Failed to load user'));
    }
  }
}

// UI handling with pattern matching
BlocBuilder<UserCubit, AsyncResult<User, String>>(
  builder: (context, state) {
    return state.when(
      initial: () => Text('Press button to start'),
      loading: () => CircularProgressIndicator(),
      data: (user) => Text('Hello, ${user.name}!'),
      error: (error) => Text('Error: $error'),
    );
  },
)

// Data transformation
final greetingState = userState.map((user) => 'Hello, ${user.name}!');

// Error recovery
final safeState = userState.recover((error) => User.guest());

// Chaining operations
final profileState = userState.flatMap((user) => loadUserProfile(user.id));
```

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
