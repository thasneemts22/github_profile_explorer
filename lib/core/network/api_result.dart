import 'package:flutter/foundation.dart';
import 'api_exceptions.dart';

@immutable
sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(data: final d) => d,
        Failure<T>() => null,
      };

  AppException? get exceptionOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(exception: final e) => e,
      };

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) {
    return switch (this) {
      Success<T>(data: final data) => success(data),
      Failure<T>(exception: final exception) => failure(exception),
    };
  }
}

final class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> && runtimeType == other.runtimeType && data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success(data: $data)';
}

final class Failure<T> extends ApiResult<T> {
  final AppException exception;
  const Failure(this.exception);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          exception.runtimeType == other.exception.runtimeType &&
          exception.message == other.exception.message;

  @override
  int get hashCode => exception.hashCode;

  @override
  String toString() => 'Failure(exception: $exception)';
}
