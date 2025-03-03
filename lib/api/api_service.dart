import 'dart:developer';

import 'package:app/api/hanlder.dart';
import 'package:app/api/model/error_message.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Result> get() async {
    String errorMsm = '';
    String stackTrace = '';

    try {
      final response = await http.get(
        Uri.parse(
            'https://gist.githubusercontent.com/JhonaCodes/5031879d3a5d406d3751db314535be63/raw/4a0fdbcb1a9682dda46c6a99c76b1e34e8ee3e67/marketplace.json'),
      );

      if (response.statusCode == 200) return Result.success(response.body);
    } catch (e, stack) {
      log(e.toString());
      log(stack.toString());

      errorMsm = e.toString();
      stackTrace = stackTrace.toString();
    }

    return Result.error(ErrorMessage(
        error: errorMsm, stackInfo: StackTrace.fromString(stackTrace)));
  }
}
