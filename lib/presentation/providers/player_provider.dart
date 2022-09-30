import 'package:aimoov_spotify/domain/entities/track.dart';
import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class PlayerProvider extends ChangeNotifier {
  Track? _currentTrack;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  Stream<int> _position = Stream.periodic(Duration(seconds: 1), (x) => x);

  Stream<int> get positionStream => _position;

  Track? get currentTrack => _currentTrack;

  void setCurrentTrack(Track track) {
    _currentTrack = track;
    _isPlaying = true;
    notifyListeners();
  }

  void play() {
    _isPlaying = true;

    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    notifyListeners();
  }
}
