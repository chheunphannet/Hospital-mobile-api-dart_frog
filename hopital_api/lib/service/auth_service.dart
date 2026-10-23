import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hopital_api/client/google_auth_client.dart';
import 'package:hopital_api/exceptions/app_exception.dart';
import 'package:hopital_api/helper/hasher.dart';
import 'package:hopital_api/models/refresh_tokens.dart';
import 'package:hopital_api/models/users.dart';
import 'package:hopital_api/repository/refresh_token_repository.dart';
import 'package:hopital_api/repository/users_repository.dart';
import 'package:hopital_api/service/jwt_service.dart';
import 'package:logging/logging.dart';

class AuthService {
  AuthService({
    required UsersRepository userRepo,
    required JwtService jwtService,
    required GoogleAuthClient googleAuthClient,
    required Hasher hasher,
    required RefreshTokenRepository refresh,
  }) : _userRepo = userRepo,
       _jwtService = jwtService,
       _googleAuthClient = googleAuthClient,
       _hasher = hasher,
       _refresh = refresh;

  final UsersRepository _userRepo;
  final JwtService _jwtService;
  final GoogleAuthClient _googleAuthClient;
  final Hasher _hasher;
  final RefreshTokenRepository _refresh;

  static final _log = Logger('AuthService');

  // 1. Register with Email and Password
  Future<AuthResult> registerWithPassword({
    required String email,
    required String password,
    String? phone,
    DeviceInfo? deviceInfo,
  }) async {
    final normalizeEmail = _normalizeEmail(email);
    _validateEmail(email);
    _validatePassword(password);

    if (await _userRepo.findByEmail(normalizeEmail) != null) {
      throw const ConflictException('Email already registered');
    }

    final user = await _createUser(
      email: normalizeEmail,
      emailVerified: false,
      passwordHash: _hasher.hash(password),
      phoneNumber: phone,
    );

    return _issueTokens(user, deviceInfo: deviceInfo);
  }

  Future<AuthResult> loginWithPassword({
    required String email,
    required String password,
    DeviceInfo? deviceInfo,
  }) async {
    final normalizeEmail = _normalizeEmail(email);
    _validateEmail(email);

    final user = await _userRepo.findByEmail(normalizeEmail);
    if (user == null || user.passwordHash == null) {
      throw const UnauthorizedException('Invalid email or password');
    }

    final isMatch = _hasher.verify(password, user.passwordHash!);
    if (!isMatch) {
      throw const UnauthorizedException('Invalid email or password');
    }

    return _issueTokens(user, deviceInfo: deviceInfo);
  }

  Future<AuthResult> loginWithGoogle({
    required String idToken,
    DeviceInfo? deviceInfo,
  }) async {
    final googleUser = await _googleAuthClient.verifyIdToken(idToken);

    var user = await _userRepo.findByGoogleId(googleUser.sub);
    if (user == null) {
      user = await _userRepo.findByEmail(googleUser.email);
      if (user == null) {
        user = await _createUser(
          email: googleUser.email,
          emailVerified: true,
          googleId: googleUser.sub,
          authProvider: 'google',
          avatarUrl: googleUser.picture,
        );
      } else {
        await _userRepo.linkGoogleAccount(
          userId: user.id!,
          googleId: googleUser.sub,
          avatarUrl: user.avatarUrl ?? googleUser.picture,
        );
      }
    }

    return _issueTokens(user, deviceInfo: deviceInfo);
  }

  Future<AuthResult> refreshToken({
    required String rawRefreshToken,
    DeviceInfo? deviceInfo,
  }) async {
    final jwt = _jwtService.verifyRefreshToken(rawRefreshToken);
    final payload = jwt.payload as Map<String, dynamic>;
    final userId = payload['userId'] as String;

    final tokenHash = sha256.convert(utf8.encode(rawRefreshToken)).toString();
    final storedToken = await _refresh.findByTokenHash(tokenHash);

    if (storedToken == null) {
      throw const UnauthorizedException('Refresh token not found');
    }

    if (storedToken.isRevoked) {
      throw const UnauthorizedException('Refresh token has been revoked');
    }

    if (storedToken.expiresAt.isBefore(DateTime.now().toUtc())) {
      throw const TokenExpiredException();
    }

    final user = await _userRepo.findById(userId);
    if (user == null) {
      throw const NotFoundException('User not found');
    }

    await _refresh.revoke(tokenHash);

    return _issueTokens(user, deviceInfo: deviceInfo);
  }

  // 5. Logout
  Future<void> logout({required String rawRefreshToken}) async {
    final tokenHash = sha256.convert(utf8.encode(rawRefreshToken)).toString();
    await _refresh.revoke(tokenHash);
  }

  Future<AuthResult> _issueTokens(
    Users user, {
    DeviceInfo? deviceInfo,
    String? branchId,
  }) async {
    final access = _jwtService.generateAccessToken(
      userId: user.id!,
      email: user.email,
      role: user.role.name,
      branchId: branchId,
    );

    final refresh = _jwtService.generateRefreshToken(
      userId: user.id!,
      email: user.email,
    );

    final tokenHash = sha256.convert(utf8.encode(refresh.token)).toString();

    final refreshTokenDoc = RefreshTokens(
      tokenHash: tokenHash,
      userId: user.id!,
      email: user.email,
      role: user.role.name,
      branchId: branchId,
      deviceInfo:
          deviceInfo ??
          const DeviceInfo(
            deviceId: 'unknown',
            platform: 'unknown',
            ipAddress: 'unknown',
          ),
      expiresAt: refresh.expiresAt,
      createdAt: refresh.createdAt,
      isRevoked: false,
    );

    await _refresh.save(refreshTokenDoc);

    return AuthResult(
      user: user,
      accessToken: access.token,
      refreshToken: refresh.token,
      accessTokenExpiresAt: access.expiresAt,
      refreshTokenExpiresAt: refresh.expiresAt,
    );
  }

  Future<Users> _createUser({
    required String email,
    required bool emailVerified,
    String? passwordHash,
    String? googleId,
    String? authProvider,
    String? phoneNumber,
    String? avatarUrl,
    PersonalInfo? personalInfo,
  }) async {
    return _userRepo.createUser(
      Users(
        email: email,
        phoneNumber: phoneNumber,
        passwordHash: passwordHash,
        googleId: googleId,
        authProvider: authProvider ?? 'local',
        avatarUrl: avatarUrl,
        isEmailVerified: emailVerified,
        personalInfo: personalInfo,
      ),
    );
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  void _validateEmail(String email) {
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!ok) throw const ValidationException('Invalid email format');
  }

  void _validatePassword(String password) {
    if (password.length < 8) {
      throw const ValidationException('Password must be at least 8 characters');
    }
  }
}

class AuthResult {
  const AuthResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
  });

  final Users user;
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
  final DateTime refreshTokenExpiresAt;

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'accessTokenExpiresAt': accessTokenExpiresAt.toIso8601String(),
    'refreshTokenExpiresAt': refreshTokenExpiresAt.toIso8601String(),
  };
}
