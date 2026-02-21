import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'data/quran_model.dart';

/// Audio pleyer holati
class AudioPlayerState {
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final int? currentSurahNumber;
  final String? currentSurahName;
  final int? currentAyahIndex;
  final List<AyahModel> ayahs;
  final String? error;

  const AudioPlayerState({
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentSurahNumber,
    this.currentSurahName,
    this.currentAyahIndex,
    this.ayahs = const [],
    this.error,
  });

  /// Progress (0.0 — 1.0)
  double get progress =>
      duration.inMilliseconds > 0
          ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
          : 0.0;

  /// Hozir ijro etilmoqda
  bool get hasAudio => currentSurahNumber != null;

  AudioPlayerState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    int? currentSurahNumber,
    String? currentSurahName,
    int? currentAyahIndex,
    List<AyahModel>? ayahs,
    String? error,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentSurahNumber: currentSurahNumber ?? this.currentSurahNumber,
      currentSurahName: currentSurahName ?? this.currentSurahName,
      currentAyahIndex: currentAyahIndex ?? this.currentAyahIndex,
      ayahs: ayahs ?? this.ayahs,
      error: error,
    );
  }
}

/// Audio pleyer boshqaruvchisi
class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayerNotifier() : super(const AudioPlayerState()) {
    _setupListeners();
  }

  /// Pleyer hodisalarini tinglash
  void _setupListeners() {
    // Ijro holati
    _player.playerStateStream.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState.playing,
        isLoading: playerState.processingState == ProcessingState.loading ||
            playerState.processingState == ProcessingState.buffering,
      );

      // Audio tugadi
      if (playerState.processingState == ProcessingState.completed) {
        _onAudioCompleted();
      }
    });

    // Pozitsiya yangilanishi
    _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    // Umumiy davomiyligi
    _player.durationStream.listen((dur) {
      if (dur != null) {
        state = state.copyWith(duration: dur);
      }
    });
  }

  /// Audio tugaganda — keyingi oyatga o'tish
  void _onAudioCompleted() {
    final currentIndex = state.currentAyahIndex;
    if (currentIndex != null && currentIndex < state.ayahs.length - 1) {
      playAyah(currentIndex + 1);
    } else {
      // Sura tugadi
      state = state.copyWith(isPlaying: false, currentAyahIndex: null);
    }
  }

  /// Surani ijro etish (birinchi oyatdan boshlash)
  Future<void> playSurah({
    required int surahNumber,
    required String surahName,
    required List<AyahModel> ayahs,
    int startAyah = 0,
  }) async {
    state = state.copyWith(
      currentSurahNumber: surahNumber,
      currentSurahName: surahName,
      ayahs: ayahs,
      error: null,
    );

    await playAyah(startAyah);
  }

  /// Ma'lum bir oyatni ijro etish
  Future<void> playAyah(int index) async {
    if (index < 0 || index >= state.ayahs.length) return;

    final ayah = state.ayahs[index];
    final audioUrl = ayah.audioUrl;

    if (audioUrl == null || audioUrl.isEmpty) {
      state = state.copyWith(error: 'Audio mavjud emas');
      return;
    }

    state = state.copyWith(
      currentAyahIndex: index,
      isLoading: true,
      error: null,
    );

    try {
      await _player.setUrl(audioUrl);
      await _player.play();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Audio yuklashda xatolik',
      );
    }
  }

  /// Ijroni to'xtatish / davom ettirish
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  /// To'xtatish
  Future<void> pause() async {
    await _player.pause();
  }

  /// To'liq to'xtatish
  Future<void> stop() async {
    await _player.stop();
    state = const AudioPlayerState();
  }

  /// Pozitsiyaga o'tish
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  /// Keyingi oyat
  Future<void> nextAyah() async {
    final current = state.currentAyahIndex;
    if (current != null && current < state.ayahs.length - 1) {
      await playAyah(current + 1);
    }
  }

  /// Oldingi oyat
  Future<void> previousAyah() async {
    final current = state.currentAyahIndex;
    if (current != null && current > 0) {
      await playAyah(current - 1);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

/// Global audio provider
final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  return AudioPlayerNotifier();
});
