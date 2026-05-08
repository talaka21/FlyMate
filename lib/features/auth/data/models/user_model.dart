class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String token;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.token,
  });

  /// Restores user from local secure storage (flat format saved by toJson)
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    fullName: json['full_name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    token: json['token'] as String? ?? '',
  );

  /// Parses the Laravel login/register API response:
  /// { "status": "Success", "data": { "token": "...", "user": { "id": 1, "name": "...", ... } } }
  factory UserModel.fromApiResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Invalid API response: missing "data" field');
    }
    final user = data['user'] as Map<String, dynamic>?;
    if (user == null) {
      throw Exception('Invalid API response: missing "user" field');
    }
    final token = (data['token'] ?? data['access_token'])?.toString() ?? '';
    return UserModel(
      id: user['id']?.toString() ?? '',
      fullName: user['name'] as String? ?? '',
      email: user['email'] as String? ?? '',
      token: token,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
    'token': token,
  };
}
