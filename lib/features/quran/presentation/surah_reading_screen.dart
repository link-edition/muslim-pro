import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../data/quran_model.dart';
import '../data/mushaf_download_service.dart';
import '../quran_provider.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _playingAyahId;

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
    _audioPlayer.dispose();
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
                   return _MushafTextPage(
                     pageNum: page,
                     theme: _theme,
                     isTajweedMode: _isTajweedMode,
                     audioPlayer: _audioPlayer,
                     onCopy: _copyAyah,
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

  void _copyAyah(AyahModel ayah) {
    Clipboard.setData(ClipboardData(text: ayah.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Oyat nusxalandi: ${ayah.verseKey}'),
        backgroundColor: _gold,
        duration: const Duration(seconds: 2),
      )
    );
  }
}

class _MushafTextPage extends ConsumerStatefulWidget {
  final int pageNum;
  final _BgTheme theme;
  final bool isTajweedMode;
  final AudioPlayer audioPlayer;
  final Function(AyahModel) onCopy;

  const _MushafTextPage({
    required this.pageNum,
    required this.theme,
    required this.isTajweedMode,
    required this.audioPlayer,
    required this.onCopy,
  });

  @override
  ConsumerState<_MushafTextPage> createState() => _MushafTextPageState();
}

class _MushafTextPageState extends ConsumerState<_MushafTextPage> {
  String? _playingKey;

  void _showAudioMenu(BuildContext context, AyahModel ayah, Color bg, Color txtC, Color gold) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Oyat ${ayah.verseKey}", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: txtC)),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.play_circle_fill, color: gold, size: 36),
                title: Text("Mishary Rashid Al-Afasy", style: TextStyle(color: txtC)),
                subtitle: Text("Ushbu oyatni tinglash", style: TextStyle(color: txtC.withOpacity(0.6))),
                onTap: () {
                  Navigator.pop(ctx);
                  _playAyah(ayah);
                },
              ),
              ListTile(
                leading: Icon(Icons.copy, color: gold, size: 36),
                title: Text("Nusxa olish", style: TextStyle(color: txtC)),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onCopy(ayah);
                },
              )
            ],
          ),
        );
      }
    );
  }

  Future<void> _playAyah(AyahModel ayah) async {
    setState(() => _playingKey = ayah.verseKey);
    final parts = ayah.verseKey.split(':');
    final s = parts[0].padLeft(3, '0');
    final a = parts[1].padLeft(3, '0');
    final url = "https://download.quranicaudio.com/quran/mishari_rashid_al-afasy/$s$a.mp3";
    try {
      await widget.audioPlayer.setUrl(url);
      await widget.audioPlayer.play();
    } catch (e) {
      debugPrint("Audio error: $e");
    } finally {
      if (mounted) setState(() => _playingKey = null);
    }
  }

  String _arabicNumber(int num) {
    const chars = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return num.toString().split('').map((e) => chars[int.parse(e)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final ayahsAsync = ref.watch(mushafPageProvider(widget.pageNum));
    
    final bgc = widget.theme == _BgTheme.light ? const Color(0xFFFFFEF9) : (widget.theme == _BgTheme.sepia ? const Color(0xFFF3EEE1) : const Color(0xFF1C1C1C));
    final txtC = widget.theme == _BgTheme.dark ? Colors.white : Colors.black87;

    return Container(
      color: bgc,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: ayahsAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: _gold.withOpacity(0.5))),
        error: (err, stack) => Center(child: Text('Xatolik: $err', style: TextStyle(color: Colors.red))),
        data: (ayahs) {
          if (ayahs.isEmpty) return const Center(child: Text("Ma'lumot topilmadi"));
          
          return SingleChildScrollView(
            child: RichText(
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
              text: TextSpan(
                children: ayahs.map((ayah) {
                  final isPlaying = _playingKey == ayah.verseKey;
                  final textToShow = widget.isTajweedMode && ayah.textTajweed != null 
                      ? ayah.textTajweed!.replaceAll(RegExp(r'<[^>]*>'), "") // Tajweed HTML (agar bor bo'lsa) standart qilinadi, lekin rangli span logikasi qo'shsa bo'ladi.
                      : ayah.text;

                  // Oyat boshi yoki Bismillah
                  String bismillah = '';
                  if (ayah.numberInSurah == 1 && ayah.verseKey != '1:1' && ayah.verseKey != '9:1') {
                    bismillah = "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ\n";
                  }

                  return TextSpan(
                    children: [
                      if (bismillah.isNotEmpty)
                        TextSpan(
                          text: bismillah,
                          style: GoogleFonts.amiriQuran(fontSize: 26, color: widget.theme == _BgTheme.dark ? _gold : const Color(0xFFB8860B), height: 2.2),
                        ),
                      TextSpan(
                        text: textToShow + ' ',
                        style: GoogleFonts.amiriQuran(
                          fontSize: 28, 
                          color: isPlaying ? _gold : txtC, 
                          height: 2.3,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          _showAudioMenu(context, ayah, bgc, txtC, _gold);
                        },
                      ),
                      TextSpan(
                        text: ' ﴿${_arabicNumber(ayah.numberInSurah)}﴾ ',
                        style: GoogleFonts.amiriQuran(fontSize: 24, color: _gold),
                        recognizer: LongPressGestureRecognizer()..onLongPress = () {
                          widget.onCopy(ayah);
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}


