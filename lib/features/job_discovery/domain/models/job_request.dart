class JobRequest {
  final String id;
  final String subject;
  final String gradeLevel;
  final String city;
  final String location;
  final String preferredGender;
  final String tuitionType;
  final String feeRange;
  final DateTime postedAt;
  final bool isNew;

  const JobRequest({
    required this.id,
    required this.subject,
    required this.gradeLevel,
    required this.city,
    required this.location,
    required this.preferredGender,
    required this.tuitionType,
    required this.feeRange,
    required this.postedAt,
    this.isNew = false,
  });

  String get timeAgo {
    final difference = DateTime.now().difference(postedAt);
    if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
