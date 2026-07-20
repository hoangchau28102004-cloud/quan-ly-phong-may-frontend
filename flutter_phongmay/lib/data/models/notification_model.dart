class NotificationModel {
  final int id;
  final int? userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw =
        json['created_at']?.toString() ?? json['ngay_tao']?.toString() ?? '';
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(createdAtRaw);
    } catch (_) {
      createdAt = DateTime.now();
    }

    final daDoc = json['da_doc'];
    final isRead = daDoc == true || daDoc == 1 || daDoc == '1';

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return NotificationModel(
      id: parseInt(json['id']),
      userId: json.containsKey('ma_nguoi_dung')
          ? parseInt(json['ma_nguoi_dung'])
          : null,
      title: json['tieu_de']?.toString() ?? json['title']?.toString() ?? '',
      message:
          json['noi_dung']?.toString() ?? json['message']?.toString() ?? '',
      type:
          json['loai_thong_bao']?.toString() ??
          json['type']?.toString() ??
          'system',
      isRead: isRead,
      createdAt: createdAt,
    );
  }

  NotificationModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
