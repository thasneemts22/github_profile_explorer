import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'api_exceptions.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.githubApiBaseUrl,
                connectTimeout: AppConstants.connectTimeout,
                receiveTimeout: AppConstants.receiveTimeout,
                headers: {
                  'Accept': 'application/vnd.github.v3+json',
                  'User-Agent': 'Flutter-GitHub-Profile-Explorer',
                },
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          final appException = _mapDioExceptionToAppException(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: appException,
              message: appException.message,
            ),
          );
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      if (e.error is AppException) {
        throw e.error as AppException;
      }
      throw _mapDioExceptionToAppException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(e.toString());
    }
  }

  static AppException _mapDioExceptionToAppException(DioException error) {
    if (error.error is SocketException ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkException(
          'Unable to connect to GitHub. Please check your internet connection.');
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const TimeoutException('Request timed out. Please try again.');
    }

    final response = error.response;
    if (response != null) {
      final statusCode = response.statusCode;

      if (statusCode == 404) {
        final message = response.data is Map && response.data['message'] != null
            ? (response.data['message'] == 'Not Found'
                ? 'User not found. Check the username and try again.'
                : response.data['message'].toString())
            : 'User not found. Check the username and try again.';
        return NotFoundException(message);
      }

      if (statusCode == 403) {
        DateTime? resetTime;
        int? remaining;

        final resetHeader = response.headers.value('x-ratelimit-reset');
        if (resetHeader != null) {
          final epochSeconds = int.tryParse(resetHeader);
          if (epochSeconds != null) {
            resetTime = DateTime.fromMillisecondsSinceEpoch(
              epochSeconds * 1000,
              isUtc: true,
            ).toLocal();
          }
        }

        final remainingHeader = response.headers.value('x-ratelimit-remaining');
        if (remainingHeader != null) {
          remaining = int.tryParse(remainingHeader);
        }

        String msg = 'GitHub API rate limit exceeded (60 requests/hr for unauthenticated calls).';
        if (resetTime != null) {
          final minutesLeft = resetTime.difference(DateTime.now()).inMinutes;
          if (minutesLeft > 0) {
            msg += ' Resets in $minutesLeft minute${minutesLeft > 1 ? "s" : ""}.';
          }
        }

        return RateLimitException(
          message: msg,
          resetTime: resetTime,
          remaining: remaining,
        );
      }

      if (statusCode != null && statusCode >= 500) {
        return ServerException(
          'GitHub servers are currently experiencing issues (Status $statusCode).',
          statusCode,
        );
      }

      final errorMsg = response.data is Map && response.data['message'] != null
          ? response.data['message'].toString()
          : 'Request failed with status: $statusCode';
      return UnknownException(errorMsg);
    }

    if (error.type == DioExceptionType.cancel) {
      return const UnknownException('Request was cancelled.');
    }

    return const UnknownException('An unexpected network error occurred.');
  }
}
