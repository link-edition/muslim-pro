import 'dart:async';
import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/quran_api_service.dart';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

class AudioDownloadManager extends ChangeNotifier {
  final _queue = DoubleLinkedQueue<int>();
  bool _isDownloading = false;
  bool _isPaused = false;
  int? _prioritySurah;

  int _downloadedCount = 0;
  String _currentDownloadingSurahName = '';
  double _currentSurahProgress = 0.0; // 0 to 1

  int get downloadedCount => _downloadedCount;
  String get currentDownloadingSurahName => _currentDownloadingSurahName;
  double get currentSurahProgress => _currentSurahProgress;
  bool get isDownloading => _isDownloading;
  bool get isPaused => _isPaused;

  static final provider = ChangeNotifierProvider((ref) => AudioDownloadManager());

  void pause() {
    _isPaused = true;
    notifyListeners();
  }

  void resume() {
    _isPaused = false;
    if (!_isDownloading) {
      _processQueue();
    } else {
      notifyListeners();
    }
  }

  void startBackgroundDownload() async {
    if (_isDownloading) return;
    
    // Barcha suralarni navbatga qo'shamiz (1-114)
    for (int i = 1; i <= 114; i++) {
      _queue.add(i);
    }
    
    // Check initial downloaded count (optional, but good for accuracy)
    _downloadedCount = 0; // Or fetch from DB if caching is implemented fully
    
    _isPaused = false;
    _processQueue();
  }

  void setPrioritySurah(int surahNumber) {
    _prioritySurah = surahNumber;
    dev.log('DownloadManager: Priority set to $surahNumber');
  }

  Future<void> _processQueue() async {
    if (_isDownloading) return;
    _isDownloading = true;
    notifyListeners();
    
    while ((_queue.isNotEmpty || _prioritySurah != null) && !_isPaused) {
      int nextSurah;
      
      if (_prioritySurah != null) {
        nextSurah = _prioritySurah!;
        _prioritySurah = null;
        _queue.remove(nextSurah);
      } else {
        nextSurah = _queue.removeFirst();
      }

      await _downloadSurah(nextSurah);
    }
    
    _isDownloading = false;
    notifyListeners();
  }

  Future<void> _downloadSurah(int surahNumber) async {
    dev.log('DownloadManager: Downloading Surah $surahNumber');
    
    try {
      final surahs = await QuranApiService.getSurahs();
      final surah = surahs.firstWhere((s) => s.number == surahNumber);
      
      _currentDownloadingSurahName = surah.englishName;
      _currentSurahProgress = 0.0;
      notifyListeners();

      final ayahs = await QuranApiService.getAyahs(surahNumber);
      int downloadedAyahs = 0;

      for (var ayah in ayahs) {
        if (_isPaused) {
          _queue.addFirst(surahNumber);
          dev.log('DownloadManager: Paused at Surah $surahNumber');
          return;
        }

        // Agar priority o'zgarsa, darhol to'xtatib o'sha suraga o'tamiz
        if (_prioritySurah != null && _prioritySurah != surahNumber) {
          _queue.addFirst(surahNumber); // Qolib ketganini boshiga qaytaramiz
          return;
        }

        if (ayah.localPath == null) {
          await QuranApiService.downloadAyahAudio(ayah);
        }
        
        downloadedAyahs++;
        _currentSurahProgress = (downloadedAyahs / ayahs.length).clamp(0.0, 1.0);
        notifyListeners();
      }
      dev.log('DownloadManager: Finished Surah $surahNumber');
      _downloadedCount++;
      notifyListeners();
    } catch (e) {
      dev.log('DownloadManager Error for Surah $surahNumber: $e');
    }
  }
}
