import 'package:khqrcode/khqrcode.dart';
import 'package:test/test.dart';

void main() {
  test('generateIndividual generates valid KHQR string and MD5 hash', () {
    final individualInfo = IndividualInfo(
      bakongAccountId: 'phanet_chheun@wing',
      merchantName: 'Phanet Chheun',
      merchantCity: 'Phnom Penh',
      acquiringBank: 'Wing Bank',
      currency: KHQRDataConst.currency['usd']!,
      amount: 10.0,
      billNumber: 'TEST-001',
      expirationTimestamp: DateTime.now().add(const Duration(minutes: 15)).millisecondsSinceEpoch,
    );

    final bakongKhqr = BakongKHQR();
    final result = bakongKhqr.generateIndividual(individualInfo);

    expect(result.isSuccess, isTrue);
    expect(result.data, isNotNull);
    final qr = result.data!.qr;
    final md5Hash = result.data!.md5Hash;

    print('Generated KHQR: $qr');
    print('Generated MD5: $md5Hash');

    final verification = BakongKHQR.verify(qr);
    expect(verification.isValid, isTrue);

    final decoded = BakongKHQR.decode(qr);
    expect(decoded.isSuccess, isTrue);
    print('Decoded data: ${decoded.data?.merchantName}');
  });
}
