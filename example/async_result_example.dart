import 'dart:async';
import 'dart:math';

import 'package:async_result/async_result.dart';

// Sample domain models
class User {
  final String id;
  final String name;
  User({required this.id, required this.name});
}

class Post {
  final String id;
  final String title;
  Post({required this.id, required this.title});
}

// Sample repository
class Repository {
  final _random = Random();

  // Simulates API call to fetch user
  Future<AsyncResult<User, String>> fetchUser(String id) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_random.nextBool()) {
      return AsyncResult.data(User(id: id, name: 'John Doe'));
    } else {
      return AsyncResult.error('Failed to fetch user');
    }
  }

  // Simulates API call to fetch posts
  Future<AsyncResult<List<Post>, String>> fetchUserPosts(String userId) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_random.nextBool()) {
      return AsyncResult.data([
        Post(id: '1', title: 'First Post'),
        Post(id: '2', title: 'Second Post'),
      ]);
    } else {
      return AsyncResult.error('Failed to fetch posts');
    }
  }
}

// Example usage
void main() async {
  final repository = Repository();

  // Basic usage example
  print('\n--- Basic Usage Example ---');
  await basicExample(repository);

  // Error handling example
  print('\n--- Error Handling Example ---');
  await errorHandlingExample(repository);

  // Pattern matching example
  print('\n--- Pattern Matching Example ---');
  await patternMatchingExample(repository);

  // Transformation example
  print('\n--- Transformation Example ---');
  await transformationExample(repository);
}

Future<void> basicExample(Repository repository) async {
  final result = await repository.fetchUser('user1');

  if (result.isSuccess) {
    print('User found: ${result.dataOrNull?.name}');
  } else if (result.isError) {
    print('Error: ${result.errorOrNull}');
  }
}

Future<void> errorHandlingExample(Repository repository) async {
  final result = await repository.fetchUser('user1');

  // Using recovery
  final recovered =
      result.recover((error) => User(id: '0', name: 'Guest User'));
  print('User: ${recovered.dataOrNull?.name}');

  // Safe data access
  final username = result.dataOrNull?.name ?? 'Unknown';
  print('Username: $username');
}

Future<void> patternMatchingExample(Repository repository) async {
  final result = await repository.fetchUser('user1');

  // Complete pattern matching
  result.when(
    whenInitial: () => print('Initial state'),
    whenLoading: () => print('Loading...'),
    whenData: (user) => print('User: ${user.name}'),
    whenError: (error) => print('Error: $error'),
  );

  // Partial pattern matching with default case
  result.maybeWhen(
    whenData: (user) => print('Found user: ${user.name}'),
    orElse: () => print('User not available'),
  );

  // Optional pattern matching
  final message = result.whenOrNull(
    whenData: (user) => 'User: ${user.name}',
    whenError: (error) => 'Error: $error',
  );
  print(message ?? 'No matching state');
}

Future<void> transformationExample(Repository repository) async {
  final result = await repository.fetchUser('user1');

  // Transform success data
  final transformed = result.map((user) => user.name.toUpperCase());
  print('Transformed data: ${transformed.dataOrNull}');

  // Transform error
  final mappedError = result.mapError((error) => 'ERROR: $error');
  print('Mapped error: ${mappedError.errorOrNull}');

  // Transform both success and error
  final bimapped = result.bimap(
    data: (user) => user.name.length,
    error: (error) => int.tryParse(error) ?? -1,
  );
  print('Bimapped result: ${bimapped.dataOrNull ?? bimapped.errorOrNull}');

  // Conditional transformation
  final conditional = result.mapWhere(
    (user) => user.name.startsWith('J'),
    (user) => User(id: user.id, name: 'Mr. ${user.name}'),
  );
  print('Conditional: ${conditional.dataOrNull?.name}');
}
