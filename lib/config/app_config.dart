class AppConfig {
  static const supabaseUrl =
      'https://btammoapputkbnbbscej.supabase.co';
  static const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ0YW1tb2FwcHV0a2JuYmJzY2VqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc3MzAzNjUsImV4cCI6MjA5MzMwNjM2NX0.UCkWgYTff54k9vFePlKD7ey-Nlzzvug36j8TMkXnsio';

  static const wcaClientId = String.fromEnvironment('WCA_CLIENT_ID');
  static const wcaRedirectUri = String.fromEnvironment(
    'WCA_REDIRECT_URI',
    defaultValue: 'fulltimer://wca-auth',
  );

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasWcaConfig => wcaClientId.isNotEmpty;
}
