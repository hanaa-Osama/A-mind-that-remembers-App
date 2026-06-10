enum MediaType { image, video }

class MediaItem {
  final String id;
  final String path;
  final MediaType type;
  final String? memoryId;
  final String? memoryTitle;
  final DateTime createdAt;
  final bool isStandalone;
  final String? standaloneId;

  MediaItem({
    required this.id,
    required this.path,
    required this.type,
    this.memoryId,
    this.memoryTitle,
    required this.createdAt,
    this.isStandalone = false,
    this.standaloneId,
  });
}
