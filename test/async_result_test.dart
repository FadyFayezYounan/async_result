import 'package:async_result/async_result.dart';
import 'package:test/test.dart';

void main() {
  group('AsyncResult', () {
    test('should create an initial state', () {
      final result = AsyncResult<int, String>.initial();
      expect(result.isInitial, true);
      expect(result.isLoading, false);
      expect(result.hasError, false);
      expect(result.hasData, false);
      expect(result.isCompleted, false);
    });

    test('should create a loading state', () {
      final result = AsyncResult<int, String>.loading();
      expect(result.isInitial, false);
      expect(result.isLoading, true);
      expect(result.hasError, false);
      expect(result.hasData, false);
      expect(result.isCompleted, false);
    });

    test('should create a data state', () {
      final result = AsyncResult<int, String>.data(42);
      expect(result.isInitial, false);
      expect(result.isLoading, false);
      expect(result.hasError, false);
      expect(result.hasData, true);
      expect(result.isCompleted, true);
      expect(result.dataOrNull, 42);
    });

    test('should create an error state', () {
      final result = AsyncResult<int, String>.error('error');
      expect(result.isInitial, false);
      expect(result.isLoading, false);
      expect(result.hasError, true);
      expect(result.hasData, false);
      expect(result.isCompleted, true);
      expect(result.errorOrNull, 'error');
    });

    test('should map data correctly', () {
      final result = AsyncResult<int, String>.data(42);
      final mapped = result.map((data) => data.toString());
      expect(mapped, AsyncResult<String, String>.data('42'));
    });

    test('should map error correctly', () {
      final result = AsyncResult<int, String>.error('error');
      final mapped = result.mapError((error) => 'mapped error');
      expect(mapped, AsyncResult<int, String>.error('mapped error'));
    });

    test('should bimap correctly', () {
      final result = AsyncResult<int, String>.data(42);
      final mapped = result.bimap(
        data: (data) => data.toString(),
        error: (error) => Exception(error),
      );
      expect(mapped, AsyncResult<String, Exception>.data('42'));
    });

    test('should flatMap correctly', () {
      final result = AsyncResult<int, String>.data(42);
      final flatMapped = result
          .flatMap((data) => AsyncResult<String, String>.data(data.toString()));
      expect(flatMapped, AsyncResult<String, String>.data('42'));
    });

    test('should recover from error correctly', () {
      final result = AsyncResult<int, String>.error('error');
      final recovered = result.recover((error) => -1);
      expect(recovered, AsyncResult<int, String>.data(-1));
    });

    test('should check allComplete correctly', () {
      final results = [
        AsyncResult<int, String>.data(42),
        AsyncResult<int, String>.error('error'),
      ];
      expect(AsyncResult.allComplete(results), true);
    });

    test('should check anyError correctly', () {
      final results = [
        AsyncResult<int, String>.data(42),
        AsyncResult<int, String>.error('error'),
      ];
      expect(AsyncResult.anyError(results), true);
    });

    test('should handle when correctly', () {
      final result = AsyncResult<int, String>.loading();
      final output = result.when(
        whenInitial: () => 'Initial',
        whenLoading: () => 'Loading',
        whenData: (data) => 'Data: $data',
        whenError: (error) => 'Error: $error',
      );
      expect(output, 'Loading');
    });

    test('should handle maybeWhen correctly', () {
      final result = AsyncResult<int, String>.data(42);
      final output = result.maybeWhen(
        whenData: (data) => 'Data: $data',
        orElse: () => 'Not in data state',
      );
      expect(output, 'Data: 42');
    });

    test('should handle whenOrNull correctly', () {
      final result = AsyncResult<int, String>.error('error');
      final output = result.whenOrNull(
        whenError: (error) => 'Error: $error',
      );
      expect(output, 'Error: error');
    });
  });
}
