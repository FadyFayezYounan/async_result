# AsyncResult

A powerful and type-safe way to handle different states of asynchronous operations in Dart and Flutter applications, specifically designed for seamless integration with the Bloc package. AsyncResult helps you manage the common states of async operations: initial, loading, data (success), and error states in your BLoC architecture.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Overview](#overview)
- [States](#states)
- [Basic Usage](#basic-usage)
- [Integration with Bloc/Cubit](#integration-with-bloccubit)
  - [Simple Example](#simple-example)
  - [Advanced Bloc Integration](#advanced-bloc-integration)
  - [Using in UI](#using-in-ui)
- [Advanced Usage](#advanced-usage)
  - [Transforming Data](#transforming-data)
  - [Error Handling](#error-handling)
  - [Chaining Operations](#chaining-operations)
  - [Recovery from Errors](#recovery-from-errors)
- [Best Practices](#best-practices)
- [API Reference](#api-reference)
- [Review and Recommendations](#review-and-recommendations)
- [Contributing](#contributing)

## Features

- 🎯 **Type-safe state handling** - Eliminates runtime errors with compile-time guarantees
- 🔄 **Comprehensive state management** - Four distinct states for complete async operation coverage
- 🛠️ **Rich functional programming utilities** - Map, flatMap, recover, and more
- 🧩 **Seamless Bloc/Cubit integration** - Built specifically for the Bloc pattern
- ⚡ **Efficient pattern matching** - Elegant state handling with when() methods
- 🔍 **Built-in error handling** - Robust error management and recovery
- 📱 **Flutter-first design** - Optimized for Flutter UI development

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  async_result: ^1.0.6
```

## Overview

When working with asynchronous operations, it's common to encounter different states such as loading, success, or error. `AsyncResult` encapsulates these states into a single, type-safe class, making it easier to handle and propagate asynchronous results throughout your application.

## States

`AsyncResult` has four possible states:

1. `AsyncInitial`: Represents the initial state before any operation has started.
2. `AsyncLoading`: Indicates that an asynchronous operation is in progress.
3. `AsyncData`: Represents a successful state with associated data.
4. `AsyncError`: Represents an error state with associated error information.

## Basic Usage

AsyncResult provides four distinct states:

```dart
// Initial state
final initial = AsyncResult<String, Exception>.initial();

// Loading state
final loading = AsyncResult<String, Exception>.loading();

// Success state with data
final success = AsyncResult<String, Exception>.data("Hello, World!");

// Error state
final error = AsyncResult<String, Exception>.error(Exception("Something went wrong"));
```

### Pattern Matching

Use the `when` method to handle all possible states:

```dart
result.when(
  whenInitial: () => print("Initial state"),
  whenLoading: () => print("Loading..."),
  whenData: (data) => print("Success: $data"),
  whenError: (error) => print("Error: $error"),
);
```

## Integration with Bloc/Cubit

AsyncResult is specifically designed to work seamlessly with the Bloc package, providing a clean and type-safe way to manage async operations in your Flutter applications.

### Simple Example

Here's a complete example showing how to use AsyncResult with Cubit for managing user data:

```dart
// Domain models
class User {
  final String id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });
}

// Error types
sealed class UserError {
  const UserError();
}

class NetworkError extends UserError {
  final String message;
  const NetworkError(this.message);
}

class NotFoundError extends UserError {
  const NotFoundError();
}

// Repository
abstract class UserRepository {
  Future<User> fetchUser(String id);
  Future<List<User>> fetchUsers();
}

class ApiUserRepository implements UserRepository {
  @override
  Future<User> fetchUser(String id) async {
    // Simulating API call with potential failures
    await Future.delayed(const Duration(seconds: 1));
    
    if (id == 'error') {
      throw const NetworkError('Failed to fetch user');
    }
    
    if (id == 'notfound') {
      throw const NotFoundError();
    }
    
    return User(
      id: id,
      name: "John Doe",
      email: "john.doe@example.com",
    );
  }

  @override
  Future<List<User>> fetchUsers() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      const User(id: '1', name: 'Alice', email: 'alice@example.com'),
      const User(id: '2', name: 'Bob', email: 'bob@example.com'),
    ];
  }
}

// State definitions
typedef UserState = AsyncResult<User, UserError>;
typedef UsersState = AsyncResult<List<User>, UserError>;

// Single User Cubit
class UserCubit extends Cubit<UserState> {
  final UserRepository _repository;

  UserCubit(this._repository) : super(const AsyncResult.initial());

  Future<void> loadUser(String id) async {
    emit(const AsyncResult.loading());

    try {
      final user = await _repository.fetchUser(id);
      emit(AsyncResult.data(user));
    } on UserError catch (e) {
      emit(AsyncResult.error(e));
    } catch (e) {
      emit(AsyncResult.error(NetworkError(e.toString())));
    }
  }

  void reset() {
    emit(const AsyncResult.initial());
  }
}

// Multiple Users Cubit
class UsersCubit extends Cubit<UsersState> {
  final UserRepository _repository;

  UsersCubit(this._repository) : super(const AsyncResult.initial());

  Future<void> loadUsers() async {
    emit(const AsyncResult.loading());

    try {
      final users = await _repository.fetchUsers();
      emit(AsyncResult.data(users));
    } on UserError catch (e) {
      emit(AsyncResult.error(e));
    } catch (e) {
      emit(AsyncResult.error(NetworkError(e.toString())));
    }
  }

  void refresh() => loadUsers();
}
```

### Advanced Bloc Integration

For more complex scenarios, you can use full Bloc pattern with events:

```dart
// Events
sealed class UserEvent {
  const UserEvent();
}

class LoadUserRequested extends UserEvent {
  final String userId;
  const LoadUserRequested(this.userId);
}

class RefreshUserRequested extends UserEvent {
  const RefreshUserRequested();
}

class ResetUserRequested extends UserEvent {
  const ResetUserRequested();
}

// Bloc
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repository;
  String? _currentUserId;

  UserBloc(this._repository) : super(const AsyncResult.initial()) {
    on<LoadUserRequested>(_onLoadUserRequested);
    on<RefreshUserRequested>(_onRefreshUserRequested);
    on<ResetUserRequested>(_onResetUserRequested);
  }

  Future<void> _onLoadUserRequested(
    LoadUserRequested event,
    Emitter<UserState> emit,
  ) async {
    _currentUserId = event.userId;
    emit(const AsyncResult.loading());

    try {
      final user = await _repository.fetchUser(event.userId);
      emit(AsyncResult.data(user));
    } on UserError catch (e) {
      emit(AsyncResult.error(e));
    } catch (e) {
      emit(AsyncResult.error(NetworkError(e.toString())));
    }
  }

  Future<void> _onRefreshUserRequested(
    RefreshUserRequested event,
    Emitter<UserState> emit,
  ) async {
    if (_currentUserId != null) {
      // Keep current state while refreshing
      final currentState = state;
      
      try {
        final user = await _repository.fetchUser(_currentUserId!);
        emit(AsyncResult.data(user));
      } on UserError catch (e) {
        emit(AsyncResult.error(e));
      } catch (e) {
        // Revert to previous state on error during refresh
        emit(currentState);
      }
    }
  }

  void _onResetUserRequested(
    ResetUserRequested event,
    Emitter<UserState> emit,
  ) {
    _currentUserId = null;
    emit(const AsyncResult.initial());
  }
}
```

### Using in UI

Here's how to use AsyncResult with Bloc in Flutter widgets:

#### Basic BlocBuilder Usage

```dart
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          return state.when(
            whenInitial: () => const _InitialView(),
            whenLoading: () => const _LoadingView(),
            whenData: (user) => _UserDataView(user: user),
            whenError: (error) => _ErrorView(error: error),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<UserCubit>().loadUser('123'),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _InitialView extends StatelessWidget {
  const _InitialView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Press the button to load user data'),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading user...'),
        ],
      ),
    );
  }
}

class _UserDataView extends StatelessWidget {
  final User user;
  
  const _UserDataView({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Information',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'ID', value: user.id),
                  _InfoRow(label: 'Name', value: user.name),
                  _InfoRow(label: 'Email', value: user.email),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final UserError error;
  
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _getErrorMessage(error),
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<UserCubit>().loadUser('123'),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _getErrorMessage(UserError error) {
    return switch (error) {
      NetworkError(message: final msg) => 'Network Error: $msg',
      NotFoundError() => 'User not found',
    };
  }
}
```

#### Advanced UI Patterns

For more complex UI patterns, you can use multiple BlocBuilders or BlocConsumer:

```dart
class UsersListPage extends StatelessWidget {
  const UsersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          BlocBuilder<UsersCubit, UsersState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: state.isLoading ? Colors.grey : null,
                ),
                onPressed: state.isLoading 
                  ? null 
                  : () => context.read<UsersCubit>().refresh(),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<UsersCubit, UsersState>(
        listener: (context, state) {
          // Show snackbar on error
          state.whenError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_getErrorMessage(error)),
                backgroundColor: Theme.of(context).colorScheme.error,
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () => context.read<UsersCubit>().refresh(),
                ),
              ),
            );
          });
        },
        builder: (context, state) {
          return state.when(
            whenInitial: () => const _EmptyView(),
            whenLoading: () => const _LoadingListView(),
            whenData: (users) => _UsersListView(users: users),
            whenError: (error) => _ErrorListView(error: error),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<UsersCubit>().loadUsers(),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getErrorMessage(UserError error) {
    return switch (error) {
      NetworkError(message: final msg) => msg,
      NotFoundError() => 'No users found',
    };
  }
}

class _UsersListView extends StatelessWidget {
  final List<User> users;
  
  const _UsersListView({required this.users});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(user.name.substring(0, 1).toUpperCase()),
          ),
          title: Text(user.name),
          subtitle: Text(user.email),
          onTap: () {
            // Navigate to user detail or perform action
            context.read<UserCubit>().loadUser(user.id);
          },
        );
      },
    );
  }
}
```

## Advanced Usage

### Transforming Data

Use `map` to transform the success value:

```dart
final result = AsyncResult<int, String>.data(42);
final mapped = result.map((i) => i.toString()); // AsyncResult<String, String>
```

### Error Handling

Use `mapError` to transform the error value:

```dart
final result = AsyncResult<int, String>.error("not_found");
final mapped = result.mapError((e) => Exception(e)); // AsyncResult<int, Exception>
```

### Chaining Operations

Use `flatMap` to chain AsyncResult operations:

```dart
class UserCubit extends Cubit<AsyncResult<UserProfile, Exception>> {
  Future<void> loadUserWithPosts(String userId) async {
    emit(const AsyncResult.loading());

    try {
      final userResult = await _repository.fetchUser(userId);
      final result = AsyncResult<User, Exception>.data(userResult)
          .flatMap((user) async {
            final posts = await _repository.fetchUserPosts(user.id);
            return AsyncResult.data(
              UserProfile(user: user, posts: posts),
            );
          });

      emit(result);
    } catch (e) {
      emit(AsyncResult.error(Exception(e.toString())));
    }
  }
}
```

### Recovery from Errors

Use `recover` to handle errors gracefully:

```dart
class UserCubit extends Cubit<AsyncResult<User, Exception>> {
  Future<void> loadUserWithFallback(String id) async {
    emit(const AsyncResult.loading());

    try {
      final user = await _repository.fetchUser(id);
      emit(AsyncResult.data(user));
    } catch (e) {
      emit(
        AsyncResult<User, Exception>
          .error(Exception(e.toString()))
          .recover((_) => User(id: "0", name: "Guest User"))
      );
    }
  }
}
```

## Best Practices

### 1. Type Safety and Error Modeling

Always specify both success and error types explicitly and use sealed classes for error modeling:

```dart
// ❌ Avoid: Using dynamic or Exception
typedef UserState = AsyncResult<User, dynamic>;
typedef UserState = AsyncResult<User, Exception>;

// ✅ Prefer: Specific error types
sealed class UserError {
  const UserError();
}

class NetworkError extends UserError {
  final String message;
  final int? statusCode;
  const NetworkError(this.message, [this.statusCode]);
}

class ValidationError extends UserError {
  final Map<String, String> fieldErrors;
  const ValidationError(this.fieldErrors);
}

typedef UserState = AsyncResult<User, UserError>;
```

### 2. Cubit/Bloc Initialization

Always start with the initial state when creating a Cubit or Bloc:

```dart
// ✅ Correct initialization
class UserCubit extends Cubit<AsyncResult<User, UserError>> {
  UserCubit(this._repository) : super(const AsyncResult.initial());
}

class UserBloc extends Bloc<UserEvent, AsyncResult<User, UserError>> {
  UserBloc(this._repository) : super(const AsyncResult.initial());
}
```

### 3. Consistent State Transitions

Always emit loading state before async operations and handle all possible exceptions:

```dart
// ✅ Proper state transitions
Future<void> loadUser(String id) async {
  emit(const AsyncResult.loading()); // Always emit loading first

  try {
    final user = await _repository.fetchUser(id);
    emit(AsyncResult.data(user));
  } on UserError catch (e) {
    emit(AsyncResult.error(e)); // Catch domain-specific errors
  } catch (e) {
    emit(AsyncResult.error(NetworkError(e.toString()))); // Catch unexpected errors
  }
}
```

### 4. UI State Handling

Use proper state handling in UI with appropriate loading indicators and error states:

```dart
// ✅ Comprehensive UI state handling
BlocBuilder<UserCubit, UserState>(
  builder: (context, state) {
    return state.when(
      whenInitial: () => const EmptyStateWidget(),
      whenLoading: () => const LoadingWidget(),
      whenData: (user) => UserWidget(user: user),
      whenError: (error) => ErrorWidget(
        error: error,
        onRetry: () => context.read<UserCubit>().loadUser(userId),
      ),
    );
  },
)
```

### 5. Separation of Concerns

Keep business logic in repositories and use Cubits/Blocs for state management only:

```dart
// ✅ Clean separation
class UserRepository {
  Future<User> fetchUser(String id) async {
    // All business logic here
    final response = await _apiClient.get('/users/$id');
    
    if (response.statusCode == 404) {
      throw const NotFoundError();
    }
    
    if (response.statusCode != 200) {
      throw NetworkError('Failed to fetch user: ${response.statusCode}');
    }
    
    return User.fromJson(response.data);
  }
}

class UserCubit extends Cubit<UserState> {
  // Only state management logic here
  Future<void> loadUser(String id) async {
    emit(const AsyncResult.loading());
    
    try {
      final user = await _repository.fetchUser(id);
      emit(AsyncResult.data(user));
    } on UserError catch (e) {
      emit(AsyncResult.error(e));
    }
  }
}
```

### 6. Testing Strategies

Test each state explicitly and use proper mocking:

```dart
// ✅ Comprehensive testing
void main() {
  group('UserCubit', () {
    late UserRepository mockRepository;
    late UserCubit cubit;

    setUp(() {
      mockRepository = MockUserRepository();
      cubit = UserCubit(mockRepository);
    });

    blocTest<UserCubit, UserState>(
      'emits [loading, data] when loadUser succeeds',
      build: () {
        when(() => mockRepository.fetchUser('123'))
            .thenAnswer((_) async => const User(id: '123', name: 'Test'));
        return cubit;
      },
      act: (cubit) => cubit.loadUser('123'),
      expect: () => [
        const AsyncResult<User, UserError>.loading(),
        const AsyncResult<User, UserError>.data(
          User(id: '123', name: 'Test'),
        ),
      ],
    );

    blocTest<UserCubit, UserState>(
      'emits [loading, error] when loadUser fails',
      build: () {
        when(() => mockRepository.fetchUser('123'))
            .thenThrow(const NetworkError('Connection failed'));
        return cubit;
      },
      act: (cubit) => cubit.loadUser('123'),
      expect: () => [
        const AsyncResult<User, UserError>.loading(),
        const AsyncResult<User, UserError>.error(
          NetworkError('Connection failed'),
        ),
      ],
    );
  });
}
```

### 7. Memory Management

Properly dispose of resources and avoid memory leaks:

```dart
// ✅ Proper resource management
class UserCubit extends Cubit<UserState> {
  final UserRepository _repository;
  StreamSubscription? _subscription;

  UserCubit(this._repository) : super(const AsyncResult.initial());

  void startListening() {
    _subscription = _repository.userStream.listen(
      (user) => emit(AsyncResult.data(user)),
      onError: (error) => emit(AsyncResult.error(NetworkError(error.toString()))),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

### 8. Performance Optimization

Use pattern matching efficiently and consider state caching:

```dart
// ✅ Efficient pattern matching
Widget build(BuildContext context) {
  return BlocBuilder<UserCubit, UserState>(
    buildWhen: (previous, current) {
      // Only rebuild when state actually changes
      return previous != current;
    },
    builder: (context, state) {
      // Use maybeWhen for partial state handling
      return state.maybeWhen(
        whenData: (user) => UserWidget(user: user),
        orElse: () => const LoadingWidget(),
      );
    },
  );
}
```

### 9. State Composition

For complex states, compose multiple AsyncResults:

```dart
// ✅ State composition
class UserProfileState {
  final AsyncResult<User, UserError> user;
  final AsyncResult<List<Post>, PostError> posts;
  final AsyncResult<UserSettings, SettingsError> settings;

  const UserProfileState({
    required this.user,
    required this.posts,
    required this.settings,
  });

  bool get isLoading => 
    user.isLoading || posts.isLoading || settings.isLoading;

  bool get hasAllData => 
    user.hasData && posts.hasData && settings.hasData;
}
```

### 10. Documentation and Code Clarity

Always document your state types and business logic:

```dart
/// Represents the state of user authentication in the application.
/// 
/// This state manages the current user session and handles authentication
/// operations like login, logout, and session validation.
typedef AuthState = AsyncResult<AuthenticatedUser, AuthError>;

/// Handles user authentication operations.
/// 
/// This cubit manages the authentication flow and maintains the current
/// user session state. It integrates with [AuthRepository] for actual
/// authentication operations.
class AuthCubit extends Cubit<AuthState> {
  /// Creates a new [AuthCubit] with the given [repository].
  /// 
  /// The cubit starts in the initial state, indicating no authentication
  /// attempt has been made yet.
  AuthCubit(this._repository) : super(const AsyncResult.initial());
  
  // ... implementation
}
```

## API Reference

### Types

- `T`: The type of the success value
- `E`: The type of the error value

### Constructors

| Constructor                  | Description                                 | Example                                                     |
| ---------------------------- | ------------------------------------------- | ----------------------------------------------------------- |
| `AsyncResult.initial()`      | Creates a new instance in the initial state | `AsyncResult<String, Exception>.initial()`                  |
| `AsyncResult.loading()`      | Creates a new instance in the loading state | `AsyncResult<String, Exception>.loading()`                  |
| `AsyncResult.data(T data)`   | Creates a new instance with success data    | `AsyncResult<String, Exception>.data("Success")`            |
| `AsyncResult.error(E error)` | Creates a new instance with an error        | `AsyncResult<String, Exception>.error(Exception("Failed"))` |

### Properties

#### State Properties

| Property             | Type   | Description                                              |
| -------------------- | ------ | -------------------------------------------------------- |
| `isInitial`          | `bool` | Whether the result is in the initial state               |
| `isLoading`          | `bool` | Whether the result is in the loading state               |
| `hasData`            | `bool` | Whether the result contains success data                 |
| `hasError`           | `bool` | Whether the result contains an error                     |
| `isSuccess`          | `bool` | Whether the result is successful (has data and no error) |
| `isError`            | `bool` | Whether the result is an error (has error and no data)   |
| `isLoadingOrInitial` | `bool` | Whether the result is in either loading or initial state |
| `isDateOrError`      | `bool` | Whether the result has either data or error              |
| `isCompleted`        | `bool` | Whether the result is in a final state (data or error)   |

#### Value Access Properties

| Property      | Type | Description                                 |
| ------------- | ---- | ------------------------------------------- |
| `dataOrNull`  | `T?` | The success value, or null if not available |
| `errorOrNull` | `E?` | The error value, or null if not available   |

### Methods

#### Pattern Matching Methods

##### `when<R>`

Pattern matches on all possible states with required handlers.

```dart
R when<R>({
  required R Function() whenInitial,
  required R Function() whenLoading,
  required R Function(T data) whenData,
  required R Function(E error) whenError,
});

// Example
final message = result.when(
  whenInitial: () => 'Start',
  whenLoading: () => 'Loading...',
  whenData: (data) => 'Got: $data',
  whenError: (e) => 'Error: $e',
);
```

##### `maybeWhen<R>`

Pattern matches with optional handlers and a required default.

```dart
R maybeWhen<R>({
  R Function()? whenInitial,
  R Function()? whenLoading,
  R Function(T data)? whenData,
  R Function(E error)? whenError,
  required R Function() orElse,
});

// Example
final message = result.maybeWhen(
  whenData: (data) => 'Got: $data',
  orElse: () => 'Not in data state',
);
```

##### `whenOrNull<R>`

Pattern matches with optional handlers, returning null if no handler matches.

```dart
R? whenOrNull<R>({
  R Function()? whenInitial,
  R Function()? whenLoading,
  R Function(T data)? whenData,
  R Function(E error)? whenError,
});

// Example
final message = result.whenOrNull(
  whenData: (data) => 'Got: $data',
); // Returns null if not in data state
```

#### State-Specific Handlers

| Method           | Type                         | Description                                  |
| ---------------- | ---------------------------- | -------------------------------------------- |
| `whenInitial<R>` | `R? Function(R Function())`  | Executes handler only in initial state       |
| `whenLoading<R>` | `R? Function(R Function())`  | Executes handler only in loading state       |
| `whenData<R>`    | `R? Function(R Function(T))` | Executes handler only when data is available |
| `whenError<R>`   | `R? Function(R Function(E))` | Executes handler only when error is present  |

#### Transformation Methods

##### `map<R>`

Transforms the success value while preserving the state.

```dart
AsyncResult<R, E> map<R>(R Function(T data) mapper);

// Example
final intResult = AsyncResult<String, Exception>.data("42");
final numResult = intResult.map(int.parse);
```

##### `mapError<F>`

Transforms the error value while preserving the state.

```dart
AsyncResult<T, F> mapError<F>(F Function(E error) mapper);

// Example
final result = AsyncResult<int, String>.error("not_found");
final mapped = result.mapError((e) => HttpException(e));
```

##### `bimap<R, F>`

Transforms both success and error values simultaneously.

```dart
AsyncResult<R, F> bimap<R, F>({
  required R Function(T data) data,
  required F Function(E error) error,
});

// Example
final result = AsyncResult<int, String>.data(42);
final mapped = result.bimap(
  data: (i) => i.toString(),
  error: (e) => Exception(e),
);
```

#### Error Handling Methods

##### `recover`

Attempts to recover from an error by providing a default value.

```dart
AsyncResult<T, E> recover(T Function(E error) recovery);

// Example
final result = AsyncResult<int, String>.error("not_found")
    .recover((_) => -1);
```

##### `mapErrorWhere`

Conditionally transforms errors that match a predicate.

```dart
AsyncResult<T, E> mapErrorWhere(
  bool Function(E error) test,
  E Function(E error) mapper,
);

// Example
final result = AsyncResult<int, String>.error("not_found")
    .mapErrorWhere(
      (e) => e.contains("not"),
      (e) => "404: $e",
    );
```

##### `mapWhere`

Conditionally transforms data that matches a predicate.

```dart
AsyncResult<T, E> mapWhere(
  bool Function(T data) test,
  T Function(T data) mapper,
);

// Example
final result = AsyncResult<int, String>.data(42)
    .mapWhere(
      (n) => n > 0,
      (n) => n * 2,
    );
```

#### Value Retrieval Methods

| Method           | Type            | Description                   | Example                            |
| ---------------- | --------------- | ----------------------------- | ---------------------------------- |
| `getDataOrElse`  | `T Function(T)` | Gets data or returns default  | `result.getDataOrElse(0)`          |
| `getErrorOrElse` | `E Function(E)` | Gets error or returns default | `result.getErrorOrElse("unknown")` |

#### Static Utility Methods

| Method        | Type                                         | Description                         |
| ------------- | -------------------------------------------- | ----------------------------------- |
| `allComplete` | `bool Function(Iterable<AsyncResult<T, E>>)` | Checks if all results are completed |
| `anyError`    | `bool Function(Iterable<AsyncResult<T, E>>)` | Checks if any result has an error   |

### Example Usage with Static Methods

```dart
final results = [
  AsyncResult<int, String>.data(1),
  AsyncResult<int, String>.data(2),
  AsyncResult<int, String>.loading(),
];

final allDone = AsyncResult.allComplete(results); // false
final hasErrors = AsyncResult.anyError(results); // false

// Wait for all results to complete
await Future.wait(futures).then((completed) {
  if (AsyncResult.allComplete(completed) && !AsyncResult.anyError(completed)) {
    print('All operations successful!');
  }
});
```

## Review and Recommendations

### Architecture Benefits

AsyncResult provides significant architectural advantages for Flutter applications using the Bloc pattern:

#### ✅ **Type Safety**
- Eliminates runtime state-related errors through compile-time guarantees
- Prevents common mistakes like accessing null data or unhandled error states
- Improves code maintainability and developer confidence

#### ✅ **Predictable State Management**
- Four well-defined states cover all async operation scenarios
- Clear state transitions make debugging easier
- Consistent pattern across different features reduces cognitive load

#### ✅ **Bloc Integration**
- Seamlessly integrates with flutter_bloc package
- Reduces boilerplate code in Cubit/Bloc implementations
- Encourages clean separation of concerns

### Performance Considerations

#### **Memory Efficiency**
- Lightweight implementation with minimal memory overhead
- Immutable states prevent unnecessary rebuilds
- Efficient pattern matching with when() methods

#### **UI Performance**
```dart
// ✅ Efficient: Only rebuild when state changes
BlocBuilder<UserCubit, UserState>(
  buildWhen: (previous, current) => previous != current,
  builder: (context, state) => state.when(...),
)

// ✅ Partial updates: Use maybeWhen for specific states
state.maybeWhen(
  whenData: (data) => DataWidget(data),
  orElse: () => existingWidget, // Avoid unnecessary rebuilds
)
```

### Common Pitfalls and Solutions

#### 1. **State Granularity**
```dart
// ❌ Avoid: Too many states in one AsyncResult
class UserProfileState {
  final AsyncResult<ComplexObject, Error> everything;
}

// ✅ Prefer: Separate concerns
class UserProfileState {
  final AsyncResult<User, UserError> user;
  final AsyncResult<List<Post>, PostError> posts;
  final AsyncResult<Settings, SettingsError> settings;
}
```

#### 2. **Error Handling**
```dart
// ❌ Avoid: Generic error handling
try {
  // operation
} catch (e) {
  emit(AsyncResult.error(e)); // Loss of type safety
}

// ✅ Prefer: Specific error handling
try {
  // operation
} on NetworkException catch (e) {
  emit(AsyncResult.error(NetworkError(e.message)));
} on ValidationException catch (e) {
  emit(AsyncResult.error(ValidationError(e.errors)));
} catch (e) {
  emit(AsyncResult.error(UnknownError(e.toString())));
}
```

#### 3. **State Persistence**
```dart
// ✅ Handle app lifecycle properly
class UserCubit extends Cubit<UserState> with HydratedMixin {
  @override
  UserState fromJson(Map<String, dynamic> json) {
    // Only restore data state, not loading/error states
    if (json['type'] == 'data') {
      return AsyncResult.data(User.fromJson(json['data']));
    }
    return const AsyncResult.initial();
  }

  @override
  Map<String, dynamic>? toJson(UserState state) {
    return state.whenOrNull(
      whenData: (user) => {
        'type': 'data',
        'data': user.toJson(),
      },
    );
  }
}
```

### When to Use AsyncResult

#### **✅ Perfect For:**
- Bloc/Cubit state management in Flutter apps
- API call handling with loading states
- Form submission with validation feedback
- Data fetching with error recovery
- Complex async operations with multiple states

#### **❌ Consider Alternatives For:**
- Simple boolean flags or single values
- Synchronous operations
- Real-time streaming data (consider StreamBuilder)
- Complex state machines (consider state_machine packages)

### Migration Strategy

#### **From Existing Code:**
```dart
// Before: Manual state management
class UserCubit extends Cubit<User?> {
  bool isLoading = false;
  String? error;
  
  Future<void> loadUser() async {
    isLoading = true;
    error = null;
    // ... complex state tracking
  }
}

// After: AsyncResult
class UserCubit extends Cubit<AsyncResult<User, UserError>> {
  UserCubit() : super(const AsyncResult.initial());
  
  Future<void> loadUser() async {
    emit(const AsyncResult.loading());
    // ... clean state management
  }
}
```

### Testing Recommendations

#### **State Testing**
```dart
// Test all state transitions
void main() {
  group('UserCubit State Transitions', () {
    test('initial state is AsyncInitial', () {
      expect(cubit.state.isInitial, true);
    });

    blocTest<UserCubit, UserState>(
      'loading → data transition',
      build: () => cubit,
      act: (cubit) => cubit.loadUser('123'),
      expect: () => [
        predicate<UserState>((state) => state.isLoading),
        predicate<UserState>((state) => state.hasData),
      ],
    );
  });
}
```

#### **Error Scenario Testing**
```dart
blocTest<UserCubit, UserState>(
  'handles network errors gracefully',
  build: () {
    when(() => repository.fetchUser(any()))
        .thenThrow(NetworkException('No internet'));
    return cubit;
  },
  act: (cubit) => cubit.loadUser('123'),
  expect: () => [
    predicate<UserState>((state) => state.isLoading),
    predicate<UserState>((state) => 
        state.hasError && state.errorOrNull is NetworkError),
  ],
);
```

### Future Enhancements

Based on community feedback, consider these patterns for advanced usage:

1. **Pagination Support**: Combine with paginated lists
2. **Optimistic Updates**: Implement optimistic UI patterns
3. **Offline Support**: Integrate with cache-first strategies
4. **Real-time Updates**: Combine with WebSocket streams

### Community Resources

- **Examples**: Check the `/example` folder for comprehensive usage patterns
- **Extensions**: Consider creating custom extensions for your domain
- **Testing**: Use the provided test utilities for consistent testing

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
