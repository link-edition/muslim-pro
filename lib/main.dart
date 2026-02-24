import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme.dart';
import 'core/splash_page.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/quran/data/mushaf_download_service.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:muslim_pro/core/notification_service.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService.init();
  await initializeDateFormatting('uz', null);
  Intl.defaultLocale = 'uz';
  runApp(const ProviderScope(child: MuslimProApp()));
}


class MuslimProApp extends StatelessWidget {
  const MuslimProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muslim Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: const Locale('uz', 'UZ'),
      supportedLocales: const [
        Locale('uz', 'UZ'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const RootPage(),
    );
  }
}

/// Splash -> Home o'tish
class RootPage extends ConsumerStatefulWidget {
  const RootPage({super.key});

  @override
  ConsumerState<RootPage> createState() => _RootPageState();
}

class _RootPageState extends ConsumerState<RootPage> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Mushaf yuklashni boshlash (background)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mushafDownloadProvider.notifier).checkStatus();
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _showSplash ? const SplashPage() : const HomeScreen(),
    );
  }
}
