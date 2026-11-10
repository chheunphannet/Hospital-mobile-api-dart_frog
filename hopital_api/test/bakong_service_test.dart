import 'dart:convert';
import 'package:hopital_api/config/env.dart';
import 'package:hopital_api/service/bakong_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:khqrcode/khqrcode.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    Env.init();
  });

  group('BakongService Tests', () {
    test('generateIndividualKhqr generates valid KHQR and MD5', () {
      final service = BakongService();
      final result = service.generateIndividualKhqr(
        amount: 25.0,
        billNumber: 'INV-TEST-99',
        currency: 'USD',
      );

      expect(result.qrString, isNotEmpty);
      expect(result.md5Hash, hasLength(32));
      expect(result.amount, equals(25.0));
      expect(result.currency, equals('USD'));

      // Verify CRC of the generated KHQR
      final verification = BakongKHQR.verify(result.qrString);
      expect(verification.isValid, isTrue);
    });

    test('checkTransactionStatus returns true when Bakong returns code 0', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), contains('check_transaction_by_md5'));
        expect(request.headers['Authorization'], contains('Bearer '));
        return http.Response(
          jsonEncode({
            'responseCode': 0,
            'responseMessage': 'Success',
            'data': {
              'hash': 'mock_transaction_hash_123',
              'fromAccountId': 'customer@aclb',
              'toAccountId': 'phanet_chheun@wing',
              'amount': 25.0,
              'currency': 'USD',
            },
          }),
          200,
        );
      });

      final service = BakongService(httpClient: mockClient);
      final status = await service.checkTransactionStatus('some_mock_md5_hash');

      expect(status.isPaid, isTrue);
      expect(status.transactionHash, equals('mock_transaction_hash_123'));
      expect(status.fromAccountId, equals('customer@aclb'));
      expect(status.amount, equals(25.0));
    });

    test('checkTransactionStatus returns false when Bakong returns code 1 (pending)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'responseCode': 1,
            'responseMessage': 'Transaction could not be found.',
            'errorCode': 1,
            'data': null,
          }),
          200,
        );
      });

      final service = BakongService(httpClient: mockClient);
      final status = await service.checkTransactionStatus('unpaid_md5_hash');

      expect(status.isPaid, isFalse);
      expect(status.message, contains('Transaction could not be found'));
    });
  });
}
