import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class PlayerService {
  Future play(String uri) async {
    log('playing....');

    try {
      await SpotifySdk.play(spotifyUri: uri);
    } on PlatformException catch (e) {
      log('message: ${e.message}');
    } on MissingPluginException {
      log('not implemented');
    }
  }

  Future playListPlay(String uri) async {
    log('playing....');

    try {
      await SpotifySdk.play(spotifyUri: uri
          // 'spotify:track:58kNJana4w5BIjlZE2wq5m'
          );
      // context.read<PlayerProvider>().setCurrentTrack(track);
    } on PlatformException catch (e) {
      log('message: ${e.message}');
    } on MissingPluginException {
      log('not implemented');
    }
  }

  Future<PlayerState?> getPlayerState() async {
    try {
      return await SpotifySdk.getPlayerState();
    } on PlatformException catch (e) {
      // log("Platform Error => $e");
      return null;
    } on MissingPluginException {
      // log('not implemented');
      return null;
    }
  }

  Future<void> queue() async {
    try {
      await SpotifySdk.queue(
          spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m');
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: e.message!);

      log("Platform Error => $e");
    } on MissingPluginException {
      log('not implemented');
    }
  }

  Future<void> toggleRepeat() async {
    try {
      await SpotifySdk.toggleRepeat();
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: e.message!);

      log("Platform Error => $e");
    } on MissingPluginException {
      log('not implemented');
    }
  }

  Future<void> setRepeatMode(RepeatMode repeatMode) async {
    try {
      await SpotifySdk.setRepeatMode(
        repeatMode: repeatMode,
      );
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: e.message!);

      log("Platform Error => $e");
    } on MissingPluginException {
      log('not implemented');
    }
  }

  Future<void> setShuffle(bool shuffle) async {
    try {
      await SpotifySdk.setShuffle(
        shuffle: shuffle,
      );
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: e.message!);

      log("Platform Error => $e");
    } on MissingPluginException {
      log('not implemented');
    }
  }

  Future<void> skipNext() async {
    try {
      final result = await SpotifySdk.skipNext();
      log("skipNext: $result");
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: e.message!);
      log("Platform Error => $e");
    } on MissingPluginException {
      log('not implemented');
    }
  }

  Future<void> skipPrevious() async {
    try {
      final skip = await SpotifySdk.skipPrevious();
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: e.message!);

      log("Platform Error => $e");
    } on MissingPluginException {
      log('not implemented');
    }
  }

  Future<void> seekTo(int positionInMilliseconds) async {
    try {
      final skip = await SpotifySdk.seekTo(
          positionedMilliseconds: positionInMilliseconds);
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: e.message!);

      log("Platform Error => $e");
    } on MissingPluginException {
      log('not implemented');
    }
  }
}
