import 'package:aimoov_spotify/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

abstract class BaseApiService {
  final String _baseUrl = "https://jsonplaceholder.typicode.com/";

  Future<Either<Failure, T>> getResponse<T>(String url);
  Future<dynamic> postResponse(
      String url, Map<String, dynamic> body, Map<String, String>? headers);
  Future<dynamic> putResponse(
      String url, Map<String, dynamic> body, Map<String, String>? headers);
  Future<dynamic> deleteResponse(
      {required String url,
      Map<String, String>? headers,
      bool showToast = true});
}
