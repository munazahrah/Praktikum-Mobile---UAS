class UserModel {
  final String userId;
  final String username;
  final String email;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
  });

  // Method untuk serialisasi ke JSON (untuk SharedPreferences)
  Map<String, dynamic> toJson() {
    return {'userId': userId, 'username': username, 'email': email};
  }

  // Factory untuk deserialisasi dari JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
    );
  }
}
