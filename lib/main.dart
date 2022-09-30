import 'dart:developer';

import 'package:aimoov_spotify/constants/constants.dart';
import 'package:aimoov_spotify/di/locator.dart';
import 'package:aimoov_spotify/presentation/providers/player_provider.dart';
import 'package:aimoov_spotify/presentation/providers/spotify_token_provider.dart';
import 'package:aimoov_spotify/presentation/screens/auth_screen.dart';
import 'package:aimoov_spotify/presentation/screens/home_screen.dart';
import 'package:aimoov_spotify/widgets/age_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PlayerProvider>(
          create: (_) => PlayerProvider(),
        ),
        ChangeNotifierProvider<SpotifyTokenProvider>(
          create: (_) => SpotifyTokenProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),

      // home: const TestHome(),
      home: StreamBuilder<PlayerState>(
          stream: SpotifySdk.subscribePlayerState(),
          builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
            var track = snapshot.data?.track;
            var playerState = snapshot.data;

            if (playerState == null || track == null) {
              return AuthScreen();
            }
            return HomeScreen();
          }),
    );
  }
}

// class TestHome extends StatelessWidget {
//   const TestHome({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: AgePickerPage3(),
//     );
//   }
// }
