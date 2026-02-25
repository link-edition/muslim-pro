import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'data/quran_model.dart';
import 'download_manager.dart';
import 'dart:developer' as dev;

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
  final double playbackSpeed;
  final int repeatMode; 
  final int currentRepeatCount;

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
    this.playbackSpeed = 1.0,
    this.repeatMode = 0,
    this.currentRepeatCount = 0,
  });

  double get progress =>
      duration.inMilliseconds > 0
          ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
          : 0.0;

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
    double? playbackSpeed,
    int? repeatMode,
    int? currentRepeatCount,
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
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      repeatMode: repeatMode ?? this.repeatMode,
      currentRepeatCount: currentRepeatCount ?? this.currentRepeatCount,
    );
  }
}

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final Ref _ref;
  late final AudioPlayer _player;

  AudioPlayerNotifier(this._ref) : super(const AudioPlayerState()) {
    _player = AudioPlayer();
    _setupListeners();
  }

  void _setupListeners() {
    _player.playerStateStream.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState.playing,
        isLoading: playerState.processingState == ProcessingState.loading ||
            playerState.processingState == ProcessingState.buffering,
      );

      if (playerState.processingState == ProcessingState.completed) {
        _onAudioCompleted();
      }
    });

    _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    _player.durationStream.listen((dur) {
      if (dur != null) {
        state = state.copyWith(duration: dur);
      }
    });

    _player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace st) {
      dev.log('AudioPlayer Playback Error: $e');
      state = state.copyWith(error: 'Audio ijrosida xatolik yuz berdi');
    });
  }

  void _onAudioCompleted() {
    final currentIndex = state.currentAyahIndex;
    if (currentIndex != null) {
      if (state.repeatMode == -1) {
        playAyah(currentIndex, forcePlay: true);
      } else if (state.repeatMode > 0 && state.currentRepeatCount < state.repeatMode) {
        state = state.copyWith(currentRepeatCount: state.currentRepeatCount + 1);
        playAyah(currentIndex, forcePlay: true);
      } else {
        state = state.copyWith(currentRepeatCount: 0);
        if (currentIndex < state.ayahs.length - 1) {
          playAyah(currentIndex + 1, forcePlay: true);
        } else {
          state = state.copyWith(isPlaying: false);
        }
      }
    }
  }

  Future<void> playSurah({
    required int surahNumber,
    required String surahName,
    required List<AyahModel> ayahs,
    int startAyah = 0,
    bool autoPlay = true,
  }) async {
    state = state.copyWith(
      currentSurahNumber: surahNumber,
      currentSurahName: surahName,
      ayahs: ayahs,
      error: null,
      currentRepeatCount: 0,
    );
    
    // Priority downloadga qo'yamiz
    _ref.read(AudioDownloadManager.provider).setPrioritySurah(surahNumber);

    if (autoPlay) {
      await playAyah(startAyah, forcePlay: true);
    } else {
      await playAyah(startAyah, forcePlay: false);
    }
  }

  Future<void> playAyah(int index, {bool forcePlay = true}) async {
    if (index < 0 || index >= state.ayahs.length) return;

    final ayah = state.ayahs[index];
    
    state = state.copyWith(
      currentAyahIndex: index,
      isLoading: true,
      error: null,
      position: Duration.zero,
      duration: Duration.zero,
    );

    try {
      AudioSource source;
      
      // Local fayl bormi?
      if (ayah.localPath != null && await File(ayah.localPath!).exists()) {
        dev.log('AudioPlayer: Playing LOCAL Ayah $index: ${ayah.localPath}');
        source = AudioSource.file(ayah.localPath!);
      } else {
        if (ayah.audioUrl == null) throw Exception("Audio URL yo'q");
        dev.log('AudioPlayer: Playing REMOTE Ayah $index: ${ayah.audioUrl}');
        source = AudioSource.uri(Uri.parse(ayah.audioUrl!));
      }

      await _player.setAudioSource(source);
      _player.setSpeed(state.playbackSpeed);
      if (forcePlay) _player.play();
    } catch (e) {
      dev.log('AudioPlayer Error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Audio yuklab bo\'lmadi.',
      );
    }
  }

  Future<void> cycleSpeed() async {
    double nextSpeed = 1.0;
    if (state.playbackSpeed == 1.0) nextSpeed = 1.5;
    else if (state.playbackSpeed == 1.5) nextSpeed = 0.5;
    else nextSpeed = 1.0;

    state = state.copyWith(playbackSpeed: nextSpeed);
    await _player.setSpeed(nextSpeed);
  }

  void cycleRepeatMode() {
    int nextMode = 0;
    if (state.repeatMode == 0) nextMode = 1;
    else if (state.repeatMode == 1) nextMode = 5;
    else if (state.repeatMode == 5) nextMode = -1;
    else nextMode = 0;

    state = state.copyWith(repeatMode: nextMode, currentRepeatCount: 0);
  }

  Future<void> togglePlayPause() async {
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        if (state.currentAyahIndex == null && state.ayahs.isNotEmpty) {
          await playAyah(0);
        } else {
          await _player.play();
        }
      }
    } catch (e) {
      dev.log('TogglePlayPause Error: $e');
    }
  }

  Future<void> stop() async {
    await _player.stop();
    state = const AudioPlayerState();
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  Future<void> nextAyah() async {
    final current = state.currentAyahIndex;
    if (current != null && current < state.ayahs.length - 1) {
      state = state.copyWith(currentRepeatCount: 0);
      await playAyah(current + 1);
    }
  }

  Future<void> previousAyah() async {
    final current = state.currentAyahIndex;
    if (current != null && current > 0) {
      state = state.copyWith(currentRepeatCount: 0);
      await playAyah(current - 1);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  return AudioPlayerNotifier(ref);
});
