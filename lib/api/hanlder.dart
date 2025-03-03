import 'package:app/api/model/error_message.dart';

class Result<T> {
  final ErrorMessage? error;
  final T? data;

  Result({this.error, this.data});

  Result.error(this.error) : data = null;

  Result.success(this.data) : error = null;

  bool get isSuccess => error == null;

  R when<R>(
      {required R Function(T data) success,
      required R Function(String error, StackTrace? stackTrace) failure}) {
    if (isSuccess && this.data != null) return success(this.data as T);

    return failure(this.error?.error.toString() ?? '', this.error?.stackInfo);
  }
}
