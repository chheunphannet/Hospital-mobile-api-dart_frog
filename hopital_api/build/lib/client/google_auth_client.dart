import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:http/http.dart' as http;

class GoogleAuthClient {
  GoogleAuthClient({required this.clientId, http.Client? client})
    : _http = client ?? http.Client();

  final String clientId; // your Google OAuth client ID
  final http.Client _http;

  static final _certsUrl = Uri.parse(
    'https://www.googleapis.com/oauth2/v1/certs',
  );
  static const _validIssuers = {
    'https://accounts.google.com',
    'accounts.google.com',
  };

  Map<String, String> _certs = {};
  DateTime _certsFetchedAt = DateTime.fromMillisecondsSinceEpoch(0);

  Future<GoogleUser> verifyIdToken(String idToken) async {
    try {
      final kid =
          JWT.decode(idToken).header?['kid'] as String?; //Read the key id (kid)
      if (kid == null) {
        throw const UnauthorizedException('Invalid google token');
      }

      final pem = await _certFor(kid); //matching Google certificate
      if (pem == null) {
        throw const UnauthorizedException('Invalid Google token');
      }

      final jwt = JWT.verify(idToken, RSAPublicKey.cert(pem));
      final p = jwt.payload as Map<String, dynamic>;

      if (!_validIssuers.contains(p['iss'])) {
        throw const UnauthorizedException('Invalid Gooogle token');
      }

      if (p['aud'] != clientId) {
        throw const UnauthorizedException('Invalid Google token');
      }

      if (p['email_verified'] != true) {
        throw const UnauthorizedException('Google email not verified');
      }

      return GoogleUser(
        sub: p['sub'] as String,
        email: (p['email'] as String).toLowerCase(),
        name: p['name'] as String?,
        picture: p['picture'] as String?,
      );
    } on JWTExpiredException {
      throw const UnauthorizedException('Google token expired');
    } on JWTException {
      throw const UnauthorizedException('Invalid Google token');
    }
  }

  Future<String?> _certFor(String kid) async {
    final stale =
        DateTime.now().difference(_certsFetchedAt) > const Duration(hours: 1);
    if (stale || !_certs.containsKey(kid)) {
      final res = await _http.get(_certsUrl);
      if (res.statusCode == 200) {
        _certs = (jsonDecode(res.body) as Map<String, dynamic>)
            .cast<String, String>();
        _certsFetchedAt = DateTime.now();
      }
    }
    return _certs[kid];
  }
}

class GoogleUser {
  const GoogleUser({
    required this.sub,
    required this.email,
    this.name,
    this.picture,
  });
  final String sub;
  final String email;
  final String? name;
  final String? picture;
}
