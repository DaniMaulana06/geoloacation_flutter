class Todo {
  final int id;
  final String title;
  final DateTime createdAt;
  final String? signatureUrl;
  final double? latitude;
  final double? longitude;

  Todo({
    required this.id,
    required this.title,
    required this.createdAt,
    this.signatureUrl,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
