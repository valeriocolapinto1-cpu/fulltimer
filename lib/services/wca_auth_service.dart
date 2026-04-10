import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// WCA OAuth2 integration
// Register your app at: https://www.worldcubeassociation.org/oauth/applications
class WcaAuthService {
  static const _clientId =
      'x6c97KCb6GdX2HFBPjxSQS9zzVIGXSSOZk8FUHzl69A'; // Replace with real client ID
  static const _clientSecret =
      'H1nlFRvEMnF8ASQM6AZSpSBBpFKrobEcgmkAmKg8tIw'; // Replace with real secret
  static const _redirectUri = 'fulltimer://oauth-callback';
  static const _scope = 'public email';
  static const _wcaBase = 'https://www.worldcubeassociation.org';
  static const _tokenKey = 'wca_token';
  static const _profileKey = 'wca_profile';

  static final WcaAuthService _i = WcaAuthService._();
  factory WcaAuthService() => _i;
  WcaAuthService._();

  String? _accessToken;
  Map<String, dynamic>? _profile;

  bool get isAuthenticated => _accessToken != null;
  Map<String, dynamic>? get profile => _profile;

  // Build OAuth2 authorization URL
  String get authUrl => '$_wcaBase/oauth/authorize'
      '?client_id=$_clientId'
      '&redirect_uri=${Uri.encodeComponent(_redirectUri)}'
      '&response_type=code'
      '&scope=${Uri.encodeComponent(_scope)}';

  // Exchange authorization code for token
  Future<bool> handleCallback(String code) async {
    try {
      final resp = await http.post(
        Uri.parse('$_wcaBase/oauth/token'),
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'redirect_uri': _redirectUri,
        },
      );
      if (resp.statusCode != 200) return false;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      _accessToken = data['access_token'] as String?;
      if (_accessToken == null) return false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _accessToken!);
      await _fetchProfile();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _fetchProfile() async {
    if (_accessToken == null) return;
    try {
      final resp = await http.get(
        Uri.parse('$_wcaBase/api/v0/me'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      if (resp.statusCode == 200) {
        _profile =
            (jsonDecode(resp.body) as Map)['me'] as Map<String, dynamic>?;
        if (_profile != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_profileKey, jsonEncode(_profile));
        }
      }
    } catch (_) {}
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_tokenKey);
    final profileStr = prefs.getString(_profileKey);
    if (profileStr != null) {
      _profile = jsonDecode(profileStr) as Map<String, dynamic>?;
    }
    if (_accessToken != null && _profile != null) {
      await _fetchProfile(); // refresh
    }
  }

  Future<void> signOut() async {
    _accessToken = null;
    _profile = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_profileKey);
  }

  // Get WCA competition results for a user
  Future<List<Map<String, dynamic>>> getPersonalResults(String wcaId) async {
    try {
      final resp =
          await http.get(Uri.parse('$_wcaBase/api/v0/persons/$wcaId/'));
      if (resp.statusCode != 200) return [];
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return (data['personal_records'] as List? ?? [])
          .cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
