class LogEntry {
  String id;
  String title;
  bool done;

  LogEntry({required this.id, required this.title, this.done = false});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'done': done};
  factory LogEntry.fromJson(Map<String, dynamic> json) =>
      LogEntry(id: json['id'], title: json['title'], done: json['done']);
}
