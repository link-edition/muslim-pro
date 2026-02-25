import 'dart:async';
import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/quran_api_service.dart';
import 'data/quran_model.dart';
import 'data/quran_db_service.dart';
import 'dart:developer' as dev;

class AudioDownloadManager {
  final _queue = DoubleLinkedQueue<int>();
  bool _isDownloading = false;
  int? _prioritySurah;

  static final provider = Provider((ref) => AudioDownloadManager());

  void startBackgroundDownload() async {
    if (_isDownloading) return;
    
    // Barcha suralarni navbatga qo'shamiz (1-114)
    for (int i = 1; i <= 114; i++) {
      _queue.add(i);
    }
    
    _processQueue();
  }

  void setPrioritySurah(int surahNumber) {
    _prioritySurah = surahNumber;
    dev.log('DownloadManager: Priority set to $surahNumber');
  }

  Future<void> _processQueue() async {
    _isDownloading = true;
    
    while (_queue.isNotEmpty || _prioritySurah != null) {
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
  }

  Future<void> _downloadSurah(int surahNumber) async {
    dev.log('DownloadManager: Downloading Surah $surahNumber');
    
    try {
      final ayahs = await QuranApiService.getAyahs(surahNumber);
      for (var ayah in ayahs) {
        // Agar priority o'zgarsa, darhol to'xtatib o'sha suraga o'tamiz
        if (_prioritySurah != null && _prioritySurah != surahNumber) {
          _queue.addFirst(surahNumber); // Qolib ketganini boshiga qaytaramiz
          return;
        }

        if (ayah.localPath == null) {
          await QuranApiService.downloadAyahAudio(ayah);
        }
      }
      dev.log('DownloadManager: Finished Surah $surahNumber');
    } catch (e) {
      dev.log('DownloadManager Error for Surah $surahNumber: $e');
    }
  }
}
