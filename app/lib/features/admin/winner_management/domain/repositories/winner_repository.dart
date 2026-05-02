import '../entities/winner_entity.dart';

abstract class WinnerRepository {
  Future<List<WinnerEntity>> getWinners({
    required String accessToken,
    String? query,
    WinnerStatus? status,
  });
}
