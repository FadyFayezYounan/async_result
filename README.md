# AsyncResult

`AsyncResult` is a Dart class that provides a type-safe way to handle different states of asynchronous operations. It is designed to make working with asynchronous data more predictable and less error-prone.

## Table of Contents

- [Overview](#overview)
- [States](#states)
- [Usage](#usage)
- [Examples](#examples)
- [API Reference](#api-reference)

## Overview

When working with asynchronous operations, it's common to encounter different states such as loading, success, or error. `AsyncResult` encapsulates these states into a single, type-safe class, making it easier to handle and propagate asynchronous results throughout your application.

## States

`AsyncResult` has four possible states:

1. `AsyncInitial`: Represents the initial state before any operation has started.
2. `AsyncLoading`: Indicates that an asynchronous operation is in progress.
3. `AsyncData`: Represents a successful state with associated data.
4. `AsyncError`: Represents an error state with associated error information.

## Usage

To use `AsyncResult`, you typically create instances of it at the boundary of your asynchronous operations (e.g., in your data repositories or services) and then pass these instances up to your UI layer or business logic.

## Examples

### Basic Usage

```dart
AsyncResult<String, Exception> fetchData() {
  try {
    // Simulating an asynchronous operation
    return AsyncResult.data("Fetched data");
  } catch (e) {
    return AsyncResult.error(Exception("Failed to fetch data"));
  }
}

void handleResult() {
  final result = fetchData();

  result.when(
    whenInitial: () => print("Operation hasn't started"),
    whenLoading: () => print("Loading..."),
    whenData: (data) => print("Data: $data"),
    whenError: (error) => print("Error: $error"),
  );
}
```

### Usage in a Flutter Widget

```dart
class DataWidget extends StatelessWidget {
  final AsyncResult<String, Exception> result;

  const DataWidget({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return result.when(
      whenInitial: () => Text("Press button to load"),
      whenLoading: () => CircularProgressIndicator(),
      whenData: (data) => Text(data),
      whenError: (error) => Text("Error: ${error.toString()}"),
    );
  }
}
```

### Chaining Operations

```dart
AsyncResult<int, String> computeValue() {
  return AsyncResult.data(42)
    .when(
      whenInitial: () => AsyncResult.error("Unexpected initial state"),
      whenLoading: () => AsyncResult.error("Unexpected loading state"),
      whenData: (value) => AsyncResult.data(value * 2),
      whenError: (error) => AsyncResult.error("Computation failed: $error"),
    );
}
```

## API Reference

### Constructors

- `AsyncResult.initial()`: Creates an instance in the initial state.
- `AsyncResult.loading()`: Creates an instance in the loading state.
- `AsyncResult.data(T data)`: Creates an instance with successful data.
- `AsyncResult.error(E error)`: Creates an instance with an error.

### Properties

- `isInitial`: Returns true if in the initial state.
- `isLoading`: Returns true if in the loading state.
- `hasError`: Returns true if in the error state.
- `hasData`: Returns true if data is available.
- `isLoadingOrInitial`: Returns true if in either loading or initial state.
- `isDataOrError`: Returns true if in either data or error state.
- `dataOrNull`: Returns the data if available, otherwise null.

### Methods

- `when<R>({...})`: Pattern matching on all possible states.
- `maybeWhen<R>({...})`: Pattern matching with a default case.
- `whenInitial<R>(...)`: Executes the given function if in initial state.
- `whenLoading<R>(...)`: Executes the given function if in loading state.
- `whenData<R>(...)`: Executes the given function if data is available.
- `whenError<R>(...)`: Executes the given function if in error state.
- `map<R>({...})`: Maps the current state to a value of type R.

By using `AsyncResult`, you can write more robust and predictable asynchronous code, improving the overall reliability and maintainability of your Dart and Flutter applications.
