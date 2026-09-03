// lib/core/services/audio/web_audio_tag.dart
// Stub MediaItem for web — just_audio_background is not supported on web.
// This file is imported conditionally when dart.library.html is available.

class MediaItem {
  final String id;
  final String? album;
  final String? title;
  final String? artist;
  const MediaItem({required this.id, this.album, this.title, this.artist});
}
