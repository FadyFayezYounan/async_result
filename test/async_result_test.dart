import 'package:async_result/async_result.dart';
import 'package:test/test.dart';

void main() {
  group('AsyncResult Factory Constructors', () {
    test('initial() creates AsyncInitial state', () {
      final result = AsyncResult<int, String>.initial();

      expect(result.isInitial, isTrue);
      expect(result.isLoading, isFalse);
      expect(result.isSuccess, isFalse);
      expect(result.isError, isFalse);
      expect(result.dataOrNull, isNull);
      expect(result.errorOrNull, isNull);
    });

    test('loading() creates AsyncLoading state', () {
      final result = AsyncResult<int, String>.loading();

      expect(result.isInitial, isFalse);
      expect(result.isLoading, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.isError, isFalse);
      expect(result.dataOrNull, isNull);
      expect(result.errorOrNull, isNull);
    });

    test('data() creates AsyncData state', () {
      final result = AsyncResult<int, String>.data(42);

      expect(result.isInitial, isFalse);
      expect(result.isLoading, isFalse);
      expect(result.isSuccess, isTrue);
      expect(result.isError, isFalse);
      expect(result.dataOrNull, equals(42));
      expect(result.dataOrThrow, equals(42));
      expect(result.errorOrNull, isNull);
    });

    test('error() creates AsyncError state', () {
      final result = AsyncResult<int, String>.error('failed');

      expect(result.isInitial, isFalse);
      expect(result.isLoading, isFalse);
      expect(result.isSuccess, isFalse);
      expect(result.isError, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.errorOrNull, equals('failed'));
      expect(result.errorOrThrow, equals('failed'));
    });
  });

  group('AsyncResult Getters', () {
    test('hasError alias works correctly', () {
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      expect(success.hasError, isFalse);
      expect(error.hasError, isTrue);
    });

    test('hasData alias works correctly', () {
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      expect(success.hasData, isTrue);
      expect(error.hasData, isFalse);
    });

    test('isLoadingOrInitial works correctly', () {
      final initial = AsyncResult<int, String>.initial();
      final loading = AsyncResult<int, String>.loading();
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      expect(initial.isLoadingOrInitial, isTrue);
      expect(loading.isLoadingOrInitial, isTrue);
      expect(success.isLoadingOrInitial, isFalse);
      expect(error.isLoadingOrInitial, isFalse);
    });

    test('isDataOrError works correctly', () {
      final initial = AsyncResult<int, String>.initial();
      final loading = AsyncResult<int, String>.loading();
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      expect(initial.isDataOrError, isFalse);
      expect(loading.isDataOrError, isFalse);
      expect(success.isDataOrError, isTrue);
      expect(error.isDataOrError, isTrue);
    });

    test('isCompleted works correctly', () {
      final initial = AsyncResult<int, String>.initial();
      final loading = AsyncResult<int, String>.loading();
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      expect(initial.isCompleted, isFalse);
      expect(loading.isCompleted, isFalse);
      expect(success.isCompleted, isTrue);
      expect(error.isCompleted, isTrue);
    });
  });

  group('AsyncResult Data Access', () {
    test('dataOrThrow throws on non-success states', () {
      final initial = AsyncResult<int, String>.initial();
      final loading = AsyncResult<int, String>.loading();
      final error = AsyncResult<int, String>.error('failed');

      expect(() => initial.dataOrThrow,
          throwsA(isA<AsyncResultDataNotFoundException>()));
      expect(() => loading.dataOrThrow,
          throwsA(isA<AsyncResultDataNotFoundException>()));
      expect(() => error.dataOrThrow,
          throwsA(isA<AsyncResultDataNotFoundException>()));
    });

    test('errorOrThrow throws on non-error states', () {
      final initial = AsyncResult<int, String>.initial();
      final loading = AsyncResult<int, String>.loading();
      final success = AsyncResult<int, String>.data(42);

      expect(() => initial.errorOrThrow,
          throwsA(isA<AsyncResultErrorNotFoundException>()));
      expect(() => loading.errorOrThrow,
          throwsA(isA<AsyncResultErrorNotFoundException>()));
      expect(() => success.errorOrThrow,
          throwsA(isA<AsyncResultErrorNotFoundException>()));
    });

    test('getDataOrElse returns data or default', () {
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      expect(success.getDataOrElse(0), equals(42));
      expect(error.getDataOrElse(0), equals(0));
    });

    test('getErrorOrElse returns error or default', () {
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      expect(success.getErrorOrElse('default'), equals('default'));
      expect(error.getErrorOrElse('default'), equals('failed'));
    });
  });

  group('AsyncResult when() method', () {
    test('when() calls correct callback for each state', () {
      final initial = AsyncResult<int, String>.initial();
      final loading = AsyncResult<int, String>.loading();
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      expect(
        initial.when(
          initial: () => 'initial',
          loading: () => 'loading',
          data: (data) => 'data: $data',
          error: (error) => 'error: $error',
        ),
        equals('initial'),
      );

      expect(
        loading.when(
          initial: () => 'initial',
          loading: () => 'loading',
          data: (data) => 'data: $data',
          error: (error) => 'error: $error',
        ),
        equals('loading'),
      );

      expect(
        success.when(
          initial: () => 'initial',
          loading: () => 'loading',
          data: (data) => 'data: $data',
          error: (error) => 'error: $error',
        ),
        equals('data: 42'),
      );

      expect(
        error.when(
          initial: () => 'initial',
          loading: () => 'loading',
          data: (data) => 'data: $data',
          error: (error) => 'error: $error',
        ),
        equals('error: failed'),
      );
    });
  });

  group('AsyncResult maybeWhen() method', () {
    test('maybeWhen() calls specific callback or orElse', () {
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      expect(
        success.maybeWhen(
          data: (data) => data * 2,
          orElse: () => 0,
        ),
        equals(84),
      );

      expect(
        error.maybeWhen(
          data: (data) => data * 2,
          orElse: () => 0,
        ),
        equals(0),
      );
    });
  });

  group('AsyncResult whenOrNull() method', () {
    test('whenOrNull() returns value or null', () {
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      expect(
        success.whenOrNull(
          data: (data) => data * 2,
        ),
        equals(84),
      );

      expect(
        error.whenOrNull(
          data: (data) => data * 2,
        ),
        isNull,
      );
    });
  });

  group('AsyncResult specific when methods', () {
    test('whenData() returns value only for data state', () {
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      expect(success.whenData((data) => data * 2), equals(84));
      expect(error.whenData((data) => data * 2), isNull);
    });

    test('whenError() returns value only for error state', () {
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      expect(success.whenError((err) => err.toUpperCase()), isNull);
      expect(error.whenError((err) => err.toUpperCase()), equals('FAILED'));
    });

    test('whenLoading() returns value only for loading state', () {
      final loading = AsyncResult<int, String>.loading();
      final success = AsyncResult<int, String>.data(42);

      expect(loading.whenLoading(() => 'loading now'), equals('loading now'));
      expect(success.whenLoading(() => 'loading now'), isNull);
    });

    test('whenInitial() returns value only for initial state', () {
      final initial = AsyncResult<int, String>.initial();
      final success = AsyncResult<int, String>.data(42);

      expect(initial.whenInitial(() => 'not started'), equals('not started'));
      expect(success.whenInitial(() => 'not started'), isNull);
    });
  });

  group('AsyncResult Transformations', () {
    test('map() transforms data preserving other states', () {
      final initial = AsyncResult<int, String>.initial();
      final loading = AsyncResult<int, String>.loading();
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      String mapper(int x) => x.toString();

      expect(initial.map(mapper).isInitial, isTrue);
      expect(loading.map(mapper).isLoading, isTrue);
      expect(success.map(mapper).dataOrThrow, equals('42'));
      expect(error.map(mapper).errorOrThrow, equals('failed'));
    });

    test('mapError() transforms error preserving other states', () {
      final initial = AsyncResult<int, String>.initial();
      final loading = AsyncResult<int, String>.loading();
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      int mapper(String err) => err.length;

      expect(initial.mapError(mapper).isInitial, isTrue);
      expect(loading.mapError(mapper).isLoading, isTrue);
      expect(success.mapError(mapper).dataOrThrow, equals(42));
      expect(error.mapError(mapper).errorOrThrow, equals(6));
    });

    test('bimap() transforms both data and error', () {
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      final mappedSuccess = success.bimap(
        data: (x) => x.toString(),
        error: (err) => err.length,
      );

      final mappedError = error.bimap(
        data: (x) => x.toString(),
        error: (err) => err.length,
      );

      expect(mappedSuccess.dataOrThrow, equals('42'));
      expect(mappedError.errorOrThrow, equals(6));
    });

    test('flatMap() chains AsyncResult operations', () {
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      AsyncResult<String, String> parseNumber(int x) {
        if (x > 0) return AsyncResult.data(x.toString());
        return AsyncResult.error('negative');
      }

      final mappedSuccess = success.flatMap(parseNumber);
      final mappedError = error.flatMap(parseNumber);

      expect(mappedSuccess.dataOrThrow, equals('42'));
      expect(mappedError.errorOrThrow, equals('failed'));
    });

    test('recover() converts error to data', () {
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      int recovery(String err) => -1;

      expect(success.recover(recovery).dataOrThrow, equals(42));
      expect(error.recover(recovery).dataOrThrow, equals(-1));
    });
  });

  group('AsyncResult New Methods', () {
    test('any() tests data with predicate', () {
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');
      final loading = AsyncResult<int, String>.loading();

      expect(success.any((x) => x > 40), isTrue);
      expect(success.any((x) => x < 40), isFalse);
      expect(error.any((x) => x > 40), isFalse);
      expect(loading.any((x) => x > 40), isFalse);
    });

    test('mapWhere() conditionally transforms data', () {
      final success = AsyncResult<int, String>.data(42);
      final smallNumber = AsyncResult<int, String>.data(5);

      final mapped = success.mapWhere(
        (x) => x > 40,
        (x) => x * 2,
      );

      final notMapped = smallNumber.mapWhere(
        (x) => x > 40,
        (x) => x * 2,
      );

      expect(mapped.dataOrThrow, equals(84));
      expect(notMapped.dataOrThrow, equals(5));
    });

    test('mapErrorWhere() conditionally transforms error', () {
      final networkError = AsyncResult<int, String>.error('network_error');
      final validationError =
          AsyncResult<int, String>.error('validation_error');

      final mapped = networkError.mapErrorWhere(
        (err) => err.startsWith('network'),
        (err) => 'Connection failed',
      );

      final notMapped = validationError.mapErrorWhere(
        (err) => err.startsWith('network'),
        (err) => 'Connection failed',
      );

      expect(mapped.errorOrThrow, equals('Connection failed'));
      expect(notMapped.errorOrThrow, equals('validation_error'));
    });

    test('validate() converts data to error if invalid', () {
      final positiveNumber = AsyncResult<int, String>.data(42);
      final negativeNumber = AsyncResult<int, String>.data(-5);

      final validatedPositive = positiveNumber.validate(
        (x) => x >= 0,
        (x) => 'Negative number: $x',
      );

      final validatedNegative = negativeNumber.validate(
        (x) => x >= 0,
        (x) => 'Negative number: $x',
      );

      expect(validatedPositive.dataOrThrow, equals(42));
      expect(validatedNegative.errorOrThrow, equals('Negative number: -5'));
    });

    test('swap() exchanges data and error types', () {
      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');
      final loading = AsyncResult<int, String>.loading();

      final swappedSuccess = success.swap();
      final swappedError = error.swap();
      final swappedLoading = loading.swap();

      expect(swappedSuccess.errorOrThrow, equals(42));
      expect(swappedError.dataOrThrow, equals('failed'));
      expect(swappedLoading.isLoading, isTrue);
    });

    test('filter() keeps or rejects data based on predicate', () {
      final largeNumber = AsyncResult<int, String>.data(100);
      final smallNumber = AsyncResult<int, String>.data(10);

      final filtered = largeNumber.filter(
        (x) => x > 50,
        () => 'Number too small',
      );

      final rejected = smallNumber.filter(
        (x) => x > 50,
        () => 'Number too small',
      );

      expect(filtered.dataOrThrow, equals(100));
      expect(rejected.errorOrThrow, equals('Number too small'));
    });

    test('tap() executes side effects without changing result', () {
      var capturedData = 0;
      var capturedError = '';
      var loadingCalled = false;
      var initialCalled = false;

      final success = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');
      final loading = AsyncResult<int, String>.loading();
      final initial = AsyncResult<int, String>.initial();

      final tappedSuccess = success.tap(
        onData: (data) => capturedData = data,
      );

      final tappedError = error.tap(
        onError: (err) => capturedError = err,
      );

      final tappedLoading = loading.tap(
        onLoading: () => loadingCalled = true,
      );

      final tappedInitial = initial.tap(
        onInitial: () => initialCalled = true,
      );

      expect(identical(success, tappedSuccess), isTrue);
      expect(identical(error, tappedError), isTrue);
      expect(identical(loading, tappedLoading), isTrue);
      expect(identical(initial, tappedInitial), isTrue);

      expect(capturedData, equals(42));
      expect(capturedError, equals('failed'));
      expect(loadingCalled, isTrue);
      expect(initialCalled, isTrue);
    });
  });

  group('AsyncResult Static Utility Methods', () {
    test('allComplete() checks if all results are completed', () {
      final results1 = [
        AsyncResult<int, String>.data(1),
        AsyncResult<int, String>.error('failed'),
      ];

      final results2 = [
        AsyncResult<int, String>.data(1),
        AsyncResult<int, String>.loading(),
      ];

      expect(AsyncResult.allComplete(results1), isTrue);
      expect(AsyncResult.allComplete(results2), isFalse);
    });

    test('allSuccess() checks if all results are successful', () {
      final results1 = [
        AsyncResult<int, String>.data(1),
        AsyncResult<int, String>.data(2),
      ];

      final results2 = [
        AsyncResult<int, String>.data(1),
        AsyncResult<int, String>.error('failed'),
      ];

      expect(AsyncResult.allSuccess(results1), isTrue);
      expect(AsyncResult.allSuccess(results2), isFalse);
    });

    test('allError() checks if all results are errors', () {
      final results1 = [
        AsyncResult<int, String>.error('error1'),
        AsyncResult<int, String>.error('error2'),
      ];

      final results2 = [
        AsyncResult<int, String>.error('error1'),
        AsyncResult<int, String>.data(1),
      ];

      expect(AsyncResult.allError(results1), isTrue);
      expect(AsyncResult.allError(results2), isFalse);
    });

    test('anyError() checks if any result is error', () {
      final results1 = [
        AsyncResult<int, String>.data(1),
        AsyncResult<int, String>.error('failed'),
      ];

      final results2 = [
        AsyncResult<int, String>.data(1),
        AsyncResult<int, String>.data(2),
      ];

      expect(AsyncResult.anyError(results1), isTrue);
      expect(AsyncResult.anyError(results2), isFalse);
    });

    test('anyLoading() checks if any result is loading', () {
      final results1 = [
        AsyncResult<int, String>.data(1),
        AsyncResult<int, String>.loading(),
      ];

      final results2 = [
        AsyncResult<int, String>.data(1),
        AsyncResult<int, String>.data(2),
      ];

      expect(AsyncResult.anyLoading(results1), isTrue);
      expect(AsyncResult.anyLoading(results2), isFalse);
    });

    test('anyComplete() checks if any result is completed', () {
      final results1 = [
        AsyncResult<int, String>.loading(),
        AsyncResult<int, String>.data(1),
      ];

      final results2 = [
        AsyncResult<int, String>.loading(),
        AsyncResult<int, String>.initial(),
      ];

      expect(AsyncResult.anyComplete(results1), isTrue);
      expect(AsyncResult.anyComplete(results2), isFalse);
    });

    test('anySuccess() checks if any result is successful', () {
      final results1 = [
        AsyncResult<int, String>.error('failed'),
        AsyncResult<int, String>.data(1),
      ];

      final results2 = [
        AsyncResult<int, String>.error('failed'),
        AsyncResult<int, String>.loading(),
      ];

      expect(AsyncResult.anySuccess(results1), isTrue);
      expect(AsyncResult.anySuccess(results2), isFalse);
    });

    test('getAllData() extracts all successful data', () {
      final results = [
        AsyncResult<int, String>.data(1),
        AsyncResult<int, String>.error('failed'),
        AsyncResult<int, String>.data(3),
        AsyncResult<int, String>.loading(),
      ];

      final data = AsyncResult.getAllData(results).toList();
      expect(data, equals([1, 3]));
    });

    test('getAllError() extracts all errors', () {
      final results = [
        AsyncResult<int, String>.data(1),
        AsyncResult<int, String>.error('error1'),
        AsyncResult<int, String>.data(3),
        AsyncResult<int, String>.error('error2'),
      ];

      final errors = AsyncResult.getAllError(results).toList();
      expect(errors, equals(['error1', 'error2']));
    });

    test('getFirstError() returns first error or null', () {
      final results1 = [
        AsyncResult<int, String>.data(1),
        AsyncResult<int, String>.error('first'),
        AsyncResult<int, String>.error('second'),
      ];

      final results2 = [
        AsyncResult<int, String>.data(1),
        AsyncResult<int, String>.data(2),
      ];

      expect(AsyncResult.getFirstError(results1), equals('first'));
      expect(AsyncResult.getFirstError(results2), isNull);
    });

    test('getFirstData() returns first data or null', () {
      final results1 = [
        AsyncResult<int, String>.error('failed'),
        AsyncResult<int, String>.data(42),
        AsyncResult<int, String>.data(100),
      ];

      final results2 = [
        AsyncResult<int, String>.error('failed'),
        AsyncResult<int, String>.loading(),
      ];

      expect(AsyncResult.getFirstData(results1), equals(42));
      expect(AsyncResult.getFirstData(results2), isNull);
    });
  });

  group('AsyncResult Combine Methods', () {
    test('combine2() combines two results', () {
      final result1 = AsyncResult<int, String>.data(1);
      final result2 = AsyncResult<int, String>.data(2);
      final error = AsyncResult<int, String>.error('failed');
      final loading = AsyncResult<int, String>.loading();

      final combined = AsyncResult.combine2(result1, result2);
      final withError = AsyncResult.combine2(result1, error);
      final withLoading = AsyncResult.combine2(result1, loading);

      expect(combined.dataOrThrow.first, equals(1));
      expect(combined.dataOrThrow.second, equals(2));
      expect(withError.errorOrThrow, equals('failed'));
      expect(withLoading.isLoading, isTrue);
    });

    test('combine3() combines three results', () {
      final result1 = AsyncResult<int, String>.data(1);
      final result2 = AsyncResult<int, String>.data(2);
      final result3 = AsyncResult<int, String>.data(3);

      final combined = AsyncResult.combine3(result1, result2, result3);

      expect(combined.dataOrThrow.first, equals(1));
      expect(combined.dataOrThrow.second, equals(2));
      expect(combined.dataOrThrow.third, equals(3));
    });

    test('combine4() combines four results', () {
      final result1 = AsyncResult<int, String>.data(1);
      final result2 = AsyncResult<int, String>.data(2);
      final result3 = AsyncResult<int, String>.data(3);
      final result4 = AsyncResult<int, String>.data(4);

      final combined = AsyncResult.combine4(result1, result2, result3, result4);

      expect(combined.dataOrThrow.first, equals(1));
      expect(combined.dataOrThrow.second, equals(2));
      expect(combined.dataOrThrow.third, equals(3));
      expect(combined.dataOrThrow.fourth, equals(4));
    });

    test('combine5() combines five results', () {
      final result1 = AsyncResult<int, String>.data(1);
      final result2 = AsyncResult<int, String>.data(2);
      final result3 = AsyncResult<int, String>.data(3);
      final result4 = AsyncResult<int, String>.data(4);
      final result5 = AsyncResult<int, String>.data(5);

      final combined =
          AsyncResult.combine5(result1, result2, result3, result4, result5);

      expect(combined.dataOrThrow.first, equals(1));
      expect(combined.dataOrThrow.second, equals(2));
      expect(combined.dataOrThrow.third, equals(3));
      expect(combined.dataOrThrow.fourth, equals(4));
      expect(combined.dataOrThrow.fifth, equals(5));
    });

    test('combineIterable() combines iterable of results', () {
      final results = [
        AsyncResult<int, String>.data(1),
        AsyncResult<int, String>.data(2),
        AsyncResult<int, String>.data(3),
      ];

      final resultsWithError = [
        AsyncResult<int, String>.data(1),
        AsyncResult<int, String>.error('failed'),
        AsyncResult<int, String>.data(3),
      ];

      final combined = AsyncResult.combineIterable(results);
      final withError = AsyncResult.combineIterable(resultsWithError);

      expect(combined.dataOrThrow, equals([1, 2, 3]));
      expect(withError.errorOrThrow, equals('failed'));
    });
  });

  group('AsyncResult Equality and toString', () {
    test('AsyncData equality works correctly', () {
      final data1 = AsyncResult<int, String>.data(42);
      final data2 = AsyncResult<int, String>.data(42);
      final data3 = AsyncResult<int, String>.data(100);

      expect(data1 == data2, isTrue);
      expect(data1 == data3, isFalse);
      expect(data1.hashCode, equals(data2.hashCode));
    });

    test('AsyncError equality works correctly', () {
      final error1 = AsyncResult<int, String>.error('failed');
      final error2 = AsyncResult<int, String>.error('failed');
      final error3 = AsyncResult<int, String>.error('different');

      expect(error1 == error2, isTrue);
      expect(error1 == error3, isFalse);
      expect(error1.hashCode, equals(error2.hashCode));
    });

    test('toString() works correctly for all states', () {
      final initial = AsyncResult<int, String>.initial();
      final loading = AsyncResult<int, String>.loading();
      final data = AsyncResult<int, String>.data(42);
      final error = AsyncResult<int, String>.error('failed');

      expect(initial.toString(), equals('AsyncResult.initial()'));
      expect(loading.toString(), equals('AsyncResult.loading()'));
      expect(data.toString(), equals('AsyncResult.data(42)'));
      expect(error.toString(), equals('AsyncResult.error(failed)'));
    });
  });

  group('AsyncResult Exception Tests', () {
    test('AsyncResultDataNotFoundException has correct message', () {
      final exception = AsyncResultDataNotFoundException<int, String>();
      expect(exception.toString(), contains('success value of [int]'));
      expect(exception.toString(), contains('isSuccess'));
      expect(exception.toString(), contains('dataOrNull'));
    });

    test('AsyncResultErrorNotFoundException has correct message', () {
      final exception = AsyncResultErrorNotFoundException<int, String>();
      expect(exception.toString(), contains('error value of [String]'));
      expect(exception.toString(), contains('isError'));
      expect(exception.toString(), contains('errorOrNull'));
    });
  });
}
