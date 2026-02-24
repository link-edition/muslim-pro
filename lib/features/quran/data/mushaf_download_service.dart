import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archive/archive_io.dart';

enum MushafType { standard, tajweed }

final mushafDownloadProvider = StateNotifierProvider<MushafDownloadNotifier, MushafDownloadState>((ref) {
  return MushafDownloadNotifier();
});

class MushafDownloadState {
  final bool isStandardDownloaded;
  final bool isTajweedDownloaded;
  final bool isDownloading;
  final MushafType downloadingType;
  final int progress;
  final String? error;

  MushafDownloadState({
    required this.isStandardDownloaded,
    required this.isTajweedDownloaded,
    required this.isDownloading,
    this.downloadingType = MushafType.standard,
    required this.progress,
    this.error,
  });

  MushafDownloadState copyWith({
    bool? isStandardDownloaded,
    bool? isTajweedDownloaded,
    bool? isDownloading,
    MushafType? downloadingType,
    int? progress,
    String? error,
  }) {
    return MushafDownloadState(
      isStandardDownloaded: isStandardDownloaded ?? this.isStandardDownloaded,
      isTajweedDownloaded: isTajweedDownloaded ?? this.isTajweedDownloaded,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadingType: downloadingType ?? this.downloadingType,
      progress: progress ?? this.progress,
      error: error,
    );
  }
}

class MushafDownloadNotifier extends StateNotifier<MushafDownloadState> {
  MushafDownloadNotifier() : super(MushafDownloadState(
    isStandardDownloaded: false, 
    isTajweedDownloaded: false, 
    isDownloading: false, 
    progress: 0
  )) {
    checkStatus();
  }

  CancelToken? _cancelToken;
  bool _isZipDownloading = false;

  Future<void> checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final dir = await getApplicationDocumentsDirectory();
    
    // Standard check
    bool standardOk = prefs.getBool('is_mushaf_downloaded') ?? false;
    if (standardOk) {
      final stdDir = Directory('${dir.path}/mushaf_pages');
      if (!stdDir.existsSync() || stdDir.listSync().whereType<File>().length < 604) {
        standardOk = false;
        prefs.setBool('is_mushaf_downloaded', false);
      }
    }

    // Tajweed check
    bool tajweedOk = prefs.getBool('is_tajweed_downloaded') ?? false;
    if (tajweedOk) {
      final tjDir = Directory('${dir.path}/tajweed_pages');
      if (!tjDir.existsSync() || tjDir.listSync().whereType<File>().length < 604) {
        tajweedOk = false;
        prefs.setBool('is_tajweed_downloaded', false);
      }
    }
    
    state = state.copyWith(
      isStandardDownloaded: standardOk,
      isTajweedDownloaded: tajweedOk,
    );

    // Agar standard yoki tajvid yuklanmagan bo'lsa, jimgina fonda boshlash
    if (!standardOk && !_isZipDownloading) {
      startDownload(MushafType.standard);
    }
  }

  /// ZIP faylni fonda yuklash
  Future<void> startDownload(MushafType type) async {
    if (_isZipDownloading) {
      if (state.downloadingType == type) return; 
      _cancelToken?.cancel('Switched type');
    }

    _isZipDownloading = true;
    state = state.copyWith(isDownloading: true, downloadingType: type, progress: 0, error: null);

    // Yangi Backend API manzili (User Render-dan olgach buni almashtirishi kerak)
    const String baseUrl = 'https://muslim-app-backend.onrender.com/api';

    final String zipUrl = type == MushafType.standard
      ? '$baseUrl/mushaf/standard'
      : '$baseUrl/mushaf/tajweed';

    try {
      final dir = await getApplicationDocumentsDirectory();
      final folderName = type == MushafType.standard ? 'mushaf_pages' : 'tajweed_pages';
      final rootDir = dir.path;
      final targetDir = Directory('$rootDir/$folderName');
      
      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }

      final zipPath = '$rootDir/${folderName}_temp.zip';
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 45);
      dio.options.receiveTimeout = const Duration(seconds: 45);
      _cancelToken = CancelToken();

      debugPrint('MUSHAF: ZIP yuklash boshlandi -> $zipUrl');

      // 1. ZIP faylni yuklash (rezume funksionalisiz oddiy yuklab olamiz, chunki tez)
      bool downloadSuccess = false;
      for (int i = 1; i <= 3; i++) { // 3 marta urinish (Internet uzilganda)
        try {
          await dio.download(
            zipUrl, 
            zipPath,
            cancelToken: _cancelToken,
            onReceiveProgress: (received, total) {
              if (total != -1 && mounted) {
                // Progressni 0-100% orqali emas, qandaydir tushunarli usulda yangilash 
                // Bizda progress avval 1 dan 604 gacha edi, hozir buni "foiz" ga o'xshatib yozamiz
                int fakeProgress = ((received / total) * 604).toInt();
                // Faqat 10 da 1 yangilaymiz ki ui qotmasin
                if (fakeProgress % 5 == 0) {
                  state = state.copyWith(progress: fakeProgress > 604 ? 604 : fakeProgress);
                }
              }
            },
          );
          downloadSuccess = true;
          break;
        } catch (e) {
          if (e is DioException && CancelToken.isCancel(e)) {
            debugPrint('MUSHAF: Yuklash toxtatildi.');
            _isZipDownloading = false;
            return;
          }
          debugPrint('MUSHAF: Xato (Urinish $i): $e');
          await Future.delayed(Duration(seconds: i * 3));
        }
      }

      if (!downloadSuccess) {
        throw Exception("Internet tarmog'ida nosozlik sababli faylni yuklab bo'lmadi.");
      }

      debugPrint('MUSHAF: ZIP muvaffaqiyatli yuklandi. Extract boshlandi...');
      state = state.copyWith(progress: 604); // To'lganini bildirish

      // 2. ZIP ni arxivdan chiqarish (Isolate orqali UI qotmaydi)
      await compute(_extractZip, {
        'zipPath': zipPath,
        'targetPath': targetDir.path,
      });

      // 3. Tozalash (zip faylini ochirish)
      final tempZipFile = File(zipPath);
      if (tempZipFile.existsSync()) {
        tempZipFile.deleteSync();
      }

      final prefs = await SharedPreferences.getInstance();
      if (type == MushafType.standard) {
        await prefs.setBool('is_mushaf_downloaded', true);
        state = state.copyWith(isStandardDownloaded: true);
      } else {
        await prefs.setBool('is_tajweed_downloaded', true);
        state = state.copyWith(isTajweedDownloaded: true);
      }
      
      _isZipDownloading = false;
      if (mounted) {
        state = state.copyWith(isDownloading: false, progress: 0);
      }
      debugPrint('MUSHAF: Barchasi tayyor!');
      
    } catch (e) {
      _isZipDownloading = false;
      if (e is! DioException || !CancelToken.isCancel(e)) {
        debugPrint('MUSHAF DOWNLOAD ERROR: $e');
        if (mounted) state = state.copyWith(isDownloading: false, error: e.toString());
      }
    }
  }

  /// Alohida sahifani darhol ustuvor yuklash
  Future<void> priorityDownloadPage(MushafType type, int pageNumber) async {
    final p = pageNumber.toString().padLeft(3, '0');
    final String url = type == MushafType.standard
        ? 'https://cdn.jsdelivr.net/gh/GovarJabbar/Quran-PNG@master/$p.png'
        : 'https://cdn.jsdelivr.net/gh/HiIAmMoot/quran-android-tajweed-page-provider@main/images/$p.png';
        
    try {
      final dir = await getApplicationDocumentsDirectory();
      final folderName = type == MushafType.standard ? 'mushaf_pages' : 'tajweed_pages';
      final targetDir = Directory('${dir.path}/$folderName');
      if (!targetDir.existsSync()) targetDir.createSync(recursive: true);
      
      final filePath = '${targetDir.path}/page$p.png';
      final file = File(filePath);
      
      if (!file.existsSync() || file.lengthSync() < 1000) {
        debugPrint('MUSHAF: PRIORITY yuklanyapti -> $p.png');
        final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 15)));
        await dio.download(url, filePath);
        debugPrint('MUSHAF: PRIORITY yuklandi -> $p.png');
      }
    } catch (e) {
      debugPrint('MUSHAF: Priority yuklashda xatolik ($p.png): $e');
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel();
    _isZipDownloading = false;
    state = state.copyWith(isDownloading: false);
  }
}

// Background isolate Function (Xotirjam unzip qilish uchun)
void _extractZip(Map<String, String> data) {
  final zipPath = data['zipPath']!;
  final targetPath = data['targetPath']!;
  
  final bytes = File(zipPath).readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);
  
  for (final file in archive) {
    final filename = file.name;
    if (file.isFile && filename.toLowerCase().endsWith('.png')) {
      final safeName = filename.split('/').last; // "Quran-PNG-master/001.png" -> "001.png"
      
      // FAQAT 3 xonali raqamli fayllarni olamiz (001.png => uzunligi 7)
      if (safeName.length == 7 || safeName.length == 6) { 
        // 6 misol uchun 1.png kelsa, garchi tajweed zero-padded bo'lsa ham.
        // Asosan biz 001.png standartini kutganmiz shuning uchun page$safeName deymiz.
        final p = safeName.replaceAll('.png', '').padLeft(3, '0');
        final outPath = '$targetPath/page$p.png';
        
        final data = file.content as List<int>;
        File(outPath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    }
  }
}
