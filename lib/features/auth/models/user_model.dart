class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final int totalXP;
  final int currentStreak;
  final int longestStreak;
  final DateTime? createdAt;
  final DateTime? lastActive;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.totalXP = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.createdAt,
    this.lastActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoURL: json['photoURL'],
      totalXP: json['totalXP'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as dynamic).toDate != null 
              ? (json['createdAt'] as dynamic).toDate()
              : null
          : null,
      lastActive: json['lastActive'] != null
          ? (json['lastActive'] as dynamic).toDate != null
              ? (json['lastActive'] as dynamic).toDate()
              : null
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'totalXP': totalXP,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'createdAt': createdAt,
      'lastActive': lastActive,
    };
  }
}
