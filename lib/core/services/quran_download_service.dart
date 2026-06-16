import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

enum DownloadType { audio, pdf }

class DownloadProgress {
  final double progress;
  final bool isDownloading;
  final String? error;

  DownloadProgress({
    required this.progress,
    required this.isDownloading,
    this.error,
  });
}

class QuranDownloadService extends ChangeNotifier {
  static final QuranDownloadService _instance = QuranDownloadService._internal();
  factory QuranDownloadService() => _instance;
  QuranDownloadService._internal();

  final Dio _dio = Dio();
  final Map<String, DownloadProgress> _progressMap = {};
  SharedPreferences? _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  DownloadProgress? getProgress(String id, DownloadType type) {
    return _progressMap['${id}_${type.name}'];
  }

  bool isDownloaded(String id, DownloadType type) {
    return _prefs?.getBool('is_downloaded_${id}_${type.name}') ?? false;
  }

  Future<String> getFilePath(String id, DownloadType type) async {
    final directory = await getApplicationDocumentsDirectory();
    final extension = type == DownloadType.audio ? 'mp3' : 'pdf';
    final folder = type == DownloadType.audio ? 'audio' : 'pdf';
    final path = p.join(directory.path, 'quran', folder, '$id.$extension');
    
    // Create directory if it doesn't exist
    final file = File(path);
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    
    return path;
  }

  Future<void> download({
    required String id,
    required String url,
    required DownloadType type,
  }) async {
    if (!_initialized) await init();
    
    final key = '${id}_${type.name}';
    if (_progressMap[key]?.isDownloading == true) return;

    final savePath = await getFilePath(id, type);

    try {
      _progressMap[key] = DownloadProgress(progress: 0, isDownloading: true);
      notifyListeners();

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _progressMap[key] = DownloadProgress(
              progress: received / total,
              isDownloading: true,
            );
            notifyListeners();
          }
        },
      );

      _progressMap[key] = DownloadProgress(progress: 1.0, isDownloading: false);
      await _prefs!.setBool('is_downloaded_$key', true);
      notifyListeners();
    } catch (e) {
      _progressMap[key] = DownloadProgress(
        progress: 0,
        isDownloading: false,
        error: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> deleteFile(String id, DownloadType type) async {
    if (!_initialized) await init();
    final path = await getFilePath(id, type);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    final key = '${id}_${type.name}';
    await _prefs!.remove('is_downloaded_$key');
    _progressMap.remove(key);
    notifyListeners();
  }
}
