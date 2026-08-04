import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter/widgets.dart';
import 'quran_download_service.dart';

class QuranAudioService extends ChangeNotifier with WidgetsBindingObserver {
  static final QuranAudioService _instance = QuranAudioService._internal();
  factory QuranAudioService() => _instance;

  final AudioPlayer _player = AudioPlayer();
  final QuranDownloadService _downloadService = QuranDownloadService();

  String? _currentId;
  bool _isPlaying = false;

  AudioPlayer get player => _player;
  bool get isPlaying => _isPlaying;
  String? get currentId => _currentId;

  QuranAudioService._internal() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _player.pause();
    }
  }

  Future<void> playSurah(int surahNum, String name) async {
    final id = 'surah_$surahNum';
    _currentId = id;

    final isDownloaded = _downloadService.isDownloaded(id, DownloadType.audio);
    late AudioSource source;

    if (isDownloaded) {
      final path = await _downloadService.getFilePath(id, DownloadType.audio);
      source = AudioSource.uri(
        Uri.file(path),
        tag: MediaItem(
          id: id,
          album: 'Quran',
          title: 'Surah $name',
          artist: 'Abdul Basit',
        ),
      );
    } else {
      final surahStr = surahNum.toString().padLeft(3, '0');
      final url = 'https://server7.mp3quran.net/basit/$surahStr.mp3';
      source = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: id,
          album: 'Quran',
          title: 'Surah $name',
          artist: 'Abdul Basit',
        ),
      );
    }

    try {
      await _player.setAudioSource(source);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing surah: $e');
    }
  }

  Future<void> playJuzz(
    int juzNum,
    String name,
    List<int> surahsInRange,
  ) async {
    final id = 'juz_$juzNum';
    _currentId = id;

    final playlist = ConcatenatingAudioSource(children: []);

    for (var surahNum in surahsInRange) {
      final surahId = 'surah_$surahNum';
      final isDownloaded = _downloadService.isDownloaded(
        surahId,
        DownloadType.audio,
      );

      if (isDownloaded) {
        final path = await _downloadService.getFilePath(
          surahId,
          DownloadType.audio,
        );
        playlist.add(
          AudioSource.uri(
            Uri.file(path),
            tag: MediaItem(
              id: '$id-$surahNum',
              album: 'Juz $juzNum',
              title: 'Surah $surahNum',
              artist: 'Abdul Basit',
            ),
          ),
        );
      } else {
        final surahStr = surahNum.toString().padLeft(3, '0');
        playlist.add(
          AudioSource.uri(
            Uri.parse('https://server7.mp3quran.net/basit/$surahStr.mp3'),
            tag: MediaItem(
              id: '$id-$surahNum',
              album: 'Juz $juzNum',
              title: 'Surah $surahNum',
              artist: 'Abdul Basit',
            ),
          ),
        );
      }
    }

    try {
      await _player.setAudioSource(playlist);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing juz: $e');
    }
  }

  Future<void> playAyah(int surahNum, int ayahNum) async {
    final surahStr = surahNum.toString().padLeft(3, '0');
    final ayahStr = ayahNum.toString().padLeft(3, '0');
    final url =
        'https://www.everyayah.com/data/Abdul_Basit_Murattal_192kbps/$surahStr$ayahStr.mp3';

    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing ayah: $e');
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _currentId = null;
    notifyListeners();
  }

  Future<void> togglePause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
    super.dispose();
  }
}
