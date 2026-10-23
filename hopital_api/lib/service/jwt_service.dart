import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:hopital_api/config/env.dart';
import 'package:hopital_api/exceptions/app_exception.dart';

class TokenDetails {
  final String token;
  final DateTime createdAt;
  final DateTime expiresAt;

  const TokenDetails({
    required this.token,
    required this.createdAt,
    required this.expiresAt,
  });
}

class JwtService {
  // Generate short-lived Access Token with expiry metadata
  TokenDetails generateAccessToken({
    required String userId,
    required String email,
    required String role,
    String? branchId,
  }) {
    final now = DateTime.now().toUtc();
    final expiresAt = now.add(Duration(minutes: Env.accessTokenTTL));

    final jwt = JWT({
      'userId': userId,
      'email': email,
      'role': role,
      if (branchId != null) 'branchId': branchId,
    });

    final token = jwt.sign(
      SecretKey(Env.jwtAccessTokenSecret),
      expiresIn: Duration(minutes: Env.accessTokenTTL),
    );

    return TokenDetails(
      token: token,
      createdAt: now,
      expiresAt: expiresAt,
    );
  }

  // Generate long-lived Refresh Token with expiry metadata
  TokenDetails generateRefreshToken({
    required String userId,
    required String email,
  }) {
    final now = DateTime.now().toUtc();
    final expiresAt = now.add(Duration(days: Env.refreshTokenTTL));

    final jwt = JWT({'userId': userId, 'email': email});

    final token = jwt.sign(
      SecretKey(Env.jwtRefreshTokenSecret),
      expiresIn: Duration(days: Env.refreshTokenTTL),
    );

    return TokenDetails(
      token: token,
      createdAt: now,
      expiresAt: expiresAt,
    );
  }

  // Verify Access Token
  JWT verifyAccessToken(String token) {
    try {
      return JWT.verify(token, SecretKey(Env.jwtAccessTokenSecret));
    } on JWTExpiredException {
      throw const TokenExpiredException();
    } on JWTException {
      throw const UnauthorizedException('Invalid token');
    }
  }

  // Verify Refresh Token
  JWT verifyRefreshToken(String token) {
    try {
      return JWT.verify(token, SecretKey(Env.jwtRefreshTokenSecret));
    } on JWTExpiredException {
      throw const TokenExpiredException();
    } on JWTException {
      throw const UnauthorizedException('Invalid token');
    }
  }
}
