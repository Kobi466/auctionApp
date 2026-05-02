import '../entities/winner_entity.dart';
import '../repositories/winner_repository.dart';

class GetWinnersUseCase {
  final WinnerRepository _repository;

  GetWinnersUseCase(this._repository);

  Future<List<WinnerEntity>> execute({
    required String accessToken,
    String? query,
    WinnerStatus? status,
  }) {
    return _repository.getWinners(
      accessToken: accessToken,
      query: query,
      status: status,
    );
  }
}
