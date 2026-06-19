
String normalizeDate(String input) {
  final parts = input.split('-');
  if (parts.length != 3) return input;

  return '${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}';
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String
  type; // 'summary', 'reminder', 'budget', 'weekly', 'monthly', 'achievement'
  final Map<String, String>? metadata;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.metadata,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    Map<String, String>? metadata,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'type': type,
    'metadata': metadata,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final dateString = json['timestamp'] as String? ?? '';
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(normalizeDate(dateString));
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return NotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      timestamp: parsedDate,
      isRead: json['isRead'] as bool? ?? false,
      type: json['type'] as String? ?? '',
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
    );
  }
}
