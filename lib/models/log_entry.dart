class LogEntry {
  final String id;
  final String title;
  final bool done;
  final String category;
  final int? color;
  final int? backgroundColor;

  LogEntry({
    required this.id,
    required this.title,
    this.done = false,
    this.category = '默认',
    this.color,
    this.backgroundColor,
  });

  LogEntry copyWith({
    String? title,
    bool? done,
    String? category,
    int? color,
    int? backgroundColor,
  }) {
    return LogEntry(
      id: id,
      title: title ?? this.title,
      done: done ?? this.done,
      category: category ?? this.category,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'done': done,
      'category': category,
      'color': color,
      'backgroundColor': backgroundColor,
    };
  }

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'],
      title: json['title'],
      done: json['done'] ?? false,
      category: json['category'] ?? '默认',
      color: json['color'],
      backgroundColor: json['backgroundColor'],
    );
  }
}
