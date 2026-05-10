class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static const wcaClientId = String.fromEnvironment('WCA_CLIENT_ID');
  static const wcaRedirectUri = String.fromEnvironment(
    'WCA_REDIRECT_URI',
    defaultValue: 'speedcubetimer://wca-auth',
  );

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasWcaConfig => wcaClientId.isNotEmpty;
}
