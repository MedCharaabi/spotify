import 'dart:convert';
import 'dart:developer';

import 'package:aimoov_spotify/constants/constants.dart';
import 'package:aimoov_spotify/core/errors/failure.dart';
import 'package:aimoov_spotify/data/models/device_model.dart';
import 'package:aimoov_spotify/data/models/track_model.dart';
import 'package:aimoov_spotify/domain/repository/spotify_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SpotifyRepoImpl extends SpotifyRepo {
  @override
  Future<Either<Failure, String>> getRefreshToken(String refreshToken) async {
    final response = await http
        .get(Uri.parse("$refreshTokenUrl?refresh_token=$refreshToken"));

    log("refresh token response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Right(data["access_token"]);
    } else {
      return left(ServerFailure(message: response.body));
    }
  }

  @override
  Future<Either<Failure, List<TrackModel>>> searchTrack(String query,
      {String? token}) async {
    final pref = await SharedPreferences.getInstance();
    final String? accessToken = pref.getString('spotifyToken');

    var response = await http.get(
        Uri.parse(
          "https://api.spotify.com/v1/search?q=$query&type=track&limit=10&offset=0",
        ),
        headers: {
          "Authorization": "Bearer ${token ?? accessToken}",
          "Accept": "application/json",
          "Content-Type": "application/json"
        });

    var jsonResponse = json.decode(response.body);

    log("result ${response.statusCode} ");
    if (response.statusCode == 200) {
      final tracks = jsonResponse['tracks']['items'];
      List<TrackModel> trackList = [];

      for (var track in tracks) {
        trackList.add(TrackModel.fromJson(track));
      }

      return Right(trackList);
    }

    if (response.statusCode == 401) {
      log("token expired");
      final newAccessToken = await getRefreshToken(refreshToken);
      newAccessToken.fold(
          (l) => log("error: ${l}"), (r) => log("new token: $r"));
      if (newAccessToken.isRight()) {
        final newToken = newAccessToken.getOrElse(() => "");
        pref.setString('spotifyToken', newToken);
        return searchTrack(query, token: newToken);
      }
    }
    debugPrint("error: ${response.body}");
    return Left(ServerFailure(message: response.body));
  }

  @override
  Future<Either<Failure, String>> getAccessToken() async {
    final response = await http.get(Uri.parse(acessTokenUrl));

    if (response.statusCode == 200) {
      return right(response.body);
    } else {
      return left(ServerFailure(message: response.body));
    }
  }

  @override
  Future<Either<Failure, String>> playTrack(String? deviceId, String trackUri,
      {required String token}) async {
    try {
      var response = await http.put(
          Uri.parse(
            "https://api.spotify.com/v1/me/player/play",
          ),
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            "context_uri": [trackUri]
          }));

      var jsonResponse = json.decode(response.body);

      log("result ${response.statusCode} ");
      if (response.statusCode == 200) {
        return Right(jsonResponse['device']['id']);
      }

      if (response.statusCode == 401) {
        final newAccessToken = await getRefreshToken(refreshToken);
        log("new Acess token:  $newAccessToken");
        newAccessToken.fold(
            (l) => log("error: ${l}"), (r) => log("new token: $r"));
        if (newAccessToken.isRight()) {
          final newToken = newAccessToken.getOrElse(() => "");
          return playTrack(deviceId, trackUri, token: newToken);
        }
      }

      return left(ServerFailure(message: jsonResponse["error"]["message"]));
    } catch (e) {
      Map error = jsonDecode("e");

      log("error: $e");
      return left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> login() async {
    final response = await http.get(Uri.parse(loginUrl));

    log("refresh token response: ${response.body}");

    if (response.statusCode == 200) {
      return right(jsonDecode(response.body));
    } else {
      return left(ServerFailure(message: response.body));
    }
  }

  @override
  Future<Either<Failure, List<TrackModel>>> recentTracks(
      {required String token}) async {
    var response = await http.get(
        Uri.parse(
          "https://api.spotify.com/v1/me/player/recently-played?limit=9",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json"
        });

    debugPrint("response: ${response.body}");

    var jsonResponse = json.decode(response.body);

    log("result ${response.statusCode} ");
    if (response.statusCode == 200) {
      final tracks = jsonResponse['items'];
      List<TrackModel> trackList = [];

      for (var track in tracks) {
        trackList.add(TrackModel.fromJson(track['track']));
      }

      return Right(trackList);
    }

    if (response.statusCode == 401) {
      log("token expired");
      final newAccessToken = await getRefreshToken(refreshToken);
      newAccessToken.fold(
          (l) => log("error: ${l}"), (r) => log("new token: $r"));
      if (newAccessToken.isRight()) {
        final newToken = newAccessToken.getOrElse(() => "");
      }
    }
    debugPrint("error: ${response.body}");
    return Left(ServerFailure(message: response.body));
  }

  @override
  Future<Either<Failure, List<DeviceModel>>> getDevices(
      {required String token}) async {
    var response = await http.get(
        Uri.parse(
          "https://api.spotify.com/v1/me/player/devices",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json"
        });

    debugPrint("response: ${response.body}");

    var jsonResponse = json.decode(response.body);

    log("result ${response.statusCode} ");
    if (response.statusCode == 200) {
      final data = jsonResponse['devices'];
      List<DeviceModel> devices = [];

      for (var device in data) {
        devices.add(DeviceModel.fromJson(device));
      }

      return Right(devices);
    }

    if (response.statusCode == 401) {
      log("token expired");
      final newAccessToken = await getRefreshToken(refreshToken);
      newAccessToken.fold(
          (l) => log("error: ${l}"), (r) => log("new token: $r"));
      if (newAccessToken.isRight()) {
        final newToken = newAccessToken.getOrElse(() => "");
        return getDevices(token: newToken);
      }
    }
    debugPrint("error: ${response.body}");
    return Left(ServerFailure(message: response.body));
  }
}
