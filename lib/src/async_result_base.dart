import 'async_result_exceptions.dart';

/// {@template async_result}
/// A sealed class representing the different states of an asynchronous operation.
///
/// [AsyncResult] provides a type-safe way to handle asynchronous operations that can
/// be in one of four states:
/// - [AsyncInitial]: The operation hasn't started yet
/// - [AsyncLoading]: The operation is in progress
/// - [AsyncData]: The operation completed successfully with data
/// - [AsyncError]: The operation failed with an error
///
/// Generic Parameters:
/// * [T] - The type of data when the operation succeeds
/// * [E] - The type of error when the operation fails
///
/// Example:
/// ```dart
/// AsyncResult<String, Exception> fetchUser() async {
///   try {
///     final user = await userRepository.getUser();
///     return AsyncResult.data(user);
///   } catch (e) {
///     return AsyncResult.error(e as Exception);
///   }
/// }
///
/// final result = await fetchUser();
/// result.when(
///   initial: () => print('Not started'),
///   loading: () => print('Loading...'),
///   data: (user) => print('User: $user'),
///   error: (error) => print('Error: $error'),
/// );
/// ```
///{@endtemplate}
sealed class AsyncResult<T, E> {
  /// {@macro async_result}
  const AsyncResult._();

  /// Creates an [AsyncResult] in the initial state.
  ///
  /// Use this to represent an operation that hasn't started yet.
  ///  /// Example:
  /// ```dart
  /// AsyncResult<String, Exception> result = AsyncResult.initial();
  /// print(result.isInitial); // output: true
  /// ```
  const factory AsyncResult.initial() = AsyncInitial<T, E>;

  /// Creates an [AsyncResult] in the loading state.
  ///
  /// Use this to represent an operation that is currently in progress.
  ///  /// Example:
  /// ```dart
  /// AsyncResult<String, Exception> result = AsyncResult.loading();
  /// print(result.isLoading); // output: true
  /// ```
  const factory AsyncResult.loading() = AsyncLoading<T, E>;

  /// Creates an [AsyncResult] in the success state with data.
  ///
  /// Use this to represent an operation that completed successfully.
  ///
  /// Parameters:
  /// * [data] - The successful result data
  ///  /// Example:
  /// ```dart
  /// AsyncResult<String, Exception> result = AsyncResult.data('Hello');
  /// print(result.isSuccess); // output: true
  /// print(result.dataOrThrow); // output: Hello
  /// ```
  const factory AsyncResult.data(T data) = AsyncData<T, E>;

  /// Creates an [AsyncResult] in the error state with an error.
  ///
  /// Use this to represent an operation that failed.
  ///
  /// Parameters:
  /// * [error] - The error that occurred
  ///
  /// Example:
  /// ```dart
  /// AsyncResult<String, Exception> result = AsyncResult.error(Exception('Failed'));
  /// print(result.isError); // true
  /// print(result.errorOrThrow is Exception); // true
  /// ```
  const factory AsyncResult.error(E error) = AsyncError<T, E>;

  /// Converts from Json.
  ///
  /// Json serialization support for `json_serializable` with `@JsonSerializable`.
  /// This factory method allows you to create an [AsyncResult] from a JSON object.
  /// It expects the JSON to represent a successful data state.
  /// If the JSON is null or cannot be parsed, it returns an initial state.
  factory AsyncResult.fromJson(
    dynamic json,
    T Function(dynamic json) fromJsonT,
  ) {
    if (json != null) {
      try {
        return AsyncResult.data(fromJsonT(json));
      } catch (e) {
        return AsyncResult.initial();
      }
    }
    return AsyncResult.initial();
  }

  /// Converts to Json.
  ///
  /// Json serialization support for `json_serializable` with `@JsonSerializable`.
  /// This method allows you to convert an [AsyncResult] instance to a JSON object.
  Object? toJson(Object? Function(T data) toJsonT);

  /// Checks if all results in the iterable are completed (either success or error).
  ///
  /// Parameters:
  /// * [iterable] - Collection of AsyncResult instances to check
  ///
  /// Returns `true` if all results are either in success or error state.
  ///
  /// Example:
  /// ```dart
  /// final results = [
  ///   AsyncResult<int, String>.data(1),
  ///   AsyncResult<int, String>.error('failed'),
  /// ];
  /// print(AsyncResult.allComplete(results)); // output: false
  /// ```
  static bool allComplete<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    return iterable.every((result) => result.isCompleted);
  }

  /// Checks if all results in the iterable are successful.
  ///
  /// Parameters:
  /// * [iterable] - Collection of AsyncResult instances to check
  ///
  /// Returns `true` only if all results are in success state.
  ///
  /// Example:
  /// ```dart
  /// final results = [
  ///   AsyncResult<int, String>.data(1),
  ///   AsyncResult<int, String>.data(2),
  /// ];
  /// print(AsyncResult.allSuccess(results)); // output: true
  /// ```
  static bool allSuccess<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    return iterable.every((result) => result.isSuccess);
  }

  /// Checks if all results in the iterable are in error state.
  ///
  /// Parameters:
  /// * [iterable] - Collection of AsyncResult instances to check
  ///
  /// Returns `true` only if all results are in error state.
  ///
  /// Example:
  /// ```dart
  /// final results = [
  ///   AsyncResult<int, String>.error('failed1'),
  ///   AsyncResult<int, String>.error('failed2'),
  /// ];
  /// print(AsyncResult.allError(results)); // output: true
  /// ```
  static bool allError<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    return iterable.every((result) => result.isError);
  }

  /// Checks if any result in the iterable is in error state.
  ///
  /// Parameters:
  /// * [iterable] - Collection of AsyncResult instances to check
  ///
  /// Returns `true` if at least one result is in error state.
  ///
  /// Example:
  /// ```dart
  /// final results = [
  ///   AsyncResult<int, String>.data(1),
  ///   AsyncResult<int, String>.error('failed'),
  /// ];
  /// print(AsyncResult.anyError(results)); // output: true
  /// ```
  static bool anyError<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    return iterable.any((result) => result.isError);
  }

  /// Checks if any result in the iterable is in loading state.
  ///
  /// Parameters:
  /// * [iterable] - Collection of AsyncResult instances to check
  ///
  /// Returns `true` if at least one result is in loading state.
  ///
  /// Example:
  /// ```dart
  /// final results = [
  ///   AsyncResult<int, String>.data(1),
  ///   AsyncResult<int, String>.loading(),
  /// ];
  /// print(AsyncResult.anyLoading(results)); // output: true
  /// ```
  static bool anyLoading<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    return iterable.any((result) => result.isLoading);
  }

  /// Checks if any result in the iterable is completed (either success or error).
  ///
  /// Parameters:
  /// * [iterable] - Collection of AsyncResult instances to check
  ///
  /// Returns `true` if at least one result is completed (success or error state).
  ///
  /// Example:
  /// ```dart
  /// final results = [
  ///   AsyncResult<int, String>.initial(),
  ///   AsyncResult<int, String>.data(1),
  /// ];
  /// print(AsyncResult.anyComplete(results)); // output: true
  /// ```
  static bool anyComplete<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    return iterable.any((result) => result.isCompleted);
  }

  /// Checks if any result in the iterable is in success state.
  ///
  /// Parameters:
  /// * [iterable] - Collection of AsyncResult instances to check
  ///
  /// Returns `true` if at least one result is in success state.
  ///
  /// Example:
  /// ```dart
  /// final results = [
  ///   AsyncResult<int, String>.error('failed'),
  ///   AsyncResult<int, String>.data(1),
  /// ];
  /// print(AsyncResult.anySuccess(results)); // output: true
  /// ```
  static bool anySuccess<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    return iterable.any((result) => result.isSuccess);
  }

  /// Extracts all data values from successful results in the iterable.
  ///
  /// Parameters:
  /// * [iterable] - Collection of AsyncResult instances to extract data from
  ///
  /// Returns an iterable of data values from all successful results.
  /// Results in other states are ignored.
  ///
  /// Example:
  /// ```dart
  /// final results = [
  ///   AsyncResult<int, String>.data(1),
  ///   AsyncResult<int, String>.error('failed'),
  ///   AsyncResult<int, String>.data(2),
  /// ];
  /// final data = AsyncResult.getAllData(results).toList();
  /// print(data); // output: [1, 2]
  /// ```
  static Iterable<T> getAllData<T, E>(
      Iterable<AsyncResult<T, E>> iterable) sync* {
    for (var result in iterable) {
      if (result.isSuccess) {
        yield result.dataOrThrow;
      }
    }
  }

  /// Extracts all error values from failed results in the iterable.
  ///
  /// Parameters:
  /// * [iterable] - Collection of AsyncResult instances to extract errors from
  ///
  /// Returns an iterable of error values from all failed results.
  /// Results in other states are ignored.
  ///
  /// Example:
  /// ```dart
  /// final results = [
  ///   AsyncResult<int, String>.data(1),
  ///   AsyncResult<int, String>.error('failed1'),
  ///   AsyncResult<int, String>.error('failed2'),
  /// ];
  /// final errors = AsyncResult.getAllError(results).toList();
  /// print(errors); // output: [failed1, failed2]
  /// ```
  static Iterable<E> getAllError<T, E>(
      Iterable<AsyncResult<T, E>> iterable) sync* {
    for (var result in iterable) {
      if (result.isError) {
        yield result.errorOrThrow;
      }
    }
  }

  /// Returns the first error found in the iterable, or null if none exist.
  ///
  /// Parameters:
  /// * [iterable] - Collection of AsyncResult instances to search
  ///
  /// Returns the error value of the first result in error state, or null if no errors.
  ///
  /// Example:
  /// ```dart
  /// final results = [
  ///   AsyncResult<int, String>.data(1),
  ///   AsyncResult<int, String>.error('first_error'),
  ///   AsyncResult<int, String>.error('second_error'),
  /// ];
  /// final firstError = AsyncResult.getFirstError(results);
  /// print(firstError); // output: first_error
  /// ```
  static E? getFirstError<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    for (var result in iterable) {
      if (result.isError) {
        return result.errorOrNull;
      }
    }
    return null;
  }

  /// Returns the first data found in the iterable, or null if none exist.
  ///
  /// Parameters:
  /// * [iterable] - Collection of AsyncResult instances to search
  ///
  /// Returns the data value of the first result in success state, or null if no data.
  ///
  /// Example:
  /// ```dart
  /// final results = [
  ///   AsyncResult<int, String>.error('failed'),
  ///   AsyncResult<int, String>.data(42),
  ///   AsyncResult<int, String>.data(100),
  /// ];
  /// final firstData = AsyncResult.getFirstData(results);
  /// print(firstData); // output: 42
  /// ```
  static T? getFirstData<T, E>(Iterable<AsyncResult<T, E>> iterable) {
    for (var result in iterable) {
      if (result.isSuccess) {
        return result.dataOrNull;
      }
    }
    return null;
  }

  /// Combines two AsyncResult instances into a single result containing a record.
  ///
  /// The combination follows these rules:
  /// - If any result is in error state, returns the first error
  /// - If any result is loading, returns loading state
  /// - If both results have data, returns data with a record containing both values
  /// - Otherwise, returns initial state
  ///
  /// Parameters:
  /// * [result1] - First AsyncResult to combine
  /// * [result2] - Second AsyncResult to combine
  ///
  /// Returns an AsyncResult containing a record with named fields 'first' and 'second'.
  ///
  /// Example:
  /// ```dart
  /// final result1 = AsyncResult<int, String>.data(42);
  /// final result2 = AsyncResult<String, String>.data('hello');
  /// final combined = AsyncResult.combine2(result1, result2);
  /// print(combined.dataOrThrow.first); // output: 42
  /// print(combined.dataOrThrow.second); // output: hello
  /// ```
  static AsyncResult<({T first, U second}), E> combine2<T, U, E>(
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
    if (result1.isSuccess && result2.isSuccess) {
      return AsyncResult.data(
        (first: result1.dataOrThrow, second: result2.dataOrThrow),
      );
    }

    // If none of the above, return initial
    return AsyncResult.initial();
  }

  /// Combines three AsyncResult instances into a single result containing a record.
  ///
  /// The combination follows these rules:
  /// - If any result is in error state, returns the first error
  /// - If any result is loading, returns loading state
  /// - If all results have data, returns data with a record containing all values
  /// - Otherwise, returns initial state
  ///
  /// Parameters:
  /// * [result1] - First AsyncResult to combine
  /// * [result2] - Second AsyncResult to combine
  /// * [result3] - Third AsyncResult to combine
  ///
  /// Returns an AsyncResult containing a record with named fields 'first', 'second', and 'third'.
  ///
  /// Example:
  /// ```dart
  /// final result1 = AsyncResult<int, String>.data(1);
  /// final result2 = AsyncResult<int, String>.data(2);
  /// final result3 = AsyncResult<int, String>.data(3);
  /// final combined = AsyncResult.combine3(result1, result2, result3);
  /// print(combined.dataOrThrow.first); // output: 1
  /// print(combined.dataOrThrow.second); // output: 2
  /// print(combined.dataOrThrow.third); // output: 3
  /// ```
  static AsyncResult<({T first, U second, V third}), E> combine3<T, U, V, E>(
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
    if (result1.isSuccess && result2.isSuccess && result3.isSuccess) {
      return AsyncResult.data((
        first: result1.dataOrThrow,
        second: result2.dataOrThrow,
        third: result3.dataOrThrow
      ));
    }

    // If none of the above, return initial
    return AsyncResult.initial();
  }

  /// Combines four AsyncResult instances into a single result containing a record.
  ///
  /// The combination follows these rules:
  /// - If any result is in error state, returns the first error
  /// - If any result is loading, returns loading state
  /// - If all results have data, returns data with a record containing all values
  /// - Otherwise, returns initial state
  ///
  /// Parameters:
  /// * [result1] - First AsyncResult to combine
  /// * [result2] - Second AsyncResult to combine
  /// * [result3] - Third AsyncResult to combine
  /// * [result4] - Fourth AsyncResult to combine
  ///
  /// Returns an AsyncResult containing a record with named fields 'first', 'second', 'third', and 'fourth'.
  ///
  /// Example:
  /// ```dart
  /// final result1 = AsyncResult<int, String>.data(1);
  /// final result2 = AsyncResult<int, String>.data(2);
  /// final result3 = AsyncResult<int, String>.data(3);
  /// final result4 = AsyncResult<int, String>.data(4);
  /// final combined = AsyncResult.combine4(result1, result2, result3, result4);
  /// print(combined.dataOrThrow.fourth); // output: 4
  /// ```
  static AsyncResult<({T first, U second, V third, W fourth}), E>
      combine4<T, U, V, W, E>(
    AsyncResult<T, E> result1,
    AsyncResult<U, E> result2,
    AsyncResult<V, E> result3,
    AsyncResult<W, E> result4,
  ) {
    // Check error state
    if (result1.isError) return AsyncResult.error(result1.errorOrThrow);
    if (result2.isError) return AsyncResult.error(result2.errorOrThrow);
    if (result3.isError) return AsyncResult.error(result3.errorOrThrow);
    if (result4.isError) return AsyncResult.error(result4.errorOrThrow);

    // Check loading state first
    if (result1.isLoading ||
        result2.isLoading ||
        result3.isLoading ||
        result4.isLoading) {
      return AsyncResult.loading();
    }

    // Check data state
    if (result1.isSuccess &&
        result2.isSuccess &&
        result3.isSuccess &&
        result4.isSuccess) {
      return AsyncResult.data((
        first: result1.dataOrThrow,
        second: result2.dataOrThrow,
        third: result3.dataOrThrow,
        fourth: result4.dataOrThrow
      ));
    }

    // If none of the above, return initial
    return AsyncResult.initial();
  }

  /// Combines five AsyncResult instances into a single result containing a record.
  ///
  /// The combination follows these rules:
  /// - If any result is in error state, returns the first error
  /// - If any result is loading, returns loading state
  /// - If all results have data, returns data with a record containing all values
  /// - Otherwise, returns initial state
  ///
  /// Parameters:
  /// * [result1] - First AsyncResult to combine
  /// * [result2] - Second AsyncResult to combine
  /// * [result3] - Third AsyncResult to combine
  /// * [result4] - Fourth AsyncResult to combine
  /// * [result5] - Fifth AsyncResult to combine
  ///
  /// Returns an AsyncResult containing a record with named fields 'first', 'second', 'third', 'fourth', and 'fifth'.
  ///
  /// Example:
  /// ```dart
  /// final result1 = AsyncResult<int, String>.data(1);
  /// final result2 = AsyncResult<int, String>.data(2);
  /// final result3 = AsyncResult<int, String>.data(3);
  /// final result4 = AsyncResult<int, String>.data(4);
  /// final result5 = AsyncResult<int, String>.data(5);
  /// final combined = AsyncResult.combine5(result1, result2, result3, result4, result5);
  /// print(combined.dataOrThrow.fifth); // output: 5
  /// ```
  static AsyncResult<({T first, U second, V third, W fourth, X fifth}), E>
      combine5<T, U, V, W, X, E>(
    AsyncResult<T, E> result1,
    AsyncResult<U, E> result2,
    AsyncResult<V, E> result3,
    AsyncResult<W, E> result4,
    AsyncResult<X, E> result5,
  ) {
    // Check error state
    if (result1.isError) return AsyncResult.error(result1.errorOrThrow);
    if (result2.isError) return AsyncResult.error(result2.errorOrThrow);
    if (result3.isError) return AsyncResult.error(result3.errorOrThrow);
    if (result4.isError) return AsyncResult.error(result4.errorOrThrow);
    if (result5.isError) return AsyncResult.error(result5.errorOrThrow);

    // Check loading state first
    if (result1.isLoading ||
        result2.isLoading ||
        result3.isLoading ||
        result4.isLoading ||
        result5.isLoading) {
      return AsyncResult.loading();
    }

    // Check data state
    if (result1.isSuccess &&
        result2.isSuccess &&
        result3.isSuccess &&
        result4.isSuccess &&
        result5.isSuccess) {
      return AsyncResult.data((
        first: result1.dataOrThrow,
        second: result2.dataOrThrow,
        third: result3.dataOrThrow,
        fourth: result4.dataOrThrow,
        fifth: result5.dataOrThrow
      ));
    }

    // If none of the above, return initial
    return AsyncResult.initial();
  }

  /// Combines multiple AsyncResult instances from an iterable into a single result containing a list.
  ///
  /// The combination follows these rules:
  /// - If any result is in error state, returns the first error
  /// - If any result is loading, returns loading state
  /// - If all results have data, returns data with a list containing all values
  /// - Otherwise, returns initial state
  ///
  /// Parameters:
  /// * [results] - Iterable of AsyncResult instances to combine
  ///
  /// Returns an AsyncResult containing a list of all data values in the same order.
  ///
  /// Example:
  /// ```dart
  /// final results = [
  ///   AsyncResult<int, String>.data(1),
  ///   AsyncResult<int, String>.data(2),
  ///   AsyncResult<int, String>.data(3),
  /// ];
  /// final combined = AsyncResult.combineIterable(results);
  /// print(combined.dataOrThrow); // output: [1, 2, 3]
  /// ```
  static AsyncResult<List<dynamic>, E> combineIterable<E>(
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
    if (results.every((result) => result.isSuccess)) {
      return AsyncResult.data(
        results.map((result) => result.dataOrNull).toList(),
      );
    }

    // If none of the above, return initial
    return AsyncResult.initial();
  }

  /// Returns `true` if this result is in the initial state.
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.initial();
  /// print(result.isInitial); // output: true
  /// ```
  bool get isInitial;

  /// Returns `true` if this result is in the loading state.
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.loading();
  /// print(result.isLoading); // output: true
  /// ```
  bool get isLoading;

  /// Returns `true` if this result is in the success state with data.
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.data(42);
  /// print(result.isSuccess); // output: true
  /// ```
  bool get isSuccess;

  /// Returns `true` if this result is in the error state.
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.error('failed');
  /// print(result.isError); // output: true
  /// ```
  bool get isError;

  /// Alias for [isError]. Returns `true` if this result has an error.
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.error('failed');
  /// print(result.hasError); // output: true
  /// ```
  bool get hasError => isError;

  /// Alias for [isSuccess]. Returns `true` if this result has data.
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.data(42);
  /// print(result.hasData); // output: true
  /// ```
  bool get hasData => isSuccess;

  /// Returns `true` if this result is either loading or initial.
  ///
  /// Useful for checking if an operation is not yet completed.
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.loading();
  /// print(result.isLoadingOrInitial); // output: true
  /// ```
  bool get isLoadingOrInitial => isLoading || isInitial;

  /// Returns `true` if this result has either data or an error.
  ///
  /// Useful for checking if an operation has completed.
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.data(42);
  /// print(result.isDataOrError); // output: true
  /// ```
  bool get isDataOrError => isSuccess || isError;

  /// Returns `true` if this result is completed (either success or error).
  ///
  /// Alias for [isDataOrError].
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.data(42);
  /// print(result.isCompleted); // output: true
  /// ```
  bool get isCompleted => isSuccess || isError;

  /// Returns the data if successful, otherwise returns `null`.
  ///
  /// This is a safe way to access data without throwing exceptions.
  /// Example:
  /// ```dart
  /// final success = AsyncResult<int, String>.data(42);
  /// final error = AsyncResult<int, String>.error('failed');
  ///
  /// print(success.dataOrNull); // output: 42
  /// print(error.dataOrNull); // output: null
  /// ```
  T? get dataOrNull;

  /// Returns data if present, otherwise throws the error.
  /// ***Note***: Always check `isSuccess` before using this getter to avoid errors.
  /// If you're unsure about the state, consider using `dataOrNull` instead which
  /// returns `null` when the result is not successful.
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.data(42);
  /// final data = result.dataOrThrow; // 42
  /// final errorResult = AsyncResult<int, String>.error("Error");
  /// final data = errorResult.dataOrThrow; // Throws AsyncResultDataNotFoundException
  /// /// If you're unsure about the state, use:
  /// final data = result.dataOrNull; // null if not successful
  /// //or check isSuccess before accessing dataOrThrow
  /// if (result.isSuccess) {
  ///  final data = result.dataOrThrow; // 42
  /// }
  /// ```
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

  /// Transforms this result by applying different functions based on its state.
  ///
  /// This is the primary way to handle all possible states of an AsyncResult.
  /// All cases must be handled.
  ///
  /// Parameters:
  /// * [initial] - Function to call when in initial state
  /// * [loading] - Function to call when in loading state
  /// * [data] - Function to call when successful with data
  /// * [error] - Function to call when in error state
  ///  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.data(42);
  /// final message = result.when(
  ///   initial: () => 'Not started',
  ///   loading: () => 'Loading...',
  ///   data: (value) => 'Got: $value',
  ///   error: (err) => 'Error: $err',
  /// );
  /// print(message); // output: Got: 42
  /// ```
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(E error) error,
  });

  /// Like [when] but with optional handlers and a required fallback.
  ///
  /// Only the states you care about need to be handled, with [orElse]
  /// called for unhandled states.
  ///
  /// Parameters:
  /// * [initial] - Optional function for initial state
  /// * [loading] - Optional function for loading state
  /// * [data] - Optional function for success state
  /// * [error] - Optional function for error state
  /// * [orElse] - Required fallback for unhandled states
  ///
  /// Example:
  /// ```dart  /// final result = AsyncResult<int, String>.data(42);
  /// final value = result.maybeWhen(
  ///   data: (value) => value * 2,
  ///   orElse: () => 0,
  /// );
  /// print(value); // output: 84
  /// ```
  R maybeWhen<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? data,
    R Function(E error)? error,
    required R Function() orElse,
  });

  R? whenInitial<R>(R Function() whenInitial);

  R? whenLoading<R>(R Function() whenLoading);

  R? whenData<R>(R Function(T data) whenData);

  R? whenError<R>(R Function(E error) whenError);

  R? whenOrNull<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? data,
    R Function(E error)? error,
  });

  /// Transforms the data if successful, preserving other states.
  ///
  /// If this result contains data, applies [mapper] to transform it.
  /// Otherwise, returns a new result with the same state.
  ///
  /// Parameters:
  /// * [mapper] - Function to transform the data
  ///  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.data(21);
  /// final doubled = result.map((x) => x * 2);
  /// print(doubled.dataOrThrow); // output: 42
  /// ```
  AsyncResult<R, E> map<R>(R Function(T data) mapper);

  /// Transforms the error if present, preserving other states.
  ///
  /// If this result contains an error, applies [mapper] to transform it.
  /// Otherwise, returns a new result with the same state.
  ///
  /// Parameters:
  /// * [mapper] - Function to transform the error
  ///
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.error('failed');  /// final mapped = result.mapError((err) => 'Error: $err');
  /// print(mapped.errorOrThrow); // output: Error: failed
  /// ```
  AsyncResult<T, F> mapError<F>(F Function(E error) mapper);

  /// Transforms both data and error with different functions.
  ///
  /// Applies the appropriate mapper based on the current state.
  /// Loading and initial states are preserved.
  ///
  /// Parameters:
  /// * [data] - Function to transform success data
  /// * [error] - Function to transform error
  ///
  /// Example:
  /// ```dart  /// final result = AsyncResult<int, String>.data(42);
  /// final mapped = result.bimap(
  ///   data: (x) => x.toString(),
  ///   error: (err) => err.length,
  /// );
  /// print(mapped.dataOrThrow); // output: 42
  /// ```
  AsyncResult<R, F> bimap<R, F>({
    required R Function(T data) data,
    required F Function(E error) error,
  });

  /// Chains another AsyncResult-returning operation on the data.
  ///
  /// If this result contains data, applies [mapper] and returns the result.
  /// Otherwise, returns a new result with the same state.
  ///
  /// This is useful for chaining operations that themselves return AsyncResult.
  ///
  /// Parameters:
  /// * [mapper] - Function that returns another AsyncResult
  ///
  /// Example:
  /// ```dart
  /// AsyncResult<String, String> parseAndValidate(int x) {
  ///   if (x > 0) return AsyncResult.data(x.toString());
  ///   return AsyncResult.error('Invalid');
  /// }
  ///
  /// final result = AsyncResult<int, String>.data(42);
  /// final chained = result.flatMap(parseAndValidate);
  /// print(chained.dataOrThrow); // output: 42
  /// ```
  AsyncResult<R, E> flatMap<R>(AsyncResult<R, E> Function(T data) mapper);

  /// Recovers from an error by converting it to data.
  ///
  /// If this result contains an error, applies [recovery] to convert it to data.
  /// Otherwise, returns the result unchanged.
  ///
  /// Parameters:
  /// * [recovery] - Function to convert error to data
  ///  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.error('failed');
  /// final recovered = result.recover((err) => -1);
  /// print(recovered.dataOrThrow); // output: -1
  /// ```
  AsyncResult<T, E> recover(T Function(E error) recovery);

  /// Tests if the data satisfies a predicate.
  ///
  /// Returns `true` only if this result contains data and the predicate returns `true`.
  /// Returns `false` for all other states.
  ///
  /// Parameters:
  /// * [predicate] - Function to test the data
  ///
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.data(42);  /// print(result.any((x) => x > 40)); // output: true
  /// print(result.any((x) => x < 40)); // output: false
  /// ```
  bool any(bool Function(T data) predicate);

  /// Conditionally transforms the error.
  ///
  /// If this result contains an error that satisfies [test], applies [mapper].
  /// Otherwise, returns the result unchanged.
  ///
  /// Parameters:
  /// * [test] - Predicate to test the error
  /// * [mapper] - Function to transform the error
  ///
  /// Example:
  /// ```dart  /// final result = AsyncResult<int, String>.error('network_error');
  /// final mapped = result.mapErrorWhere(
  ///   (err) => err.startsWith('network'),
  ///   (err) => 'Connection failed',
  /// );
  /// print(mapped.errorOrThrow); // output: Connection failed
  /// ```
  AsyncResult<T, E> mapErrorWhere(
    bool Function(E error) test,
    E Function(E error) mapper,
  );

  /// Conditionally transforms the data.
  ///
  /// If this result contains data that satisfies [test], applies [mapper].
  /// Otherwise, returns the result unchanged.
  ///
  /// Parameters:
  /// * [test] - Predicate to test the data
  /// * [mapper] - Function to transform the data
  ///
  /// Example:
  /// ```dart  /// final result = AsyncResult<int, String>.data(42);
  /// final mapped = result.mapWhere(
  ///   (x) => x > 40,
  ///   (x) => x * 2,
  /// );
  /// print(mapped.dataOrThrow); // output: 84
  /// ```
  AsyncResult<T, E> mapWhere(
    bool Function(T data) test,
    T Function(T data) mapper,
  );

  /// Validates the data and converts to error if invalid.
  ///
  /// If this result contains data that fails [predicate], converts it to an error
  /// using [errorBuilder]. Otherwise, returns the result unchanged.
  ///
  /// Parameters:
  /// * [predicate] - Function to validate the data
  /// * [errorBuilder] - Function to create error from invalid data
  ///  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.data(-5);
  /// final validated = result.validate(
  ///   (x) => x >= 0,
  ///   (x) => 'Negative number: $x',
  /// );
  /// print(validated.errorOrThrow); // output: Negative number: -5
  /// ```
  AsyncResult<T, E> validate(
    bool Function(T data) predicate,
    E Function(T data) errorBuilder,
  );

  /// Swaps success and error types.
  ///
  /// Converts successful results to errors and vice versa.
  /// Loading and initial states are preserved.
  ///
  /// This can be useful when you want to handle success as an error condition.
  ///  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.data(42);
  /// final swapped = result.swap();
  /// print(swapped.errorOrThrow); // output: 42
  /// ```
  AsyncResult<E, T> swap();

  /// Filters the data based on a predicate.
  ///
  /// If this result contains data that satisfies [predicate], returns it unchanged.
  /// If the data fails the predicate, converts to an error using [errorBuilder].
  /// Other states are preserved.
  ///
  /// Parameters:
  /// * [predicate] - Function to test the data
  /// * [errorBuilder] - Function to create error for filtered data
  ///
  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.data(42);  /// final filtered = result.filter(
  ///   (x) => x > 50,
  ///   () => 'Value too small',
  /// );
  /// print(filtered.errorOrThrow); // output: Value too small
  /// ```
  AsyncResult<T, E> filter(
    bool Function(T data) predicate,
    E Function() errorBuilder,
  );

  /// Executes a side effect based on the current state.
  ///
  /// This allows you to perform actions (like logging) without changing the result.
  /// Returns the original result unchanged.
  ///
  /// Parameters:
  /// * [onData] - Optional action to perform on success data
  /// * [onError] - Optional action to perform on error
  /// * [onLoading] - Optional action to perform when loading
  /// * [onInitial] - Optional action to perform when initial
  ///  /// Example:
  /// ```dart
  /// final result = AsyncResult<int, String>.data(42);
  /// final same = result.tap(
  ///   onData: (data) => print('Got data: $data'),
  ///   onError: (error) => print('Got error: $error'),
  /// );
  /// print(identical(result, same)); // output: true (Returns the same instance)
  /// ```
  AsyncResult<T, E> tap({
    void Function(T data)? onData,
    void Function(E error)? onError,
    void Function()? onLoading,
    void Function()? onInitial,
  });

  @override
  String toString() {
    return when(
      initial: () => 'AsyncResult.initial()',
      loading: () => 'AsyncResult.loading()',
      data: (data) => 'AsyncResult.data($data)',
      error: (error) => 'AsyncResult.error($error)',
    );
  }
}

/// Represents the initial state of an asynchronous operation.
final class AsyncInitial<T, E> extends AsyncResult<T, E> {
  const AsyncInitial() : super._();

  @override
  bool get isInitial => true;

  @override
  bool get isLoading => false;

  @override
  bool get isError => false;

  @override
  bool get isSuccess => false;

  @override
  T? get dataOrNull => null;

  @override
  T get dataOrThrow => throw AsyncResultDataNotFoundException<T, E>();

  @override
  E? get errorOrNull => null;

  @override
  E get errorOrThrow => throw AsyncResultErrorNotFoundException<T, E>();

  @override
  T getDataOrElse(T defaultValue) => defaultValue;

  @override
  E getErrorOrElse(E defaultValue) => defaultValue;

  @override
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(E error) error,
  }) =>
      initial();

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
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? data,
    R Function(E error)? error,
    required R Function() orElse,
  }) =>
      initial?.call() ?? orElse();

  @override
  R? whenOrNull<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? data,
    R Function(E error)? error,
  }) =>
      initial?.call();

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
  bool any(bool Function(T data) predicate) => false;

  @override
  AsyncResult<T, E> mapErrorWhere(
    bool Function(E error) test,
    E Function(E error) mapper,
  ) =>
      AsyncResult<T, E>.initial();

  @override
  AsyncResult<T, E> mapWhere(
    bool Function(T data) test,
    T Function(T data) mapper,
  ) =>
      AsyncResult<T, E>.initial();

  @override
  AsyncResult<T, E> validate(
    bool Function(T data) predicate,
    E Function(T data) errorBuilder,
  ) =>
      AsyncResult<T, E>.initial();

  @override
  AsyncResult<E, T> swap() => AsyncResult<E, T>.initial();

  @override
  AsyncResult<T, E> filter(
    bool Function(T data) predicate,
    E Function() errorBuilder,
  ) =>
      AsyncResult<T, E>.initial();

  @override
  AsyncResult<T, E> tap({
    void Function(T data)? onData,
    void Function(E error)? onError,
    void Function()? onLoading,
    void Function()? onInitial,
  }) {
    onInitial?.call();
    return this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsyncInitial<T, E> && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  Object? toJson(Object? Function(T data) toJsonT) => null;
}

/// Represents the loading state of an asynchronous operation.
final class AsyncLoading<T, E> extends AsyncResult<T, E> {
  const AsyncLoading() : super._();

  @override
  bool get isInitial => false;

  @override
  bool get isLoading => true;

  @override
  bool get isError => false;

  @override
  bool get isSuccess => false;

  @override
  T? get dataOrNull => null;

  @override
  T get dataOrThrow => throw AsyncResultDataNotFoundException<T, E>();

  @override
  E? get errorOrNull => null;

  @override
  E get errorOrThrow => throw AsyncResultErrorNotFoundException<T, E>();

  @override
  T getDataOrElse(T defaultValue) => defaultValue;

  @override
  E getErrorOrElse(E defaultValue) => defaultValue;

  @override
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(E error) error,
  }) =>
      loading();

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
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? data,
    R Function(E error)? error,
    required R Function() orElse,
  }) =>
      loading?.call() ?? orElse();

  @override
  R? whenOrNull<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? data,
    R Function(E error)? error,
  }) =>
      loading?.call();

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
  bool any(bool Function(T data) predicate) => false;

  @override
  AsyncResult<T, E> mapErrorWhere(
    bool Function(E error) test,
    E Function(E error) mapper,
  ) =>
      AsyncResult<T, E>.loading();

  @override
  AsyncResult<T, E> mapWhere(
    bool Function(T data) test,
    T Function(T data) mapper,
  ) =>
      AsyncResult<T, E>.loading();

  @override
  AsyncResult<T, E> validate(
    bool Function(T data) predicate,
    E Function(T data) errorBuilder,
  ) =>
      AsyncResult<T, E>.loading();

  @override
  AsyncResult<E, T> swap() => AsyncResult<E, T>.loading();

  @override
  AsyncResult<T, E> filter(
    bool Function(T data) predicate,
    E Function() errorBuilder,
  ) =>
      AsyncResult<T, E>.loading();

  @override
  AsyncResult<T, E> tap({
    void Function(T data)? onData,
    void Function(E error)? onError,
    void Function()? onLoading,
    void Function()? onInitial,
  }) {
    onLoading?.call();
    return this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsyncLoading<T, E> && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  Object? toJson(Object? Function(T data) toJsonT) => null;
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
  bool get isError => false;

  @override
  bool get isSuccess => true;

  @override
  T? get dataOrNull => _data;

  @override
  T get dataOrThrow => _data;

  @override
  E? get errorOrNull => null;

  @override
  E get errorOrThrow => throw AsyncResultErrorNotFoundException<T, E>();

  @override
  T getDataOrElse(T defaultValue) => _data;

  @override
  E getErrorOrElse(E defaultValue) => defaultValue;

  @override
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(E error) error,
  }) =>
      data(_data);

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
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? data,
    R Function(E error)? error,
  }) =>
      data?.call(_data);

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
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? data,
    R Function(E error)? error,
    required R Function() orElse,
  }) =>
      data?.call(_data) ?? orElse();

  @override
  bool any(bool Function(T data) predicate) => predicate(_data);

  @override
  AsyncResult<T, E> mapErrorWhere(
    bool Function(E error) test,
    E Function(E error) mapper,
  ) =>
      AsyncResult<T, E>.data(_data);

  @override
  AsyncResult<T, E> mapWhere(
    bool Function(T data) test,
    T Function(T data) mapper,
  ) =>
      AsyncResult<T, E>.data(
        test(_data) ? mapper(_data) : _data,
      );

  @override
  AsyncResult<T, E> validate(
    bool Function(T data) predicate,
    E Function(T data) errorBuilder,
  ) =>
      predicate(_data)
          ? AsyncResult<T, E>.data(_data)
          : AsyncResult<T, E>.error(errorBuilder(_data));

  @override
  AsyncResult<E, T> swap() => AsyncResult<E, T>.error(_data);

  @override
  AsyncResult<T, E> filter(
    bool Function(T data) predicate,
    E Function() errorBuilder,
  ) =>
      predicate(_data)
          ? AsyncResult<T, E>.data(_data)
          : AsyncResult<T, E>.error(errorBuilder());

  @override
  AsyncResult<T, E> tap({
    void Function(T data)? onData,
    void Function(E error)? onError,
    void Function()? onLoading,
    void Function()? onInitial,
  }) {
    onData?.call(_data);
    return this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsyncData<T, E> &&
          runtimeType == other.runtimeType &&
          _data == other._data;

  @override
  int get hashCode => _data.hashCode;

  @override
  Object? toJson(Object? Function(T data) toJsonT) => toJsonT(_data);
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
  bool get isError => true;

  @override
  bool get isSuccess => false;

  @override
  T? get dataOrNull => null;

  @override
  T get dataOrThrow => throw AsyncResultDataNotFoundException<T, E>();

  @override
  E? get errorOrNull => _error;

  @override
  E get errorOrThrow => _error;

  @override
  T getDataOrElse(T defaultValue) => defaultValue;

  @override
  E getErrorOrElse(E defaultValue) => _error;

  @override
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(E error) error,
  }) =>
      error(_error);

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
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? data,
    R Function(E error)? error,
    required R Function() orElse,
  }) =>
      error?.call(_error) ?? orElse();

  @override
  R? whenOrNull<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? data,
    R Function(E error)? error,
  }) =>
      error?.call(_error);

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
  bool any(bool Function(T data) predicate) => false;

  @override
  AsyncResult<T, E> mapErrorWhere(
    bool Function(E error) test,
    E Function(E error) mapper,
  ) =>
      AsyncResult<T, E>.error(
        test(_error) ? mapper(_error) : _error,
      );

  @override
  AsyncResult<T, E> mapWhere(
    bool Function(T data) test,
    T Function(T data) mapper,
  ) =>
      AsyncResult<T, E>.error(_error);

  @override
  AsyncResult<T, E> validate(
    bool Function(T data) predicate,
    E Function(T data) errorBuilder,
  ) =>
      AsyncResult<T, E>.error(_error);

  @override
  AsyncResult<E, T> swap() => AsyncResult<E, T>.data(_error);

  @override
  AsyncResult<T, E> filter(
    bool Function(T data) predicate,
    E Function() errorBuilder,
  ) =>
      AsyncResult<T, E>.error(_error);

  @override
  AsyncResult<T, E> tap({
    void Function(T data)? onData,
    void Function(E error)? onError,
    void Function()? onLoading,
    void Function()? onInitial,
  }) {
    onError?.call(_error);
    return this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsyncError<T, E> &&
          runtimeType == other.runtimeType &&
          _error == other._error;

  @override
  int get hashCode => _error.hashCode;

  @override
  Object? toJson(Object? Function(T data) toJsonT) => null;
}
