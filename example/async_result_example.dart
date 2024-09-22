import 'dart:async';
import 'dart:math';

import 'package:async_result/async_result.dart';

// Usage examples
void main() async {
  final rsult = AsyncResult.data('Hello, World!');
  print(rsult.toString());
  // // Using Example 1
  // print('Fetching todos...');
  // final todosResult = await fetchTodos();
  // todosResult.when(
  //   whenInitial: () => print('Initial state (unexpected)'),
  //   whenLoading: () => print('Loading todos...'),
  //   whenData: (todos) => print('Fetched ${todos.length} todos: $todos'),
  //   whenError: (error) => print('Error fetching todos: $error'),
  // );

  // // Using Example 2
  // print('\nPerforming computation...');
  // final computationResult = await simulateComputation();
  // computationResult.when(
  //   whenInitial: () => print('Initial state (unexpected)'),
  //   whenLoading: () => print('Computing...'),
  //   whenData: (result) => print('Computation result: $result'),
  //   whenError: (error) => print('Computation error: $error'),
  // );

  // // Using Example 3
  // print('\nProcessing data...');
  // final initialResult = AsyncResult<int, String>.data(10);
  // final processedResult = await processData(initialResult);
  // processedResult.when(
  //   whenInitial: () => print('Initial state (unexpected)'),
  //   whenLoading: () => print('Processing...'),
  //   whenData: (result) => print('Processed result: $result'),
  //   whenError: (error) => print('Processing error: $error'),
  // );

  // // Using Example 5
  // print('\nCombining results...');
  // final result1 = AsyncResult<int, String>.data(42);
  // final result2 = AsyncResult<String, String>.data('Hello');
  // final combinedResult = await combineResults(result1, result2);
  // combinedResult.when(
  //   whenInitial: () => print('Initial state (unexpected)'),
  //   whenLoading: () => print('Combining...'),
  //   whenData: (result) => print(result),
  //   whenError: (error) => print('Combining error: $error'),
  // );
}

// Example 1: Simulating data fetch from an API
Future<AsyncResult<List<String>, Exception>> fetchTodos() async {
  // Simulate network delay
  await Future.delayed(Duration(seconds: 1));

  // Simulate success or failure randomly
  final random = Random();
  if (random.nextBool()) {
    // Simulate successful response
    final todos = List.generate(5, (index) => 'Todo ${index + 1}');
    return AsyncResult.data(todos);
  } else {
    // Simulate error
    return AsyncResult.error(Exception('Failed to load todos'));
  }
}

// Example 2: Simulating a long-running computation
Future<AsyncResult<int, String>> simulateComputation() async {
  try {
    await Future.delayed(Duration(seconds: 2)); // Simulate work
    final result =
        List.generate(1000000, (index) => index).reduce((a, b) => a + b);
    return AsyncResult.data(result);
  } catch (e) {
    return AsyncResult.error('Computation failed: $e');
  }
}

// Example 3: Chaining AsyncResult operations
Future<AsyncResult<double, String>> processData(
    AsyncResult<int, String> input) async {
  return input.when(
    whenInitial: () => AsyncResult.error('Unexpected initial state'),
    whenLoading: () => AsyncResult.error('Unexpected loading state'),
    whenData: (data) async {
      await Future.delayed(Duration(milliseconds: 500)); // Simulate processing
      return AsyncResult.data(data / 2.0);
    },
    whenError: (error) => AsyncResult.error('Processing failed: $error'),
  );
}

// Example 5: Combining multiple AsyncResults
Future<AsyncResult<String, String>> combineResults(
    AsyncResult<int, String> result1,
    AsyncResult<String, String> result2) async {
  if (result1.hasError) return AsyncResult.error(result1.whenError((e) => e)!);
  if (result2.hasError) return AsyncResult.error(result2.whenError((e) => e)!);

  final value1 = result1.dataOrNull;
  final value2 = result2.dataOrNull;

  if (value1 != null && value2 != null) {
    return AsyncResult.data('Combined: $value1 and $value2');
  } else {
    return AsyncResult.error('One or both results are null');
  }
}
