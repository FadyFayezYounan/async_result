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
sealed class AsyncResult<T, E> {
  const AsyncResult._();

  /// Creates an instance representing the initial state.
  const factory AsyncResult.initial() = AsyncInitial<T, E>;

  /// Creates an instance representing the loading state.
  const factory AsyncResult.loading() = AsyncLoading<T, E>;

  /// Creates an instance representing a successful state with data.
  const factory AsyncResult.data(T data) = AsyncData<T, E>;

  /// Creates an instance representing an error state.
  const factory AsyncResult.error(E error) = AsyncError<T, E>;

  /// Returns true if this instance represents the initial state.
  bool get isInitial;

  /// Returns true if this instance represents the loading state.
  bool get isLoading;

  /// Returns true if this instance represents an error state.
  bool get hasError;

  /// Returns true if this instance contains data.
  bool get hasData;

  /// Returns true if this instance is in either loading or initial state.
  bool get isLoadingOrInitial;

  /// Returns true if this instance is in either data or error state.
  bool get isDateOrError;

  /// Returns the data if available, otherwise null.
  T? get dataOrNull;

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
  R? whenData<R>(R Function(T data) whenSuccess);

  /// Executes the given function if the state has an error.
  R? whenError<R>(R Function(E error) whenError);

  /// Maps the current state to a value of type R.
  R map<R>({
    required R Function(AsyncInitial<T, E> initial) initial,
    required R Function(AsyncLoading<T, E> loading) loading,
    required R Function(AsyncData<T, E> data) data,
    required R Function(AsyncError<T, E> error) error,
  });

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
  R? whenData<R>(R Function(T data) whenSuccess) => null;

  @override
  R map<R>({
    required R Function(AsyncInitial<T, E> initial) initial,
    required R Function(AsyncLoading<T, E> loading) loading,
    required R Function(AsyncData<T, E> success) data,
    required R Function(AsyncError<T, E> failure) error,
  }) =>
      initial(this);

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
  R? whenData<R>(R Function(T data) whenSuccess) => null;

  @override
  R map<R>({
    required R Function(AsyncInitial<T, E> initial) initial,
    required R Function(AsyncLoading<T, E> loading) loading,
    required R Function(AsyncData<T, E> success) data,
    required R Function(AsyncError<T, E> failure) error,
  }) =>
      loading(this);

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
  R? whenData<R>(R Function(T data) whenSuccess) => whenSuccess(_data);

  @override
  R map<R>({
    required R Function(AsyncInitial<T, E> initial) initial,
    required R Function(AsyncLoading<T, E> loading) loading,
    required R Function(AsyncData<T, E> success) data,
    required R Function(AsyncError<T, E> failure) error,
  }) =>
      data(this);

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
  R? whenData<R>(R Function(T data) whenSuccess) => null;

  @override
  R map<R>({
    required R Function(AsyncInitial<T, E> initial) initial,
    required R Function(AsyncLoading<T, E> loading) loading,
    required R Function(AsyncData<T, E> success) data,
    required R Function(AsyncError<T, E> failure) error,
  }) =>
      error(this);

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
