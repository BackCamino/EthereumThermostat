
import 'dart:convert';

import 'package:http/http.dart' as http;

class CompilerUtil {

  static final Map<String, String> headers = {
    "Content-type": "application/json",
    "accept": "application/json"
  };

  static final CompilerUtil _compilerUtil = CompilerUtil._internal();

  factory CompilerUtil() => _compilerUtil;

  CompilerUtil._internal();

  Future<String> fetchAbi() async {

  }

  Future<String> fetchBin() async {
    http.Response response;
    response = await http.get(
      'http://sol-compiler.herokuapp.com/translate',
      headers: headers,
    );
  }

  String requestBinBody() {
    return jsonEncode({
      
    });
  }
}