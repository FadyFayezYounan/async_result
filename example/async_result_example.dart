import 'dart:async';
import 'dart:math';

import 'package:async_result/async_result.dart';

void main() async {
  print('=== AsyncResult Comprehensive Example ===\n');

  // Basic usage example
  await basicUsageExample();

  // Error handling example
  await errorHandlingExample();

  // Transformation examples
  transformationExamples();

  // Combination examples
  combinationExamples();

  // New utility methods examples
  utilityMethodsExamples();

  // Real-world example
  await realWorldExample();
}

/// Demonstrates basic usage of AsyncResult states
Future<void> basicUsageExample() async {
  print('--- Basic Usage Example ---');

  // Simulate a data fetching operation
  final result = await fetchUserData(userId: 123);

  // Handle the result using when()
  final message = result.when(
    initial: () => 'Operation not started',
    loading: () => 'Fetching user data...',
    data: (user) => 'User loaded: ${user.name} (${user.email})',
    error: (error) => 'Failed to load user: $error',
  );
  print('Result: $message');

  // Alternative: Handle only specific states
  result.whenData((user) {
    print('Success! User ID: ${user.id}');
  });

  result.whenError((error) {
    print('Error occurred: $error');
  });

  print('');
}

/// Demonstrates error handling patterns
Future<void> errorHandlingExample() async {
  print('--- Error Handling Example ---');

  final result = await fetchUserData(userId: -1); // This will fail

  // Safe data access
  final userData = result.dataOrNull;
  if (userData != null) {
    print('User: ${userData.name}');
  } else {
    print('No user data available');
  }

  // Using getDataOrElse for default values
  final defaultUser = result.getDataOrElse(User(
    id: 0,
    name: 'Anonymous',
    email: 'anonymous@example.com',
  ));
  print('User (with default): ${defaultUser.name}');

  // Recovery from errors
  final recovered = result.recover((error) => User(
        id: -1,
        name: 'Error User',
        email: 'error@example.com',
      ));
  print('Recovered user: ${recovered.dataOrThrow.name}');
  print('');
}

/// Demonstrates transformation methods
void transformationExamples() {
  print('--- Transformation Examples ---');

  final userResult = AsyncResult<User, String>.data(User(
    id: 123,
    name: 'John Doe',
    email: 'john@example.com',
  ));

  // Transform data
  final nameResult = userResult.map((user) => user.name.toUpperCase());
  print('Uppercase name: ${nameResult.dataOrThrow}');

  // Transform errors
  final errorResult = AsyncResult<User, String>.error('network_timeout');
  final mappedError = errorResult.mapError((err) => 'Connection Error: $err');
  print('Mapped error: ${mappedError.errorOrThrow}');

  // Conditional transformations
  final conditionalResult = userResult.mapWhere(
    (user) => user.name.length > 5,
    (user) => user.copyWith(name: '${user.name} (Long Name)'),
  );
  print('Conditional transform: ${conditionalResult.dataOrThrow.name}');

  // Validation
  final validatedResult = userResult.validate(
    (user) => user.email.contains('@'),
    (user) => 'Invalid email: ${user.email}',
  );
  print('Validation result: ${validatedResult.isSuccess}');

  // Chain operations with flatMap
  final chainedResult = userResult.flatMap((user) {
    if (user.id > 0) {
      return AsyncResult.data('Valid user: ${user.name}');
    }
    return AsyncResult.error('Invalid user ID');
  });
  print('Chained result: ${chainedResult.dataOrThrow}');

  print('');
}

/// Demonstrates combination methods
void combinationExamples() {
  print('--- Combination Examples ---');

  final user = AsyncResult<User, String>.data(User(
    id: 1,
    name: 'Alice',
    email: 'alice@example.com',
  ));

  final profile = AsyncResult<UserProfile, String>.data(UserProfile(
    bio: 'Software Developer',
    location: 'San Francisco',
  ));

  // Combine two results
  final combined = AsyncResult.combine2(user, profile);
  if (combined.isSuccess) {
    final data = combined.dataOrThrow;
    print('Combined: ${data.first.name} - ${data.second.bio}');
  }

  // Combine multiple results
  final results = [
    AsyncResult<int, String>.data(1),
    AsyncResult<int, String>.data(2),
    AsyncResult<int, String>.data(3),
  ];

  final combinedList = AsyncResult.combineIterable(results);
  print('Combined list: ${combinedList.dataOrThrow}');

  // Static utility methods
  print('All success: ${AsyncResult.allSuccess(results)}');
  print('Any error: ${AsyncResult.anyError(results)}');
  print('All data: ${AsyncResult.getAllData(results).toList()}');

  print('');
}

/// Demonstrates new utility methods
void utilityMethodsExamples() {
  print('--- Utility Methods Examples ---');

  final numbers = AsyncResult<List<int>, String>.data([1, 2, 3, 4, 5]);

  // Test predicate
  final hasEvenNumbers = numbers.any((list) => list.any((n) => n % 2 == 0));
  print('Has even numbers: $hasEvenNumbers');

  // Filter data
  final filtered = numbers.filter(
    (list) => list.length >= 3,
    () => 'List too short',
  );
  print('Filtered result: ${filtered.isSuccess}');

  // Swap data and error types
  final swapped = numbers.swap();
  print('Swapped (now error): ${swapped.isError}');

  // Side effects with tap
  final tapped = numbers.tap(
    onData: (data) => print('Tapped data length: ${data.length}'),
    onError: (error) => print('Tapped error: $error'),
  );
  print('Tap preserves original: ${identical(numbers, tapped)}');

  print('');
}

/// Real-world example demonstrating a complete flow
Future<void> realWorldExample() async {
  print('--- Real-World Example: User Management System ---');

  // Simulate user creation flow
  final userCreationFlow = await createUserWorkflow(
    name: 'Jane Smith',
    email: 'jane.smith@example.com',
  );

  userCreationFlow.when(
    initial: () => print('User creation not started'),
    loading: () => print('Creating user...'),
    data: (result) => print('✅ User created successfully: ${result.message}'),
    error: (error) => print('❌ User creation failed: $error'),
  );

  // Demonstrate error recovery in a pipeline
  final pipeline = await userDataPipeline(userId: 999); // Non-existent user

  pipeline.when(
    initial: () => print('Pipeline not started'),
    loading: () => print('Processing user data...'),
    data: (result) => print('✅ Pipeline completed: $result'),
    error: (error) => print('❌ Pipeline failed: $error'),
  );

  print('');
}

/// Simulates fetching user data with random success/failure
Future<AsyncResult<User, String>> fetchUserData({required int userId}) async {
  // Simulate network delay
  await Future.delayed(Duration(milliseconds: 100));

  if (userId <= 0) {
    return AsyncResult.error('Invalid user ID');
  }

  // Simulate random failure
  if (Random().nextBool()) {
    return AsyncResult.error('Network timeout');
  }

  return AsyncResult.data(User(
    id: userId,
    name: 'User $userId',
    email: 'user$userId@example.com',
  ));
}

/// Simulates user creation with validation
Future<AsyncResult<CreateUserResult, String>> createUserWorkflow({
  required String name,
  required String email,
}) async {
  // Validate input
  if (name.isEmpty) {
    return AsyncResult.error('Name cannot be empty');
  }

  if (!email.contains('@')) {
    return AsyncResult.error('Invalid email format');
  }

  // Simulate API call
  await Future.delayed(Duration(milliseconds: 200));

  return AsyncResult.data(CreateUserResult(
    userId: Random().nextInt(1000) + 1,
    message: 'User $name created successfully',
  ));
}

/// Demonstrates a complex pipeline with error handling
Future<AsyncResult<String, String>> userDataPipeline(
    {required int userId}) async {
  // Step 1: Fetch user
  final userResult = await fetchUserData(userId: userId);

  if (userResult.isError) {
    return AsyncResult.error(
        'Failed to fetch user: ${userResult.errorOrThrow}');
  }

  if (!userResult.isSuccess) {
    return AsyncResult.error('User fetch incomplete');
  }

  final user = userResult.dataOrThrow;

  // Step 2: Validate user
  if (user.email.isEmpty) {
    return AsyncResult.error('User has no email');
  }

  // Step 3: Fetch additional profile data
  await Future.delayed(Duration(milliseconds: 50));

  return AsyncResult.data('Complete profile for ${user.name}');
}

// Domain models
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  User copyWith({int? id, String? name, String? email}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}

class UserProfile {
  final String bio;
  final String location;

  UserProfile({required this.bio, required this.location});
}

class CreateUserResult {
  final int userId;
  final String message;

  CreateUserResult({required this.userId, required this.message});
}
