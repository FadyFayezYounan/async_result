import 'async_result_exceptions.dart';

sealed class AsyncResult<T, E> {
  /// Represents the result of an asynchronous operation.
  ///
  /// This sealed class provides a type-safe way to handle different states
  /// of asynchronous operations: initial, loading, data (success), and error.
  ///
  /// Usage example:
  /// ```dart
  /// AsyncResult<String> result = AsyncResult.loading();
  /// result.when(
  ///   whenInitial: () => print("Initial state"),
  ///   whenLoading: () => print("Loading..."),
  ///   whenData: (data) => print("Data: $data"),
  ///   whenError: (error) => print("Error: $error"),
  /// );
  /// ```
  const AsyncResult._();

  /// Creates an instance representing the initial state.
  const factory AsyncResult.initial() = AsyncInitial<T, E>;

  /// Creates an instance representing the loading state.
  const factory AsyncResult.loading() = AsyncLoading<T, E>;

  /// Creates an instance representing a successful state with data.
  const factory AsyncResult.data(T data) = AsyncData<T, E>;

  /// Creates an instance representing an error state.
  const factory AsyncResult.error(E error) = AsyncError<T, E>;

  /// Checks if all `AsyncResult` instances in the given iterable are completed (success or error).
  ///
  /// This method iterates through the provided iterable of `AsyncResult`
  /// instances and returns `true` if every instance has completed, otherwise
  /// returns `false`.
  ///
  /// - Parameter iterable: An iterable collection of `AsyncResult` instances.
  /// - Returns: A boolean value indicating whether all `AsyncResult` instances
  ///   in the iterable are completed.
  static bool allComplete<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    return iterable.every((result) => result.isCompleted);
  }

  /// Checks if all elements in the given iterable are successful.
  ///
  /// This method takes an iterable of `AsyncResult` objects and returns `true`
  /// if every element in the iterable has a successful result (`isSuccess` is `true`).
  ///
  static bool allSuccess<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    return iterable.every((result) => result.isSuccess);
  }

  /// Checks if all elements in the given iterable are in an error state.
  ///
  /// This method iterates through the provided [iterable] of [AsyncResult] objects
  /// and returns `true` if every element is an error. Otherwise, it returns `false`.
  ///
  /// - Parameter iterable: An iterable collection of [AsyncResult] objects.
  /// - Returns: A boolean value indicating whether all elements are errors.
  static bool allError<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    return iterable.every((result) => result.isError);
  }

  /// Checks if any [AsyncResult] in the given iterable has an error.
  ///
  /// This method iterates through the provided [iterable] of [AsyncResult]
  /// objects and returns `true` if at least one of them has an error.
  ///
  /// - [iterable]: An iterable collection of [AsyncResult] objects to check.
  ///
  /// Returns `true` if any [AsyncResult] in the iterable has an error, otherwise `false`.
  static bool anyError<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    return iterable.any((result) => result.hasError);
  }

  /// Checks if any of the `AsyncResult` objects in the given iterable are in a loading state.
  ///
  /// This method iterates through the provided iterable of `AsyncResult` objects
  /// and returns `true` if at least one of the objects is currently loading.
  ///
  /// - Parameter iterable: An iterable collection of `AsyncResult` objects.
  /// - Returns: `true` if any `AsyncResult` in the iterable is loading, otherwise `false`.
  static bool anyLoading<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    return iterable.any((result) => result.isLoading);
  }

  /// Checks if any of the `AsyncResult` instances in the given iterable are completed (success or error).
  ///
  /// This method iterates through the provided iterable and returns `true` if
  /// at least one `AsyncResult` has completed, otherwise it returns `false`.
  ///
  /// - Parameter iterable: An iterable collection of `AsyncResult` instances.
  /// - Returns: A boolean value indicating whether any `AsyncResult` in the iterable is completed.
  static bool anyComplete<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    return iterable.any((result) => result.isCompleted);
  }

  /// Checks if any of the [AsyncResult] instances in the given [iterable] is successful.
  ///
  /// Returns `true` if at least one [AsyncResult] in the [iterable] has a success state,
  /// otherwise returns `false`.
  ///
  /// - Parameter iterable: An [Iterable] of [AsyncResult] instances to check.
  /// - Returns: A [bool] indicating whether any [AsyncResult] in the [iterable] is successful.
  static bool anySuccess<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    return iterable.any((result) => result.isSuccess);
  }

  /// Returns an iterable of all data from the provided list of AsyncResults.
  static Iterable<T> getAllData<T, E>(
      Iterable<AsyncResult<T, E>> iterable) sync* {
    for (var result in iterable) {
      if (result.isSuccess) {
        yield result.dataOrNull!;
      }
    }
  }

  /// Returns an iterable of all errors from the provided list of AsyncResults.
  static Iterable<E> getAllError<T, E>(
      Iterable<AsyncResult<T, E>> iterable) sync* {
    for (var result in iterable) {
      if (result.isError) {
        yield result.errorOrNull!;
      }
    }
  }

  /// Returns the first error found in the given iterable of `AsyncResult` objects.
  ///
  /// Iterates through the provided iterable and checks each `AsyncResult`
  /// for an error. If an error is found, it is returned immediately. If no
  /// errors are found, `null` is returned.
  ///
  /// - Parameters:
  ///   - iterable: An iterable collection of `AsyncResult` objects to be checked for errors.
  ///
  /// - Returns: The first error of type `E` found in the iterable, or `null` if no errors are present.
  static E? getFirstError<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    for (var result in iterable) {
      if (result.isError) {
        return result.errorOrNull;
      }
    }
    return null;
  }

  /// Returns the first successful data from an iterable of [AsyncResult].
  ///
  /// Iterates through the given [iterable] of [AsyncResult] objects and returns
  /// the data of the first [AsyncResult] that is successful. If no successful
  /// result is found, returns `null`.
  ///
  /// - `T`: The type of the data contained in the [AsyncResult].
  /// - `E`: The type of the error contained in the [AsyncResult].
  ///
  /// Returns:
  /// - The data of the first successful [AsyncResult], or `null` if none is found.
  static T? getFirstData<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    for (var result in iterable) {
      if (result.isSuccess) {
        return result.dataOrNull;
      }
    }
    return null;
  }

  /// Combines two [AsyncResult] instances into a single [AsyncResult] containing a record of both results.
  ///
  /// The combined result follows these rules:
  /// * Returns [AsyncResult.loading] if either result is loading
  /// * Returns [AsyncResult.error] with the first encountered error if any result has error
  /// * Returns [AsyncResult.data] with a record containing both data values if both results have data
  /// * Returns [AsyncResult.initial] if none of the above conditions are met
  ///
  /// ### Example
  /// ```dart
  /// final result1 = AsyncResult.data(1);
  /// final result2 = AsyncResult.data("hello");
  /// final combined = AsyncResult.zip2(result1, result2);
  /// combined.when(
  /// whenInitial: () { /* handle initial state */ },
  ///  whenLoading: () { /* handle loading state */ },
  ///  whenData: (data) {
  ///   print('Combined result: ${data.first}, ${data.second}');
  ///  },
  ///  whenError: (error) { /* handle error state */ },
  ///);
  /// ```
  ///
  /// ### Parameters
  /// * [result1] - The first [AsyncResult] to combine
  /// * [result2] - The second [AsyncResult] to combine
  ///
  /// ### Type Parameters
  /// * [T] - The type of the first result's data
  /// * [U] - The type of the second result's data
  /// * [E] - The type of possible errors (must be the same for both results)
  ///
  /// ### Returns
  /// An [AsyncResult] containing a record with [first] and [second] fields if successful
  static AsyncResult<({T first, U second}), E> zip2<T, U, E>(
    AsyncResult<T, E> result1,
    AsyncResult<U, E> result2,
  ) {
    // Check error state
    if (result1.isError) return AsyncResult.error(result1.errorOrThrow);
    if (result2.isError) return AsyncResult.error(result2.errorOrThrow);

    // Check loading state first
    if (result1.isLoading || result2.isLoading) {
      return AsyncResult.loading();
    }

    // Check data state
    if (result1.hasData && result2.hasData) {
      return AsyncResult.data(
        (first: result1.dataOrThrow, second: result2.dataOrThrow),
      );
    }

    // If none of the above, return initial
    return AsyncResult.initial();
  }

  /// Combines three [AsyncResult] instances into a single [AsyncResult] containing a record of all results.
  ///
  /// The combined result follows these rules:
  /// * Returns [AsyncResult.loading] if either result is loading
  /// * Returns [AsyncResult.error] with the first encountered error if any result has error
  /// * Returns [AsyncResult.data] with a record containing the data of all three results if all have data
  /// * Returns [AsyncResult.initial] if none of the above conditions are met
  ///
  /// ### Example
  /// ```dart
  /// final result1 = AsyncResult.data(1);
  /// final result2 = AsyncResult.data("hello");
  /// final result3 = AsyncResult.data("world");
  /// final combined = AsyncResult.zip2(result1, result2, result3);
  /// combined.when(
  /// whenInitial: () { /* handle initial state */ },
  ///  whenLoading: () { /* handle loading state */ },
  ///  whenData: (data) {
  ///   print('Combined result: ${data.first}, ${data.second}, ${data.third}');
  ///  },
  ///  whenError: (error) { /* handle error state */ },
  ///);
  /// ```
  ///
  /// ### Parameters
  /// * [result1] - The first [AsyncResult] to combine
  /// * [result2] - The second [AsyncResult] to combine
  /// * [result3] - The third [AsyncResult] to combine
  ///
  /// ### Type Parameters
  /// * [T] - The type of the first result's data
  /// * [U] - The type of the second result's data
  /// * [V] - The type of the third result's data
  /// * [E] - The type of possible errors (must be the same for both results)
  ///
  /// ### Returns
  /// An [AsyncResult] containing a record with [first], [second] and [third] fields if successful
  static AsyncResult<({T first, U second, V third}), E> zip3<T, U, V, E>(
    AsyncResult<T, E> result1,
    AsyncResult<U, E> result2,
    AsyncResult<V, E> result3,
  ) {
    // Check error state
    if (result1.isError) return AsyncResult.error(result1.errorOrThrow);
    if (result2.isError) return AsyncResult.error(result2.errorOrThrow);
    if (result3.isError) return AsyncResult.error(result3.errorOrThrow);

    // Check loading state first
    if (result1.isLoading || result2.isLoading || result3.isLoading) {
      return AsyncResult.loading();
    }
    // Check data state
    if (result1.hasData && result2.hasData && result3.hasData) {
      return AsyncResult.data((
        first: result1.dataOrThrow,
        second: result2.dataOrThrow,
        third: result3.dataOrThrow
      ));
    }

    // If none of the above, return initial
    return AsyncResult.initial();
  }

  /// Combines multiple [AsyncResult] instances into a single [AsyncResult] containing a list of their values.
  ///
  /// The resulting [AsyncResult] follows these rules:
  /// * If any result is loading, returns a loading state
  /// * If any result has an error, returns the first error encountered
  /// * If all results have data, returns a list containing all data values
  /// * Otherwise returns an initial state
  ///
  /// Example:
  /// ```dart
  /// final result1 = AsyncResult.data(1);
  /// final result2 = AsyncResult.data("hello");
  /// final combined = AsyncResult.zipMultiple([result1, result2]);
  /// // combined will be AsyncResult.data([1, "hello"])
  /// ```
  ///
  /// [results] - An iterable of [AsyncResult] instances to combine
  /// Returns an [AsyncResult] combining the states of all input results
  static AsyncResult<List<dynamic>, E> zipMultiple<E>(
    Iterable<AsyncResult<dynamic, E>> results,
  ) {
    // Check error state
    final firstError = getFirstError(results);
    if (firstError != null) {
      return AsyncResult.error(firstError);
    }

    // Check loading state first
    if (anyLoading(results)) {
      return AsyncResult.loading();
    }

    // Check data state
    if (results.every((result) => result.hasData)) {
      return AsyncResult.data(
          results.map((result) => result.dataOrNull).toList());
    }

    // If none of the above, return initial
    return AsyncResult.initial();
  }

  /// Returns true if this instance represents the initial state.
  bool get isInitial;

  /// Returns true if this instance represents the loading state.
  bool get isLoading;

  /// Returns true if this instance represents an error state.
  bool get hasError;

  /// Returns true if this instance contains data.
  bool get hasData;

  /// Returns true if this instance is a successful state.
  bool get isSuccess => hasData && !hasError;

  /// Returns true if this instance is an error state.
  bool get isError => hasError && !hasData;

  /// Returns true if this instance is in either loading or initial state.
  bool get isLoadingOrInitial;

  /// Returns true if this instance is in either data or error state.
  bool get isDateOrError;

  /// Returns true if this AsyncResult is in a final state (data or error).
  bool get isCompleted;

  /// Returns the data if available, otherwise null.
  T? get dataOrNull;

  /// Returns data if present, otherwise throws the error.
  /// ***Note***: Always check `isSuccess` before using this getter to avoid errors.
  /// If you're unsure about the state, consider using `dataOrNull` instead which
  /// returns `null` when the result is not successful.
  T get dataOrThrow;

  /// Returns the error if available, otherwise null.
  E? get errorOrNull;

  /// Returns error if present, otherwise throws the error.
  /// ***Note***: Always check `isError` before using this getter to avoid errors.
  /// If you're unsure about the state, consider using `errorOrNull` instead which
  /// returns `null` when the result is not error.
  E get errorOrThrow;

  /// Returns the data if available, otherwise returns the provided default value.
  T getDataOrElse(T defaultValue);

  /// Returns the error if available, otherwise returns the provided default value.
  E getErrorOrElse(E defaultValue);

  /// Allows pattern matching on the different states of AsyncResult.
  ///
  /// Example:
  /// ```dart
  /// result.when(
  ///   whenInitial: () => print("Initial"),
  ///   whenLoading: () => print("Loading"),
  ///   whenData: (data) => print("Data: $data"),
  ///   whenError: (error) => print("Error: $error"),
  /// );
  /// ```
  R when<R>({
    required R Function() whenInitial,
    required R Function() whenLoading,
    required R Function(T data) whenData,
    required R Function(E error) whenError,
  });

  /// Similar to `when`, but allows for a default case with `orElse`.
  ///
  /// Example:
  /// ```dart
  /// result.maybeWhen(
  ///   whenData: (data) => print("Data: $data"),
  ///   orElse: () => print("Not in data state"),
  /// );
  /// ```
  R maybeWhen<R>({
    R Function()? whenInitial,
    R Function()? whenLoading,
    R Function(T data)? whenData,
    R Function(E error)? whenError,
    required R Function() orElse,
  });

  /// Executes the given function if the state is initial.
  R? whenInitial<R>(R Function() whenInitial);

  /// Executes the given function if the state is loading.
  R? whenLoading<R>(R Function() whenLoading);

  /// Executes the given function if the state has data.
  R? whenData<R>(R Function(T data) whenData);

  /// Executes the given function if the state has an error.
  R? whenError<R>(R Function(E error) whenError);

  /// Allows pattern matching on the different states of AsyncResult,
  /// returning null if no matching function is provided.
  ///
  /// Example:
  /// ```dart
  /// final result = result.whenOrNull(
  ///   whenData: (data) => "Data: $data",
  ///   whenError: (error) => "Error: $error",
  /// );
  /// print(result ?? "No match");
  /// ```
  R? whenOrNull<R>({
    R Function()? whenInitial,
    R Function()? whenLoading,
    R Function(T data)? whenData,
    R Function(E error)? whenError,
  });

  /// Maps the success value of this AsyncResult to a new value of type R.
  ///
  /// If this AsyncResult is in the data state, applies the given mapping function
  /// to the data value and returns a new AsyncResult with the mapped value.
  /// Otherwise, returns this AsyncResult unchanged (but with updated generic types).
  ///
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.data(42);
  /// final mapped = result.map((i) => i.toString()); // AsyncResult<String, String>
  /// ```
  AsyncResult<R, E> map<R>(R Function(T data) mapper);

  /// Maps the error value of this AsyncResult to a new error type F.
  ///
  /// If this AsyncResult is in the error state, applies the given mapping function
  /// to the error value and returns a new AsyncResult with the mapped error.
  /// Otherwise, returns this AsyncResult unchanged (but with updated generic types).
  ///
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.error("error");
  /// final mapped = result.mapError((e) => Exception(e)); // AsyncResult<int, Exception>
  /// ```
  AsyncResult<T, F> mapError<F>(F Function(E error) mapper);

  /// Maps both success and error values simultaneously.
  ///
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.data(42);
  /// final mapped = result.bimap(
  ///   data: (i) => i.toString(),
  ///   error: (e) => Exception(e),
  /// );
  /// ```
  AsyncResult<R, F> bimap<R, F>({
    required R Function(T data) data,
    required F Function(E error) error,
  });

  /// Chains another AsyncResult-returning operation only if this instance contains data.
  ///
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.data(42);
  /// final chained = result.flatMap((data) => AsyncResult.data(data.toString()));
  /// ```
  AsyncResult<R, E> flatMap<R>(AsyncResult<R, E> Function(T data) mapper);

  /// Recovers from an error state by transforming the error into data.
  ///
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.error("Not found");
  /// final recovered = result.recover((error) => -1);
  /// ```
  AsyncResult<T, E> recover(T Function(E error) recovery);

  /// Returns true if the data value satisfies the given predicate.
  ///
  /// Returns false if this instance is not in the data state.
  ///
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.data(42);
  /// final isPositive = result.any((data) => data > 0); // true
  /// ```
  bool any(bool Function(T data) predicate) {
    return when(
      whenData: predicate,
      whenError: (_) => false,
      whenLoading: () => false,
      whenInitial: () => false,
    );
  }

  /// Creates a new AsyncResult with a transformed error, but only if it matches a condition.
  ///
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.error("Not found");
  /// final mapped = result.mapErrorWhere(
  ///   (e) => e.contains("not"),
  ///   (e) => "404: $e",
  /// );
  /// ```
  AsyncResult<T, E> mapErrorWhere(
    bool Function(E error) test,
    E Function(E error) mapper,
  ) {
    return when(
      whenData: (data) => AsyncResult.data(data),
      whenError: (error) => AsyncResult.error(
        test(error) ? mapper(error) : error,
      ),
      whenLoading: () => AsyncResult.loading(),
      whenInitial: () => AsyncResult.initial(),
    );
  }

  /// Creates a new AsyncResult with transformed data, but only if it matches a condition.
  ///
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.data(42);
  /// final mapped = result.mapWhere(
  ///   (i) => i > 0,
  ///   (i) => i * 2,
  /// );
  /// ```
  AsyncResult<T, E> mapWhere(
    bool Function(T data) test,
    T Function(T data) mapper,
  ) {
    return when(
      whenData: (data) => AsyncResult.data(
        test(data) ? mapper(data) : data,
      ),
      whenError: (error) => AsyncResult.error(error),
      whenLoading: () => AsyncResult.loading(),
      whenInitial: () => AsyncResult.initial(),
    );
  }

  @override
  String toString() => 'AsyncResult()';
}

/// Represents the initial state of an asynchronous operation.
final class AsyncInitial<T, E> extends AsyncResult<T, E> {
  const AsyncInitial() : super._();

  @override
  bool get isInitial => true;

  @override
  bool get isLoading => false;

  @override
  bool get hasError => false;

  @override
  bool get hasData => false;

  @override
  bool get isLoadingOrInitial => true;

  @override
  bool get isDateOrError => false;

  @override
  T? get dataOrNull => null;

  @override
  T get dataOrThrow => throw AsyncResultDataNoFoundedExceptions();

  @override
  E? get errorOrNull => null;

  @override
  E get errorOrThrow => throw AsyncResultErrorNoFoundedExceptions();

  @override
  T getDataOrElse(T defaultValue) => defaultValue;

  @override
  E getErrorOrElse(E defaultValue) => defaultValue;

  @override
  bool get isCompleted => false;

  @override
  R when<R>({
    required R Function() whenInitial,
    required R Function() whenLoading,
    required R Function(T data) whenData,
    required R Function(E error) whenError,
  }) =>
      whenInitial();

  @override
  R? whenError<R>(R Function(E error) whenError) => null;

  @override
  R? whenInitial<R>(R Function() whenInitial) => whenInitial();

  @override
  R? whenLoading<R>(R Function() whenLoading) => null;

  @override
  R? whenData<R>(R Function(T data) whenData) => null;

  @override
  R maybeWhen<R>({
    R Function()? whenInitial,
    R Function()? whenLoading,
    R Function(T data)? whenData,
    R Function(E error)? whenError,
    required R Function() orElse,
  }) =>
      whenInitial?.call() ?? orElse();

  @override
  R? whenOrNull<R>({
    R Function()? whenInitial,
    R Function()? whenLoading,
    R Function(T data)? whenData,
    R Function(E error)? whenError,
  }) =>
      whenInitial?.call();

  @override
  AsyncResult<R, E> map<R>(R Function(T data) mapper) =>
      AsyncResult<R, E>.initial();

  @override
  AsyncResult<T, F> mapError<F>(F Function(E error) mapper) =>
      AsyncResult<T, F>.initial();

  @override
  AsyncResult<R, F> bimap<R, F>({
    required R Function(T data) data,
    required F Function(E error) error,
  }) =>
      AsyncResult<R, F>.initial();

  @override
  AsyncResult<R, E> flatMap<R>(AsyncResult<R, E> Function(T data) mapper) =>
      AsyncResult<R, E>.initial();

  @override
  AsyncResult<T, E> recover(T Function(E error) recovery) =>
      AsyncResult<T, E>.initial();

  @override
  String toString() => 'AsyncInitial()';
}

/// Represents the loading state of an asynchronous operation.
final class AsyncLoading<T, E> extends AsyncResult<T, E> {
  const AsyncLoading() : super._();

  @override
  bool get isInitial => false;

  @override
  bool get isLoading => true;

  @override
  bool get hasError => false;

  @override
  bool get hasData => false;

  @override
  bool get isLoadingOrInitial => true;

  @override
  bool get isDateOrError => false;

  @override
  T? get dataOrNull => null;

  @override
  T get dataOrThrow => throw AsyncResultDataNoFoundedExceptions();

  @override
  E? get errorOrNull => null;

  @override
  E get errorOrThrow => throw AsyncResultErrorNoFoundedExceptions();

  @override
  T getDataOrElse(T defaultValue) => defaultValue;

  @override
  E getErrorOrElse(E defaultValue) => defaultValue;

  @override
  bool get isCompleted => false;

  @override
  R when<R>({
    required R Function() whenInitial,
    required R Function() whenLoading,
    required R Function(T data) whenData,
    required R Function(E error) whenError,
  }) =>
      whenLoading();

  @override
  R? whenError<R>(R Function(E error) whenError) => null;

  @override
  R? whenInitial<R>(R Function() whenInitial) => null;

  @override
  R? whenLoading<R>(R Function() whenLoading) => whenLoading();

  @override
  R? whenData<R>(R Function(T data) whenData) => null;

  @override
  R maybeWhen<R>({
    R Function()? whenInitial,
    R Function()? whenLoading,
    R Function(T data)? whenData,
    R Function(E error)? whenError,
    required R Function() orElse,
  }) =>
      whenLoading?.call() ?? orElse();

  @override
  R? whenOrNull<R>({
    R Function()? whenInitial,
    R Function()? whenLoading,
    R Function(T data)? whenData,
    R Function(E error)? whenError,
  }) =>
      whenLoading?.call();

  @override
  AsyncResult<R, E> map<R>(R Function(T data) mapper) =>
      AsyncResult<R, E>.loading();

  @override
  AsyncResult<T, F> mapError<F>(F Function(E error) mapper) =>
      AsyncResult<T, F>.loading();

  @override
  AsyncResult<R, F> bimap<R, F>({
    required R Function(T data) data,
    required F Function(E error) error,
  }) =>
      AsyncResult<R, F>.loading();

  @override
  AsyncResult<R, E> flatMap<R>(AsyncResult<R, E> Function(T data) mapper) =>
      AsyncResult<R, E>.loading();

  @override
  AsyncResult<T, E> recover(T Function(E error) recovery) =>
      AsyncResult<T, E>.loading();

  @override
  String toString() => 'AsyncLoading()';
}

/// Represents a successful state of an asynchronous operation with data.
final class AsyncData<T, E> extends AsyncResult<T, E> {
  const AsyncData(T data) : this._(data);
  const AsyncData._(this._data) : super._();

  final T _data;

  @override
  bool get isInitial => false;

  @override
  bool get isLoading => false;

  @override
  bool get hasError => false;

  @override
  bool get isLoadingOrInitial => false;

  @override
  bool get isDateOrError => true;

  @override
  bool get hasData => _data != null;

  @override
  T? get dataOrNull => _data;

  @override
  T get dataOrThrow => _data;

  @override
  E? get errorOrNull => null;

  @override
  E get errorOrThrow => throw AsyncResultErrorNoFoundedExceptions();

  @override
  T getDataOrElse(T defaultValue) => _data;

  @override
  E getErrorOrElse(E defaultValue) => defaultValue;

  @override
  bool get isCompleted => true;

  @override
  R when<R>({
    required R Function() whenInitial,
    required R Function() whenLoading,
    required R Function(T data) whenData,
    required R Function(E error) whenError,
  }) =>
      whenData(_data);

  @override
  R? whenError<R>(R Function(E error) whenError) => null;

  @override
  R? whenInitial<R>(R Function() whenInitial) => null;

  @override
  R? whenLoading<R>(R Function() whenLoading) => null;

  @override
  R? whenData<R>(R Function(T data) whenData) => whenData(_data);

  @override
  R? whenOrNull<R>({
    R Function()? whenInitial,
    R Function()? whenLoading,
    R Function(T data)? whenData,
    R Function(E error)? whenError,
  }) =>
      whenData?.call(_data);

  @override
  AsyncResult<R, E> map<R>(R Function(T data) mapper) =>
      AsyncResult<R, E>.data(mapper(_data));

  @override
  AsyncResult<T, F> mapError<F>(F Function(E error) mapper) =>
      AsyncResult<T, F>.data(_data);

  @override
  AsyncResult<R, F> bimap<R, F>({
    required R Function(T data) data,
    required F Function(E error) error,
  }) =>
      AsyncResult<R, F>.data(data(_data));

  @override
  AsyncResult<R, E> flatMap<R>(AsyncResult<R, E> Function(T data) mapper) =>
      mapper(_data);
  @override
  AsyncResult<T, E> recover(T Function(E error) recovery) =>
      AsyncResult<T, E>.data(_data);

  @override
  R maybeWhen<R>({
    R Function()? whenInitial,
    R Function()? whenLoading,
    R Function(T data)? whenData,
    R Function(E error)? whenError,
    required R Function() orElse,
  }) =>
      whenData?.call(_data) ?? orElse();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsyncData<T, E> &&
          runtimeType == other.runtimeType &&
          _data == other._data;

  @override
  int get hashCode => _data.hashCode;

  @override
  String toString() => 'AsyncData($_data)';
}

/// Represents an error state of an asynchronous operation.
final class AsyncError<T, E> extends AsyncResult<T, E> {
  const AsyncError(E failure) : this._(failure);
  const AsyncError._(this._error) : super._();

  final E _error;

  @override
  bool get isInitial => false;

  @override
  bool get isLoading => false;

  @override
  bool get hasError => true;

  @override
  bool get hasData => false;

  @override
  bool get isLoadingOrInitial => false;

  @override
  bool get isDateOrError => true;

  @override
  T? get dataOrNull => null;

  @override
  T get dataOrThrow => throw AsyncResultDataNoFoundedExceptions();

  @override
  E? get errorOrNull => _error;

  @override
  E get errorOrThrow => _error;

  @override
  T getDataOrElse(T defaultValue) => defaultValue;

  @override
  E getErrorOrElse(E defaultValue) => _error;

  @override
  bool get isCompleted => true;

  @override
  R when<R>({
    required R Function() whenInitial,
    required R Function() whenLoading,
    required R Function(T data) whenData,
    required R Function(E error) whenError,
  }) =>
      whenError(_error);

  @override
  R? whenError<R>(R Function(E error) whenError) => whenError(_error);

  @override
  R? whenInitial<R>(R Function() whenInitial) => null;

  @override
  R? whenLoading<R>(R Function() whenLoading) => null;

  @override
  R? whenData<R>(R Function(T data) whenData) => null;

  @override
  R maybeWhen<R>({
    R Function()? whenInitial,
    R Function()? whenLoading,
    R Function(T data)? whenData,
    R Function(E error)? whenError,
    required R Function() orElse,
  }) =>
      whenError?.call(_error) ?? orElse();

  @override
  R? whenOrNull<R>({
    R Function()? whenInitial,
    R Function()? whenLoading,
    R Function(T data)? whenData,
    R Function(E error)? whenError,
  }) =>
      whenError?.call(_error);

  @override
  AsyncResult<R, E> map<R>(R Function(T data) mapper) =>
      AsyncResult<R, E>.error(_error);

  @override
  AsyncResult<T, F> mapError<F>(F Function(E error) mapper) =>
      AsyncResult<T, F>.error(mapper(_error));

  @override
  AsyncResult<R, F> bimap<R, F>({
    required R Function(T data) data,
    required F Function(E error) error,
  }) =>
      AsyncResult<R, F>.error(error(_error));

  @override
  AsyncResult<R, E> flatMap<R>(AsyncResult<R, E> Function(T data) mapper) =>
      AsyncResult<R, E>.error(_error);

  @override
  AsyncResult<T, E> recover(T Function(E error) recovery) =>
      AsyncResult<T, E>.data(recovery(_error));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsyncError<T, E> &&
          runtimeType == other.runtimeType &&
          _error == other._error;

  @override
  int get hashCode => _error.hashCode;

  @override
  String toString() => 'AsyncError($_error)';
}
