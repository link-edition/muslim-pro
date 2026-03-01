import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/splash_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'features/home/presentation/home_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:muslim_pro/core/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:muslim_pro/features/settings/settings_provider.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // 120 FPS ni yoqish (Faqat Android qurilmalari uchun maxsus blokirovkani olib tashlaydi)
    if (Platform.isAndroid) {
      try {
        await FlutterDisplayMode.setHighRefreshRate();
      } catch (e) {
        debugPrint('Refresh rakani o\'rnatishda xatolik: $e');
      }
    }

    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Qur\'an Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    );
    
    // Global Error Catcher
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      Fluttertoast.showToast(
        msg: "Xatolik: ${details.exception}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    };

    // Timezone initialization

    tz.initializeTimeZones();
    
    // Notification service initialization
    await NotificationService.init();
    
    // App locale and formatting
    await initializeDateFormatting('uz', null);
    Intl.defaultLocale = 'uz';

    // Battery Optimization handling for Release mode reliability
    await _handlePermissions();

    runApp(const ProviderScope(child: MuslimProApp()));
  } catch (e) {
    debugPrint('Initialization Error: $e');
    Fluttertoast.showToast(
      msg: "Xatolik yuz berdi: $e",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}

Future<void> _handlePermissions() async {
  // Request Location permission
  if (await Permission.location.isDenied) {
    await Permission.location.request();
  }

  // Battery Optimization request (to keep app alive when cable is unplugged)
  if (await Permission.ignoreBatteryOptimizations.isDenied) {
    await Permission.ignoreBatteryOptimizations.request();
  }
}


class MuslimProApp extends ConsumerWidget {
  const MuslimProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Amal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeInOut,
      locale: Locale(settings.language == 'uz_cyr' ? 'uz' : settings.language),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supported in supportedLocales) {
          if (supported.languageCode == locale?.languageCode) return supported;
        }
        return const Locale('en');
      },
      builder: (context, child) {
        final isRtl = settings.language == 'ar';
        return Directionality(
          textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(settings.fontScale),
            ),
            child: child!,
          ),
        );
      },
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
