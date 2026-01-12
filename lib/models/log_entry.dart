class LogEntry {
  String id;
  String title;
  bool done;
  String category;
  int? color; // content color
  int? backgroundColor; // Added individual background color support

  LogEntry({
    required this.id,
    required this.title,
    this.done = false,
    this.category = '默认',
    this.color,
    this.backgroundColor,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': done,
        'category': category,
        'color': color,
        'backgroundColor': backgroundColor,
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
        id: json['id'],
        title: json['title'],
        done: json['done'],
        category: json['category'] ?? '默认',
        color: json['color'],
        backgroundColor: json['backgroundColor'],
      );
}
