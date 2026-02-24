import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/quran_model.dart';
import '../data/mushaf_download_service.dart';

// ==========================================
// MUSHAF — OFLAYN O'QISH
// ==========================================

enum _BgTheme { light, sepia, dark }

const _gold = Color(0xFFD4A843);

class SurahReadingScreen extends ConsumerStatefulWidget {
  final SurahModel surah;
  const SurahReadingScreen({super.key, required this.surah});

  @override
  ConsumerState<SurahReadingScreen> createState() => _State();
}

class _State extends ConsumerState<SurahReadingScreen> {
  var _theme = _BgTheme.sepia;
  bool _isTajweedMode = false;
  late int _currentPage;
  late PageController _pc;
  String? _appDir;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.surah.startPage;
    _pc = PageController(initialPage: _currentPage - 1);
    _loadSettings();
    _initDir();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isTajweedMode = prefs.getBool('is_tajweed_mode_enabled') ?? false;
        final themeIdx = prefs.getInt('mushaf_theme_index') ?? 1;
        _theme = _BgTheme.values[themeIdx];
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_tajweed_mode_enabled', _isTajweedMode);
    await prefs.setInt('mushaf_theme_index', _theme.index);
  }

  Future<void> _initDir() async {
    final dir = await getApplicationDocumentsDirectory();
    if (mounted) {
      setState(() {
        _appDir = dir.path;
      });
    }
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  Color _bg(_BgTheme t) => switch (t) {
    _BgTheme.light => const Color(0xFFFFFEF9),
    _BgTheme.sepia => const Color(0xFFF3EEE1),
    _BgTheme.dark => const Color(0xFF1C1C1C),
  };
  Color _mut(_BgTheme t) => switch (t) {
    _BgTheme.light => const Color(0xFF999999),
    _BgTheme.sepia => const Color(0xFF8B8178),
    _BgTheme.dark => const Color(0xFF666666),
  };
  Color _txtC(_BgTheme t) => switch (t) {
    _BgTheme.light => const Color(0xFF333333),
    _BgTheme.sepia => const Color(0xFF4A3728),
    _BgTheme.dark => const Color(0xFFCCCCCC),
  };

  @override
  Widget build(BuildContext context) {
    final downloadState = ref.watch(mushafDownloadProvider);
    final bool isReady = _isTajweedMode ? downloadState.isTajweedDownloaded : downloadState.isStandardDownloaded;
    final bool isCurrentlyDownloadingThis = downloadState.isDownloading && 
        ((_isTajweedMode && downloadState.downloadingType == MushafType.tajweed) ||
         (!_isTajweedMode && downloadState.downloadingType == MushafType.standard));

    return Scaffold(
      backgroundColor: _bg(_theme),
      body: SafeArea(
        child: Stack(
          children: [
            // ASOSIY QISM
            if (_appDir == null)
              const Center(child: CircularProgressIndicator(color: _gold))
            else
               // 604 BETLIK PAGEVIEW — doim ko'rsatiladi! Fonda zip tortiladi, rasm yo'q bo'lsa darhol priority download qilinadi.
               PageView.builder(
                 controller: _pc,
                 reverse: true, // O'ngdan chapga (arabcha uslub)
                 itemCount: 604,
                 onPageChanged: (i) => setState(() => _currentPage = i + 1),
                 itemBuilder: (_, i) {
                   final page = i + 1;
                   final folder = _isTajweedMode ? 'tajweed_pages' : 'mushaf_pages';
                   return _MushafLocalPage(
                     pageNum: page,
                     theme: _theme,
                     baseDir: '$_appDir/$folder',
                     // Tajvid rejimida rasmning o'z ranglari muhim, shuning uchun invert qilmaymiz
                     disableInvert: _isTajweedMode,
                   );
                 },
               ),

            // Tepki qism
            _buildHeader(isReady, isCurrentlyDownloadingThis, downloadState),

            // Pastki qism
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isReady, bool isCurrentlyDownloadingThis, MushafDownloadState dl) {
    return Positioned(
      top: 8, left: 12, right: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _bg(_theme).withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                  ),
                  child: Icon(Icons.arrow_back_ios_new, size: 18, color: _txtC(_theme).withOpacity(0.6)),
                ),
              ),
              if (isCurrentlyDownloadingThis)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _bg(_theme).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dl.progress < 604 ? 'Yuklanmoqda: ${dl.progress}/604' : 'Ochilmoqda...',
                    style: GoogleFonts.poppins(fontSize: 10, color: _gold, fontWeight: FontWeight.bold),
                  ),
                ),
              GestureDetector(
                onTap: _showSettings,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _bg(_theme).withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                  ),
                  child: Icon(Icons.tune, size: 20, color: _txtC(_theme).withOpacity(0.6)),
                ),
              ),
            ],
          ),
          if (isCurrentlyDownloadingThis)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: LinearProgressIndicator(
                value: dl.progress / 604,
                backgroundColor: _gold.withOpacity(0.2),
                color: _gold,
                minHeight: 3,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Positioned(
      bottom: 8, left: 0, right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: _bg(_theme).withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$_currentPage / 604',
            style: GoogleFonts.poppins(fontSize: 12, color: _mut(_theme), fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _theme == _BgTheme.dark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Sozlamalar', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: _theme == _BgTheme.dark ? Colors.white : Colors.black)),
            const SizedBox(height: 24),
            
            // Rejim tanlash
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: (_theme == _BgTheme.dark ? Colors.white : Colors.black).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Expanded(child: _modeBtn('Standard', !_isTajweedMode, () {
                  setState(() => _isTajweedMode = false);
                  setModalState(() {});
                  _saveSettings();
                })),
                Expanded(child: _modeBtn('Tajvid', _isTajweedMode, () {
                  setState(() => _isTajweedMode = true);
                  setModalState(() {});
                  _saveSettings();
                })),
              ]),
            ),
            
            const SizedBox(height: 24),
            Text('Sahifa rangi', style: GoogleFonts.poppins(fontSize: 14, color: _theme == _BgTheme.dark ? Colors.white70 : Colors.black54)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _cDot(_BgTheme.light, Colors.white, 'Oq', ctx),
              _cDot(_BgTheme.sepia, const Color(0xFFF3EEE1), 'Sepia', ctx),
              _cDot(_BgTheme.dark, const Color(0xFF1C1C1C), 'Qora', ctx),
            ]),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  Widget _modeBtn(String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? _gold : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? Colors.white : (_theme == _BgTheme.dark ? Colors.white54 : Colors.black54))),
        ),
      ),
    );
  }

  Widget _cDot(_BgTheme t, Color c, String label, BuildContext ctx) {
    final selected = _theme == t;
    return GestureDetector(
      onTap: () { 
        setState(() => _theme = t); 
        _saveSettings();
        Navigator.pop(ctx); 
      },
      child: Column(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: c,
            shape: BoxShape.circle,
            border: Border.all(color: selected ? _gold : Colors.grey.withOpacity(0.2), width: selected ? 3 : 1),
            boxShadow: selected ? [BoxShadow(color: _gold.withOpacity(0.3), blurRadius: 8)] : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: selected ? _gold : Colors.grey)),
      ]),
    );
  }
}

class _MushafLocalPage extends ConsumerStatefulWidget {
  final int pageNum;
  final _BgTheme theme;
  final String baseDir;
  final bool disableInvert;

  const _MushafLocalPage({
    required this.pageNum,
    required this.theme,
    required this.baseDir,
    this.disableInvert = false,
  });

  @override
  ConsumerState<_MushafLocalPage> createState() => _MushafLocalPageState();
}

class _MushafLocalPageState extends ConsumerState<_MushafLocalPage> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkOrDownload();
  }

  @override
  void didUpdateWidget(covariant _MushafLocalPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageNum != widget.pageNum || oldWidget.baseDir != widget.baseDir) {
      _checkOrDownload();
    }
  }

  Future<void> _checkOrDownload() async {
    setState(() { _isLoading = true; _hasError = false; });
    final p = widget.pageNum.toString().padLeft(3, '0');
    final file = File('${widget.baseDir}/page$p.png');
    
    if (!file.existsSync() || file.lengthSync() < 1000) {
      // Prioritet yuklashni boshlash
      final type = widget.baseDir.contains('tajweed') ? MushafType.tajweed : MushafType.standard;
      try {
        await ref.read(mushafDownloadProvider.notifier).priorityDownloadPage(type, widget.pageNum);
      } catch (e) {
        if (mounted) setState(() => _hasError = true);
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: widget.theme == _BgTheme.light ? const Color(0xFFFFFEF9) : (widget.theme == _BgTheme.sepia ? const Color(0xFFF3EEE1) : const Color(0xFF1C1C1C)),
        child: Center(child: CircularProgressIndicator(color: _gold.withOpacity(0.5))),
      );
    }

    final p = widget.pageNum.toString().padLeft(3, '0');
    final file = File('${widget.baseDir}/page$p.png');
    final isDark = widget.theme == _BgTheme.dark;

    return Container(
      color: widget.theme == _BgTheme.light ? const Color(0xFFFFFEF9) : (widget.theme == _BgTheme.sepia ? const Color(0xFFF3EEE1) : const Color(0xFF1C1C1C)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Image.file(
        file,
        fit: BoxFit.contain,
        // Tajvid rejimida ranglarni o'zgartirmaymiz, aks holda qoidalar ko'rinmay qoladi
        color: (isDark && !widget.disableInvert) ? Colors.white : null,
        colorBlendMode: (isDark && !widget.disableInvert) ? BlendMode.srcIn : null,
        errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      ),
    );
  }
}

