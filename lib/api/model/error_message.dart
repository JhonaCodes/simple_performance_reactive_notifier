class ErrorMessage {
  final String? title;
  final String? content;
  final Object? error;
  final StackTrace? stackInfo;
  ErrorMessage({this.error, this.title, this.content, this.stackInfo});
}
