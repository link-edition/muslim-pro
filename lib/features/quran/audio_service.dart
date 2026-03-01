import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
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
    _player.playerStateStream.listen((pState) {
      if (!mounted) return;
      state = state.copyWith(
        isPlaying: pState.playing,
        isLoading: pState.processingState == ProcessingState.loading || pState.processingState == ProcessingState.buffering, 
      );
      if (pState.processingState == ProcessingState.completed) {
        state = state.copyWith(isPlaying: false);
      }
    });

    _player.currentIndexStream.listen((index) {
      if (!mounted) return;
      if (index != null && index < _player.sequence.length) {
         final mediaItem = _player.sequence[index].tag as MediaItem;
         final ayahIndex = mediaItem.extras?['ayahIndex'] as int? ?? index;
         if (ayahIndex != state.currentAyahIndex) {
            state = state.copyWith(currentAyahIndex: ayahIndex);
         }
      }
    });

    _player.positionStream.listen((pos) {
      if (!mounted) return;
      state = state.copyWith(position: pos);
    });

    _player.durationStream.listen((dur) {
      if (!mounted) return;
      if (dur != null) {
        state = state.copyWith(duration: dur);
      }
    });

    _player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace stackTrace) {
      dev.log('AudioPlayer Log Error: $e');
    });
  }

  Future<void> _updatePlaylist(int startIndex) async {
    final audioSources = <AudioSource>[];
    final repeats = (state.repeatMode == -1) ? 0 : state.repeatMode; 

    for (int i = 0; i < state.ayahs.length; i++) {
        final ayah = state.ayahs[i];
        final uri = (ayah.localPath != null && File(ayah.localPath!).existsSync()) 
             ? Uri.file(ayah.localPath!) 
             : Uri.parse(ayah.audioUrl!);
        
        final count = (state.repeatMode == -1) ? 1 : (repeats + 1);
        for(int c=0; c < count; c++) {
            final mediaItem = MediaItem(
              id: '${state.currentSurahNumber}_${i}_$c',
              album: 'Qur\'on - Amal',
              title: '${state.currentSurahName} — Oyat ${i + 1}',
              artist: 'Mishary Rashid Alafasy',
              extras: {'ayahIndex': i},
            );
            audioSources.add(AudioSource.uri(uri, tag: mediaItem));
        }
    }
    
    final playlist = ConcatenatingAudioSource(children: audioSources);
    final actualStartIndex = (state.repeatMode == -1) ? startIndex : (startIndex * (repeats + 1));
    
    await _player.setAudioSource(playlist, initialIndex: actualStartIndex, initialPosition: Duration.zero);
    
    if (state.repeatMode == -1) {
       await _player.setLoopMode(LoopMode.one);
    } else {
       await _player.setLoopMode(LoopMode.off);
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
      currentAyahIndex: startAyah,
    );
    
    // Priority downloadga qo'yamiz
    _ref.read(AudioDownloadManager.provider).setPrioritySurah(surahNumber);

    await _updatePlaylist(startAyah);
    if (autoPlay) {
      _player.play();
    }
  }

  Future<void> playAyah(int index, {bool forcePlay = true}) async {
    if (index < 0 || index >= state.ayahs.length) return;
    
    final repeats = (state.repeatMode == -1) ? 0 : state.repeatMode; 
    final actualIndex = (state.repeatMode == -1) ? index : (index * (repeats + 1));

    try {
        await _player.seek(Duration.zero, index: actualIndex);
        if (forcePlay) {
            _player.play();
        }
    } catch(e) {
        dev.log('playAyah Error: $e');
    }
  }

  Future<void> cycleSpeed() async {
    double nextSpeed = 1.0;
    if (state.playbackSpeed == 1.0) {
      nextSpeed = 1.5;
    } else if (state.playbackSpeed == 1.5) nextSpeed = 2.0;
    else if (state.playbackSpeed == 2.0) nextSpeed = 0.5;
    else nextSpeed = 1.0;

    state = state.copyWith(playbackSpeed: nextSpeed);
    await _player.setSpeed(nextSpeed);
  }

  Future<void> cycleRepeatMode() async {
    int nextMode = 0;
    if (state.repeatMode == 0) {
      nextMode = 1;
    } else if (state.repeatMode == 1) nextMode = 5;
    else if (state.repeatMode == 5) nextMode = -1;
    else nextMode = 0;

    state = state.copyWith(repeatMode: nextMode, currentRepeatCount: 0);
    
    final currentAyah = state.currentAyahIndex ?? 0;
    final wasPlaying = _player.playing;
    
    await _updatePlaylist(currentAyah);
    if (wasPlaying) {
        _player.play();
    }
  }

  Future<void> togglePlayPause() async {
    try {
      if (state.isPlaying) {
        await _player.pause();
      } else {
        if (state.currentAyahIndex == null && state.ayahs.isNotEmpty) {
          await playAyah(0);
        } else {
          _player.play();
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
      await playAyah(current + 1);
    }
  }

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

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  return AudioPlayerNotifier(ref);
});
