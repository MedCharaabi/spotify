import 'package:flutter/material.dart';

class SpotifyTokenProvider extends ChangeNotifier {
  String? _spotifyToken;

  String? get spotifyToken => _spotifyToken;

  void setSpotifyToken(String token) {
    _spotifyToken = token;
    notifyListeners();
  }
}
