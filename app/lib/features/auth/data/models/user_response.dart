import '../../../../core/models/base_model.dart';

class UserResponse extends BaseModel {
  final String id;
  final String email;
  final bool isActive;

  UserResponse({required this.id, required this.email, required this.isActive});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'isActive': isActive};
  }
}
