import '../data/models/profile_response.dart';
import '../data/profile_service.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _service = ProfileService();

  @override
  Future<ProfileResponse> getProfile({required String accessToken}) {
    return _service.getProfile(accessToken: accessToken);
  }

  @override
  Future<ProfileResponse> updateProfile({
    required String accessToken,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String avatar,
  }) {
    return _service.updateProfile(
      accessToken: accessToken,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      avatar: avatar,
    );
  }
}
