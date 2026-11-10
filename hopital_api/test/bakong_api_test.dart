import 'dart:convert';
import 'package:hopital_api/config/env.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  test('Bakong API check transaction endpoint test', () async {
    Env.init();
    final token = Env.bakongToken;
    final username = Env.bakongUsername;

    print('Bakong username: $username');
    print('Bakong token prefix: ${token.substring(0, 15)}...');

    final response = await http.post(
      Uri.parse('https://api-bakong.nbc.gov.kh/v1/check_transaction_by_md5'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'md5': '6b780735975f7a5b4b170510c9416dd8',
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  });
}
