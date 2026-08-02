import '../data/models/profile_response.dart';

abstract class ProfileRepository {
  Future<ProfileResponse> getProfile({required String accessToken});

  Future<ProfileResponse> updateProfile({
    required String accessToken,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String avatar,
  });
}
