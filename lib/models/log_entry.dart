class LogEntry {
  final String id;
  final String title;
  final bool done;
  final String category;
  final int? color;
  final int? backgroundColor;
  final DateTime createdAt;

  LogEntry({
    required this.id,
    required this.title,
    this.done = false,
    this.category = '默认',
    this.color,
    this.backgroundColor,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  LogEntry copyWith({
    String? title,
    bool? done,
    String? category,
    int? color,
    int? backgroundColor,
    DateTime? createdAt,
  }) {
    return LogEntry(
      id: id,
      title: title ?? this.title,
      done: done ?? this.done,
      category: category ?? this.category,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': done,
        'category': category,
        'color': color,
        'backgroundColor': backgroundColor,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
        id: json['id'],
        title: json['title'],
        done: json['done'] ?? false,
        category: json['category'] ?? '默认',
        color: json['color'],
        backgroundColor: json['backgroundColor'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
      );
}
