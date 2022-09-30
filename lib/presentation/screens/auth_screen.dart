import 'dart:developer';

import 'package:aimoov_spotify/constants/constants.dart';
import 'package:aimoov_spotify/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoading = false;
  bool isLoggedIn = false;

  String? errorAuth;

  Future<void> connectToSpotifyRemote() async {
    try {
      setState(() {
        isLoading = true;
      });

      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: clientId, redirectUrl: redirect_uri);

      setState(() {
        isLoading = false;
        errorAuth = null;
      });
      if (result) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    } on PlatformException catch (e) {
      log('${e.code}, message ${e.message}');
      setState(() {
        isLoading = false;
        errorAuth = e.message;
      });
    } on MissingPluginException {
      setState(() {
        isLoading = false;
      });
      log('not implemented');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              color: Colors.green,
              onPressed: connectToSpotifyRemote,
              child: const Text('Connect Spotify'),
            ),
            const SizedBox(
              height: 17,
            ),
            if (errorAuth != null)
              Text(
                errorAuth!,
                style: const TextStyle(color: Colors.red),
              )
          ],
        ),
      ),
    );
  }
}
