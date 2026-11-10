import 'dart:convert';
import 'package:hopital_api/config/env.dart';
import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:http/http.dart' as http;
import 'package:khqrcode/khqrcode.dart';
import 'package:logging/logging.dart';

class BakongPaymentResult {
  final String qrString;
  final String md5Hash;
  final double amount;
  final String currency;
  final String billNumber;
  final DateTime expiresAt;

  const BakongPaymentResult({
    required this.qrString,
    required this.md5Hash,
    required this.amount,
    required this.currency,
    required this.billNumber,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() => {
    'qrString': qrString,
    'md5Hash': md5Hash,
    'amount': amount,
    'currency': currency,
    'billNumber': billNumber,
    'expiresAt': expiresAt.toIso8601String(),
  };
}

class BakongTransactionStatus {
  final bool isPaid;
  final String? transactionHash;
  final String? fromAccountId;
  final double? amount;
  final String? currency;
  final String message;

  const BakongTransactionStatus({
    required this.isPaid,
    this.transactionHash,
    this.fromAccountId,
    this.amount,
    this.currency,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
    'isPaid': isPaid,
    if (transactionHash != null) 'transactionHash': transactionHash,
    if (fromAccountId != null) 'fromAccountId': fromAccountId,
    if (amount != null) 'amount': amount,
    if (currency != null) 'currency': currency,
    'message': message,
  };
}

class BakongService {
  final http.Client _httpClient;
  static final _log = Logger('BakongService');
  static const String _checkByMd5Url =
      'https://api-bakong.nbc.gov.kh/v1/check_transaction_by_md5';

  BakongService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Generate Dynamic KHQR payload and MD5 hash for individual account
  BakongPaymentResult generateIndividualKhqr({
    required double amount,
    required String billNumber,
    String currency = 'USD',
    int expiryMinutes = 15,
    String merchantName = 'Phanet Chheun',
    String merchantCity = 'Phnom Penh',
    String acquiringBank = 'Wing Bank',
  }) {
    final isKhr = currency.toUpperCase() == 'KHR';
    final currencyCode = isKhr
        ? KHQRDataConst.currency['khr']!
        : KHQRDataConst.currency['usd']!;

    final expiresAt = DateTime.now().toUtc().add(
      Duration(minutes: expiryMinutes),
    );

    final individualInfo = IndividualInfo(
      bakongAccountId: Env.bakongUsername,
      merchantName: merchantName,
      merchantCity: merchantCity,
      acquiringBank: acquiringBank,
      currency: currencyCode,
      amount: amount,
      billNumber: billNumber,
      expirationTimestamp: expiresAt.millisecondsSinceEpoch,
    );

    final bakongKhqr = BakongKHQR();
    final result = bakongKhqr.generateIndividual(individualInfo);

    if (!result.isSuccess || result.data == null) {
      _log.severe('KHQR generation failed: ${result.status.message}');
      throw ValidationException(
        'Failed to generate KHQR: ${result.status.message ?? "Unknown error"}',
      );
    }

    return BakongPaymentResult(
      qrString: result.data!.qr,
      md5Hash: result.data!.md5Hash,
      amount: amount,
      currency: currency.toUpperCase(),
      billNumber: billNumber,
      expiresAt: expiresAt,
    );
  }

  /// Verify payment status via NBC Bakong Open API
  Future<BakongTransactionStatus> checkTransactionStatus(String md5Hash) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(_checkByMd5Url),
        headers: {
          'Authorization': 'Bearer ${Env.bakongToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'md5': md5Hash}),
      );

      if (response.statusCode != 200) {
        _log.warning(
          'Bakong API returned HTTP ${response.statusCode}: ${response.body}',
        );
        return BakongTransactionStatus(
          isPaid: false,
          message: 'Bakong API responded with HTTP ${response.statusCode}',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final responseCode = body['responseCode'];

      // responseCode == 0 means payment confirmed by NBC Bakong
      if (responseCode == 0 && body['data'] != null) {
        final data = body['data'] as Map<String, dynamic>;
        return BakongTransactionStatus(
          isPaid: true,
          transactionHash: data['hash'] as String?,
          fromAccountId: data['fromAccountId'] as String?,
          amount: (data['amount'] as num?)?.toDouble(),
          currency: data['currency'] as String?,
          message: 'Payment confirmed successfully',
        );
      }

      // responseCode == 1 means not yet settled or not found
      return BakongTransactionStatus(
        isPaid: false,
        message: body['responseMessage'] as String? ?? 'Transaction pending',
      );
    } catch (e, stack) {
      _log.severe('Exception checking Bakong transaction status', e, stack);
      return BakongTransactionStatus(
        isPaid: false,
        message: 'Failed to connect to Bakong network: $e',
      );
    }
  }
}
