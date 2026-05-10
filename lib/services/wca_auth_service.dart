import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

// WCA OAuth2 integration
// Register your app at: https://www.worldcubeassociation.org/oauth/applications
class WcaAuthService {
  static const _scope        = 'public email';
  static const _wcaBase      = 'https://www.worldcubeassociation.org';
  static const _tokenKey     = 'wca_token';
  static const _profileKey   = 'wca_profile';
  static const _pkceVerifierKey = 'wca_pkce_verifier';
  static const _oauthStateKey = 'wca_oauth_state';
  static const _secureStorage = FlutterSecureStorage();

  static final WcaAuthService _i = WcaAuthService._();
  factory WcaAuthService() => _i;
  WcaAuthService._();

  String? _accessToken;
  Map<String, dynamic>? _profile;

  bool get isAuthenticated => _accessToken != null;
  Map<String, dynamic>? get profile => _profile;
  bool get isConfigured => AppConfig.hasWcaConfig;

  Future<String> beginAuthFlow() async {
    if (!isConfigured) {
      throw StateError('Missing WCA_CLIENT_ID configuration.');
    }
    final state = _randomToken(32);
    final verifier = _randomToken(64);
    final challenge = _base64UrlNoPadding(sha256.convert(utf8.encode(verifier)).bytes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pkceVerifierKey, verifier);
    await prefs.setString(_oauthStateKey, state);
    return '$_wcaBase/oauth/authorize'
        '?client_id=${Uri.encodeQueryComponent(AppConfig.wcaClientId)}'
        '&redirect_uri=${Uri.encodeQueryComponent(AppConfig.wcaRedirectUri)}'
        '&response_type=code'
        '&scope=${Uri.encodeQueryComponent(_scope)}'
        '&state=${Uri.encodeQueryComponent(state)}'
        '&code_challenge=${Uri.encodeQueryComponent(challenge)}'
        '&code_challenge_method=S256';
  }

  // Exchange authorization code for token
  Future<bool> handleCallback(String code, {String? state}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expectedState = prefs.getString(_oauthStateKey);
      final verifier = prefs.getString(_pkceVerifierKey);
      if (!isConfigured || verifier == null || expectedState == null) return false;
      if (state != null && state.isNotEmpty && state != expectedState) return false;
      final resp = await http.post(
        Uri.parse('$_wcaBase/oauth/token'),
        body: {
          'grant_type':    'authorization_code',
          'code':           code,
          'client_id':      AppConfig.wcaClientId,
          'redirect_uri':   AppConfig.wcaRedirectUri,
          'code_verifier':  verifier,
        },
      );
      if (resp.statusCode != 200) return false;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      _accessToken = data['access_token'] as String?;
      if (_accessToken == null) return false;
      await _secureStorage.write(key: _tokenKey, value: _accessToken!);
      await prefs.remove(_pkceVerifierKey);
      await prefs.remove(_oauthStateKey);
      await _fetchProfile();
      return true;
    } catch (_) { return false; }
  }

  Future<void> _fetchProfile() async {
    if (_accessToken == null) return;
    try {
      final resp = await http.get(
        Uri.parse('$_wcaBase/api/v0/me'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      if (resp.statusCode == 200) {
        _profile = (jsonDecode(resp.body) as Map)['me'] as Map<String, dynamic>?;
        if (_profile != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_profileKey, jsonEncode(_profile));
        }
      }
    } catch (_) {}
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = await _secureStorage.read(key: _tokenKey);
    final profileStr = prefs.getString(_profileKey);
    if (profileStr != null) {
      _profile = jsonDecode(profileStr) as Map<String, dynamic>?;
    }
    if (_accessToken != null && _profile != null) {
      await _fetchProfile(); // refresh
    }
  }

  Future<void> signOut() async {
    _accessToken = null; _profile = null;
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.delete(key: _tokenKey);
    await prefs.remove(_profileKey);
    await prefs.remove(_pkceVerifierKey);
    await prefs.remove(_oauthStateKey);
  }

  // Get WCA competition results for a user
  Future<List<Map<String, dynamic>>> getPersonalResults(String wcaId) async {
    try {
      final resp = await http.get(Uri.parse('$_wcaBase/api/v0/persons/$wcaId/'));
      if (resp.statusCode != 200) return [];
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return (data['personal_records'] as List? ?? [])
          .cast<Map<String, dynamic>>();
    } catch (_) { return []; }
  }

  String _randomToken(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  String _base64UrlNoPadding(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}
