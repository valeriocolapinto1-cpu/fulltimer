import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/session_provider.dart';
import 'providers/timer_provider.dart';
import 'providers/l10n_provider.dart';
import 'services/storage_service.dart';
import 'services/supabase_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Supabase
  await SupabaseService.initialize();

  final storage  = StorageService();    await storage.init();
  final settings = SettingsProvider();  await settings.init();
  final session  = SessionProvider(storage); await session.init();
  final l10n     = L10n();             await l10n.init();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: settings),
    ChangeNotifierProvider.value(value: session),
    ChangeNotifierProvider.value(value: l10n),
    ChangeNotifierProvider(create: (_) => TimerProvider()),
  ], child: const FullTimerApp()));
}
