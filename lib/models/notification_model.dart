class NotificationModel {
  final String id;
  final String image;
  final String title;
  final String content;
  final bool isSent;
  final DateTime? sentAt;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.image,
    required this.title,
    required this.content,
    required this.isSent,
    this.sentAt,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final content = json['content'] ?? '';
    print('🔍 NotificationModel.fromJson:');
    print('   Raw JSON: $json');
    print('   Parsed content: "$content"');

    final notification = NotificationModel(
      id: json['id'] ?? '',
      image: json['image'] ?? '',
      title: json['title'] ?? '',
      content: content,
      isSent: json['isSent'] ?? false,
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );

    print('   DisplayText: "${notification.displayText}"');
    return notification;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'title': title,
      'content': content,
      'isSent': isSent,
      'sentAt': sentAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  // Helper method to get the display text
  String get displayText {
    if (content.isNotEmpty && content != 'null') {
      return content;
    } else {
      return '';
    }
  }

  // Helper method to get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Helper method to get full image URL
  String get fullImageUrl {
    // If image is already a full URL, return as is
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }

    // If it's a Cloudinary URL path, construct the full URL
    if (image.contains('cloudinary')) {
      return image;
    }

    // For local development or relative paths, construct the full URL
    // You may need to adjust this based on your backend setup
    const baseUrl = 'http://10.0.2.2:3000'; // Adjust for your backend URL

    // Remove leading slash if present to avoid double slashes
    final cleanPath = image.startsWith('/') ? image.substring(1) : image;
    return '$baseUrl/$cleanPath';
  }
}
