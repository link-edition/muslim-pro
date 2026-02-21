import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'core/constants.dart';
import 'features/namoz/presentation/namoz_screen.dart';
import 'features/tasbeh/presentation/tasbeh_screen.dart';
import 'features/qibla/presentation/qibla_screen.dart';
import 'features/quran/presentation/quran_screen.dart';

import 'core/notification_service.dart';
import 'core/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Bildirishnomalarni ishga tushirish
  await NotificationService.init();
  
  runApp(
    const ProviderScope(
      child: MuslimProApp(),
    ),
  );
}

/// Asosiy ilova widgeti
class MuslimProApp extends StatelessWidget {
  const MuslimProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const RootPage(), // RootPage bilan boshlaymiz
    );
  }
}

/// Ilova ildiz sahifasi — Splash dan MainScreen ga o'tishni boshqaradi
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Kamida 2 soniya splashni ko'rsatamiz
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _showSplash ? const SplashPage() : const MainScreen(),
    );
  }
}

/// Asosiy ekran — BottomNavigationBar bilan 4 ta sahifa
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    NamozScreen(),
    TasbehScreen(),
    QiblaScreen(),
    QuranScreen(),
  ];

  final List<String> _titles = const [
    'Namoz Vaqtlari',
    'Tasbeh',
    'Qibla',
    'Qur\'on',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Sozlamalar sahifasi — kelajakda
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.access_time_outlined),
            selectedIcon: Icon(Icons.access_time_filled),
            label: 'Namoz',
          ),
          NavigationDestination(
            icon: Icon(Icons.radio_button_checked_outlined),
            selectedIcon: Icon(Icons.radio_button_checked),
            label: 'Tasbeh',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Qibla',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Qur\'on',
          ),
        ],
      ),
    );
  }
}
