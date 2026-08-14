abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class NotFoundException extends AppException {
  const NotFoundException([String message = 'User not found. Check the username and try again.'])
      : super(message, 404);
}

class RateLimitException extends AppException {
  final DateTime? resetTime;
  final int? remaining;

  RateLimitException({
    String message = 'GitHub API rate limit exceeded. Please wait before trying again.',
    this.resetTime,
    this.remaining,
  }) : super(message, 403);

  String get formattedResetTime {
    if (resetTime == null) return '';
    final minutesLeft = resetTime!.difference(DateTime.now()).inMinutes;
    if (minutesLeft <= 0) return 'Resets shortly';
    return 'Resets in $minutesLeft minute${minutesLeft > 1 ? "s" : ""}';
  }
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection. Please check your network.']);
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Connection timed out. Please try again later.']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'GitHub server error. Please try again later.', super.statusCode]);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'An unexpected error occurred. Please try again.']);
}
