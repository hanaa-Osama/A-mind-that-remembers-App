class Memory {
  final String id;
  final String title;
  final DateTime createdAt;
  final bool isJournal;
  final bool isFavorite;
  final List<MemoryPageData> pages;

  Memory({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isJournal = false,
    this.isFavorite = false,
    this.pages = const [],
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isJournal: json['isJournal'] == true,
      isFavorite: json['isFavorite'] == true,
      pages: (json['pages'] as List?)?.map((p) => MemoryPageData.fromJson(p)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'isJournal': isJournal,
    'isFavorite': isFavorite,
    'pages': pages.map((p) => p.toJson()).toList(),
  };
}

class MemoryPageData {
  final String text;
  final String? image;
  final String? video;

  MemoryPageData({required this.text, this.image, this.video});

  factory MemoryPageData.fromJson(Map<String, dynamic> json) => MemoryPageData(
    text: json['text']?.toString() ?? '',
    image: json['image'],
    video: json['video'],
  );

  Map<String, dynamic> toJson() => {'text': text, 'image': image, 'video': video};
}
