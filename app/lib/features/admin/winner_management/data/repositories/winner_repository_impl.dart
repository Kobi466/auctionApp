import '../../domain/entities/winner_entity.dart';
import '../../domain/repositories/winner_repository.dart';
import '../services/admin_winner_service.dart';

class WinnerRepositoryImpl implements WinnerRepository {
  final AdminWinnerService _service;

  WinnerRepositoryImpl(this._service);

  @override
  Future<List<WinnerEntity>> getWinners({
    required String accessToken,
    String? query,
    WinnerStatus? status,
  }) async {
    String? statusStr;
    if (status != null) {
      statusStr = status.name;
    }

    final models = await _service.getWinners(
      accessToken: accessToken,
      query: query,
      status: statusStr,
    );

    return models;
  }
}
