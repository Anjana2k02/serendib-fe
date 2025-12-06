import '../core/constants/app_constants.dart';
import '../models/artifact.dart';
import 'api_service.dart';

class ArtifactService {
  final ApiService _apiService = ApiService();

  Future<ArtifactListResponse> getArtifacts({
    int page = 0,
    int size = 10,
    String sortBy = 'id',
    String sortDir = 'asc',
  }) async {
    final queryParameters = {
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'sortDir': sortDir,
    };

    final response = await _apiService.get(
      AppConstants.artifactsEndpoint,
      queryParameters: queryParameters,
    );

    return ArtifactListResponse.fromJson(response);
  }

  Future<Artifact> getArtifactById(int id) async {
    final response = await _apiService.get(
      '${AppConstants.artifactsEndpoint}/$id',
    );

    return Artifact.fromJson(response);
  }

  Future<Artifact> createArtifact(Artifact artifact) async {
    final response = await _apiService.post(
      AppConstants.artifactsEndpoint,
      artifact.toJson(),
    );

    return Artifact.fromJson(response);
  }

  Future<Artifact> updateArtifact(int id, Artifact artifact) async {
    final response = await _apiService.put(
      '${AppConstants.artifactsEndpoint}/$id',
      artifact.toJson(),
    );

    return Artifact.fromJson(response);
  }

  Future<void> deleteArtifact(int id) async {
    await _apiService.delete(
      '${AppConstants.artifactsEndpoint}/$id',
    );
  }

  Future<ArtifactListResponse> searchArtifacts(
    String searchTerm, {
    int page = 0,
    int size = 10,
  }) async {
    final queryParameters = {
      'searchTerm': searchTerm,
      'page': page.toString(),
      'size': size.toString(),
    };

    final response = await _apiService.get(
      '${AppConstants.artifactsEndpoint}/search',
      queryParameters: queryParameters,
    );

    return ArtifactListResponse.fromJson(response);
  }
}
