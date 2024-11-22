# AsyncResult

A powerful and type-safe way to handle different states of asynchronous operations in Dart and Flutter applications. AsyncResult helps you manage the common states of async operations: initial, loading, data (success), and error states.

## Features

- 🎯 Type-safe state handling
- 🔄 Comprehensive state management
- 🛠️ Rich functional programming utilities
- 🧩 Seamless integration with Bloc/Cubit
- ⚡ Efficient pattern matching
- 🔍 Built-in error handling

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  async_result: ^1.0.4
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

## Integration with Cubit

Here's a complete example showing how to use AsyncResult with Cubit for managing user data:

```dart
// User model
class User {
  final String id;
  final String name;

  User({required this.id, required this.name});
}

// Repository
class UserRepository {
  Future<User> fetchUser(String id) async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 1));
    return User(id: id, name: "John Doe");
  }
}

// State
typedef UserState = AsyncResult<User, Exception>;

// Cubit
class UserCubit extends Cubit<UserState> {
  final UserRepository _repository;

  UserCubit(this._repository) : super(const AsyncResult.initial());

  Future<void> loadUser(String id) async {
    emit(const AsyncResult.loading());

    try {
      final user = await _repository.fetchUser(id);
      emit(AsyncResult.data(user));
    } catch (e) {
      emit(AsyncResult.error(Exception(e.toString())));
    }
  }
}
```

### Using in UI

Here's how to use the UserCubit in a Flutter widget:

```dart
class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return state.when(
          whenInitial: () => const Text('Press button to load user'),
          whenLoading: () => const CircularProgressIndicator(),
          whenData: (user) => Column(
            children: [
              Text('ID: ${user.id}'),
              Text('Name: ${user.name}'),
            ],
          ),
          whenError: (error) => Text('Error: ${error.toString()}'),
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

1. **Type Safety**: Always specify both success and error types:

```dart
typedef UserState = AsyncResult<User, Exception>;
```

2. **Initial State**: Start with initial state when creating a Cubit:

```dart
class MyCubit extends Cubit<AsyncResult<Data, Error>> {
  MyCubit() : super(const AsyncResult.initial());
}
```

3. **Error Handling**: Use specific error types instead of dynamic:

```dart
AsyncResult<Data, NetworkError> instead of AsyncResult<Data, dynamic>
```

4. **State Transitions**: Always emit loading state before async operations:

```dart
emit(const AsyncResult.loading());
// ... perform async work
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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
