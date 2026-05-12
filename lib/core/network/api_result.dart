sealed class ApiResult<T> {
  const ApiResult();
  const factory ApiResult.success(T data) = ApiSuccess<T>;
  const factory ApiResult.failure(String message, {int? statusCode}) =
      ApiFailure<T>;
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);
  final T data;
}

final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
}

extension ApiResultX<T> on ApiResult<T> {
  bool get isSuccess => this is ApiSuccess<T>;

  T get data => (this as ApiSuccess<T>).data;

  String get message => (this as ApiFailure<T>).message;

  R fold<R>(
    R Function(String message) onFailure,
    R Function(T data) onSuccess,
  ) =>
      switch (this) {
        ApiSuccess(:final data) => onSuccess(data),
        ApiFailure(:final message) => onFailure(message),
      };
}
