import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:hopital_api/config/env.dart';
import 'package:hopital_api/exceptions/app_exception.dart';

class JwtService {
  // Generate short-lived Access Token
  String generateAccessToken({
    required String userId,
    required String email,
    required String role,
    String? branchId,
  }) {
    final jwt = JWT({
      'userId': userId,
      'email': email,
      'role': role,
      if (branchId != null) 'branchId': branchId,
    });

    return jwt.sign(
      SecretKey(Env.jwtAccessTokenSecret),
      expiresIn: Duration(minutes: Env.accessTokenTTL),
    );
  }

  // Generate long-lived Refresh Token
  String generateRefreshToken({required String userId, required String email}) {
    final jwt = JWT({'userId': userId, 'email': email});

    return jwt.sign(
      SecretKey(Env.jwtRefreshTokenSecret),
      expiresIn: Duration(days: Env.refreshTokenTTL),
    );
  }

  //Verify Access Token
  JWT verifyAccessToken(String token) {
    try {
      return JWT.verify(token, SecretKey(Env.jwtAccessTokenSecret));
    } on JWTExpiredException {
      throw const TokenExpiredException();
    } on JWTException {
      throw const UnauthorizedException('Invalid token');
    }
  }

  //Verify Refresh Token
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
