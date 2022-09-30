import 'package:aimoov_spotify/core/errors/failure.dart';
import 'package:aimoov_spotify/data/models/device_model.dart';
import 'package:aimoov_spotify/data/models/track_model.dart';
import 'package:dartz/dartz.dart';

import '../entities/track.dart';

abstract class SpotifyRepo {
  Future<Either<Failure, List<TrackModel>>> searchTrack(String query,
      {required String token});
  Future<Either<Failure, Map<String, String>>> login();
  Future<Either<Failure, List<TrackModel>>> recentTracks(
      {required String token});
  Future<Either<Failure, String>> getAccessToken();
  Future<Either<Failure, List<DeviceModel>>> getDevices(
      {required String token});
  Future<Either<Failure, String>> getRefreshToken(String refreshToken);
  Future<Either<Failure, String>> playTrack(String deviceId, String trackUri,
      {required String token});
}
