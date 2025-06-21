/// An exception thrown when attempting to access success data that doesn't exist in an [AsyncResult].
///
/// This exception is typically thrown when calling [dataOrThrow] on an [AsyncResult]
/// that doesn't contain success data (i.e., when [isSuccess] is false).
///
/// Generic Parameters:
/// * [S] - The type of success data that was expected but not found
/// * [E] - The type of error that could be present instead
///
/// Example:
/// ```dart
/// final result = AsyncResult<String, Error>.error(Error());
/// result.dataOrThrow; // Throws AsyncResultDataNotFoundException
/// ```
///
/// To avoid this exception, either:
/// * Check [isSuccess] before accessing [dataOrThrow]
/// * Use [dataOrNull] which returns null instead of throwing
final class AsyncResultDataNotFoundException<T, E> implements Exception {
  const AsyncResultDataNotFoundException();
  @override
  String toString() {
    return '''
      Tried to get the success value of [$T], but none was found. 
      Make sure you're checking for `isSuccess` before trying to get it through
      `dataOrThrow`. You can also use `dataOrNull` if you're unsure.
    ''';
  }
}

/// An exception thrown when attempting to access error data that doesn't exist in an [AsyncResult].
///
/// This exception is typically thrown when calling [errorOrThrow] on an [AsyncResult]
/// that doesn't contain error data (i.e., when [isError] is false).
///
/// Generic Parameters:
/// * [S] - The type of success data that could be present instead
/// * [E] - The type of error that was expected but not found
///
/// Example:
/// ```dart
/// final result = AsyncResult<String, Error>.data('data');
/// result.errorOrThrow; // Throws AsyncResultErrorNotFoundException
/// ```
///
/// To avoid this exception, either:
/// * Check [isError] before accessing [errorOrThrow]
/// * Use [errorOrNull] which returns null instead of throwing
final class AsyncResultErrorNotFoundException<T, E> implements Exception {
  const AsyncResultErrorNotFoundException();

  @override
  String toString() {
    return '''
      Tried to get the error value of [$E], but none was found. 
      Make sure you're checking for `isError` before trying to get it through
      `errorOrThrow`. You can also use `errorOrNull` if you're unsure.
    ''';
  }
}
