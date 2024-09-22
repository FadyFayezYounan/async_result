import 'package:async_result/async_result.dart';
import 'package:test/test.dart';

void main() {
  group('AsyncResult', () {
    test('initial state', () {
      final result = AsyncResult<int, String>.initial();
      expect(result.isInitial, isTrue);
      expect(result.isLoading, isFalse);
      expect(result.hasError, isFalse);
      expect(result.hasData, isFalse);
      expect(result.isLoadingOrInitial, isTrue);
      expect(result.isDateOrError, isFalse);
      expect(result.dataOrNull, isNull);
    });

    test('loading state', () {
      final result = AsyncResult<int, String>.loading();
      expect(result.isInitial, isFalse);
      expect(result.isLoading, isTrue);
      expect(result.hasError, isFalse);
      expect(result.hasData, isFalse);
      expect(result.isLoadingOrInitial, isTrue);
      expect(result.isDateOrError, isFalse);
      expect(result.dataOrNull, isNull);
    });

    test('data state', () {
      final result = AsyncResult<int, String>.data(42);
      expect(result.isInitial, isFalse);
      expect(result.isLoading, isFalse);
      expect(result.hasError, isFalse);
      expect(result.hasData, isTrue);
      expect(result.isLoadingOrInitial, isFalse);
      expect(result.isDateOrError, isTrue);
      expect(result.dataOrNull, equals(42));
    });

    test('error state', () {
      final result = AsyncResult<int, String>.error('Error message');
      expect(result.isInitial, isFalse);
      expect(result.isLoading, isFalse);
      expect(result.hasError, isTrue);
      expect(result.hasData, isFalse);
      expect(result.isLoadingOrInitial, isFalse);
      expect(result.isDateOrError, isTrue);
      expect(result.dataOrNull, isNull);
    });

    test('when method', () {
      AsyncResult<int, String> result;

      result = AsyncResult.initial();
      expect(
        result.when(
          whenInitial: () => 'initial',
          whenLoading: () => 'loading',
          whenData: (data) => 'data',
          whenError: (error) => 'error',
        ),
        equals('initial'),
      );

      result = AsyncResult.loading();
      expect(
        result.when(
          whenInitial: () => 'initial',
          whenLoading: () => 'loading',
          whenData: (data) => 'data',
          whenError: (error) => 'error',
        ),
        equals('loading'),
      );

      result = AsyncResult.data(42);
      expect(
        result.when(
          whenInitial: () => 'initial',
          whenLoading: () => 'loading',
          whenData: (data) => 'data: $data',
          whenError: (error) => 'error',
        ),
        equals('data: 42'),
      );

      result = AsyncResult.error('Error message');
      expect(
        result.when(
          whenInitial: () => 'initial',
          whenLoading: () => 'loading',
          whenData: (data) => 'data',
          whenError: (error) => 'error: $error',
        ),
        equals('error: Error message'),
      );
    });

    test('maybeWhen method', () {
      AsyncResult<int, String> result;

      result = AsyncResult.initial();
      expect(
        result.maybeWhen(
          whenData: (data) => 'data',
          orElse: () => 'other',
        ),
        equals('other'),
      );

      result = AsyncResult.data(42);
      expect(
        result.maybeWhen(
          whenData: (data) => 'data: $data',
          orElse: () => 'other',
        ),
        equals('data: 42'),
      );
    });

    test('equality', () {
      expect(AsyncResult<int, String>.data(42),
          equals(AsyncResult<int, String>.data(42)));
      expect(AsyncResult<int, String>.data(42),
          isNot(equals(AsyncResult<int, String>.data(43))));
      expect(AsyncResult<int, String>.error('Error'),
          equals(AsyncResult<int, String>.error('Error')));
      expect(AsyncResult<int, String>.error('Error'),
          isNot(equals(AsyncResult<int, String>.error('Different error'))));
    });

    test('whenInitial method', () {
      final result = AsyncResult<int, String>.initial();
      expect(result.whenInitial(() => 'initial'), equals('initial'));
      expect(AsyncResult<int, String>.data(42).whenInitial(() => 'initial'),
          isNull);
    });

    test('whenLoading method', () {
      final result = AsyncResult<int, String>.loading();
      expect(result.whenLoading(() => 'loading'), equals('loading'));
      expect(AsyncResult<int, String>.data(42).whenLoading(() => 'loading'),
          isNull);
    });

    test('whenData method', () {
      final result = AsyncResult<int, String>.data(42);
      expect(result.whenData((data) => 'data: $data'), equals('data: 42'));
      expect(
          AsyncResult<int, String>.error('Error')
              .whenData((data) => 'data: $data'),
          isNull);
    });

    test('whenError method', () {
      final result = AsyncResult<int, String>.error('Error message');
      expect(result.whenError((error) => 'error: $error'),
          equals('error: Error message'));
      expect(
          AsyncResult<int, String>.data(42)
              .whenError((error) => 'error: $error'),
          isNull);
    });
  });
}
