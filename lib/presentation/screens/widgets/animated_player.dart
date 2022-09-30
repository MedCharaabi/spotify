import 'dart:developer';

import 'package:aimoov_spotify/core/extensions/string.dart';
import 'package:aimoov_spotify/core/services/player_services.dart';
import 'package:aimoov_spotify/di/locator.dart';
import 'package:aimoov_spotify/presentation/providers/player_provider.dart';
import 'package:aimoov_spotify/utils/str_digit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class AnimatedPlayer extends HookWidget {
  const AnimatedPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final playerPosition = useState<int>(0);

    useEffect((() {
      log("progress:");

// listen to player state position and update the progress
      SpotifySdk.subscribePlayerState().listen((playerState) {
        playerPosition.value = playerState.playbackPosition;
      });

      return () {};
    }), []);

    final _playerService = locator<PlayerService>();

    final track = context.read<PlayerProvider>().currentTrack;

    return Consumer<PlayerProvider>(builder: (context, playerProvider, child) {
      final playertrack = playerProvider.currentTrack;

      return StreamBuilder<PlayerState>(
        stream: SpotifySdk.subscribePlayerState(),
        builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
          var track = snapshot.data?.track;
          var playerState = snapshot.data;

          return AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            bottom: playerState == null || track == null ? 0 : 15,
            child: playerState == null || track == null
                ? const SizedBox()
                : AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    // height: height * 0.15,
                    width: width,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(10),

                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  track.name.threeDots(20),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                if (track.artists != null &&
                                    track.artists.isNotEmpty)
                                  Text(
                                    track.artists[0].name!.threeDots(20),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: InkWell(
                                        onTap: _playerService.skipPrevious,
                                        child: const Icon(Icons.skip_previous)),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: InkWell(
                                      onTap: () async {
                                        log("playerState.isPaused: ${playerState.isPaused}");
                                        if (!playerState.isPaused) {
                                          await SpotifySdk.pause();
                                          playerProvider.pause();
                                          // context
                                          //     .read<PlayerProvider>()
                                          //     .pause();
                                        } else {
                                          await SpotifySdk.resume();
                                          playerProvider.play();
                                          // context
                                          //     .read<PlayerProvider>()
                                          //     .play();
                                        }
                                      },
                                      child: Icon(
                                        // playerProvider.isPlaying
                                        playerState.isPaused
                                            ? Icons.play_arrow
                                            : Icons.pause,
                                        color: Colors.black,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: InkWell(
                                        onTap: _playerService.skipNext,
                                        child: Icon(Icons.skip_next)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
// Slider
                        const SizedBox(
                          height: 5,
                        ),
                        // Row(
                        //   children: <Widget>[
                        //     Text(
                        //       milisecondToTimeConverter(
                        //           playerState.playbackPosition),
                        //       style: const TextStyle(
                        //         color: Colors.white,
                        //         fontSize: 12,
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //     ),
                        //     const Spacer(),
                        //     Text(
                        //       playerState.track != null
                        //           ? milisecondToTimeConverter(
                        //               playerState.track!.duration)
                        //           : '-',
                        //       style: const TextStyle(
                        //         color: Colors.white,
                        //         fontSize: 12,
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(
                        //   height: 10,
                        // ),
                        // Slider(
                        //   value: playerPosition.value.toDouble(),
                        //   onChanged: (value) =>
                        //       _playerService.seekTo(value.toInt()),
                        //   min: 0,
                        //   max: playerState.track!.duration.toDouble(),
                        //   activeColor: Colors.white,
                        //   inactiveColor: Colors.white.withOpacity(0.5),
                        // ),
                      ],
                    ),

                    // child: Stack(
                    //   alignment: Alignment.bottomCenter,
                    //   children: [
                    //     Row(
                    //       children: [
                    //         Container(
                    //           height: height * 0.1,
                    //           width: width * 0.2,
                    //           decoration: const BoxDecoration(
                    //             color: Colors.amber,
                    //             borderRadius: BorderRadius.only(
                    //                 topLeft: Radius.circular(33),
                    //                 bottomLeft: Radius.circular(33)),
                    //           ),
                    //           child: Center(
                    //               child: InkWell(
                    //                   onTap: () async {
                    //                     await _playerService.skipPrevious();

                    //                     // playerProvider
                    //                     //     .setCurrentTrack(
                    //                     //         playertrack!);
                    //                   },
                    //                   child: const Icon(Icons.skip_previous))),
                    //         ),
                    //         InkWell(
                    //           onTap: () {
                    //             // Navigator.push(
                    //             //     context,
                    //             //     MaterialPageRoute(
                    //             //         builder: (context) =>
                    //             //             const PlayerScreen()));
                    //           },
                    //           child: Container(
                    //             height: height * 0.1,
                    //             width: width * 0.6,
                    //             color: Colors.black,
                    //             child: Column(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 SizedBox(
                    //                   height: height * .03,
                    //                 ),
                    //                 Text(
                    //                   track.name.threeDots(20),
                    //                   style: const TextStyle(
                    //                     color: Colors.white,
                    //                     fontSize: 15,
                    //                     fontWeight: FontWeight.w600,
                    //                   ),
                    //                 ),
                    //                 const SizedBox(
                    //                   height: 5,
                    //                 ),
                    //                 Text(
                    //                   track.artists[0].name!.threeDots(20),
                    //                   style: const TextStyle(
                    //                     color: Colors.white,
                    //                     fontSize: 12,
                    //                     fontWeight: FontWeight.w600,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //         Container(
                    //           height: height * 0.1,
                    //           width: width * 0.2,
                    //           decoration: const BoxDecoration(
                    //             color: Colors.amber,
                    //             borderRadius: BorderRadius.only(
                    //               topRight: Radius.circular(33),
                    //               bottomRight: Radius.circular(33),
                    //             ),
                    //           ),
                    //           child: Center(
                    //               child: InkWell(
                    //                   onTap: _playerService.skipNext,
                    //                   child: Icon(Icons.skip_next))),
                    //         ),
                    //       ],
                    //     ),
                    //     Positioned(
                    //       top: 0,
                    //       right: 40,
                    //       left: 40,
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //         children: [
                    //           Container(
                    //             height: height * 0.06,
                    //             width: height * 0.06,
                    //             decoration: BoxDecoration(
                    //                 shape: BoxShape.circle,
                    //                 color: Colors.amber,
                    //                 boxShadow: [
                    //                   BoxShadow(
                    //                     color: Colors.black.withOpacity(0.5),
                    //                     spreadRadius: 1,
                    //                     blurRadius: 7,
                    //                     offset: const Offset(
                    //                         0, 3), // changes position of shadow
                    //                   ),
                    //                 ]),
                    //             child: Center(
                    //               child: InkWell(
                    //                 onTap: () => _playerService.setShuffle(
                    //                     !playerState
                    //                         .playbackOptions.isShuffling),
                    //                 child: Icon(
                    //                   Icons.shuffle,
                    //                   color: playerState
                    //                           .playbackOptions.isShuffling
                    //                       ? Colors.white
                    //                       : Colors.black,
                    //                   size: 30,
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //           Container(
                    //             height: height * 0.06,
                    //             width: height * 0.06,
                    //             decoration: BoxDecoration(
                    //                 shape: BoxShape.circle,
                    //                 color: Colors.amber,
                    //                 boxShadow: [
                    //                   BoxShadow(
                    //                     color: Colors.black.withOpacity(0.5),
                    //                     spreadRadius: 1,
                    //                     blurRadius: 7,
                    //                     offset: const Offset(
                    //                         0, 3), // changes position of shadow
                    //                   ),
                    //                 ]),
                    //             child: Center(
                    //               child: InkWell(
                    //                 onTap: () async {
                    //                   log("playerState.isPaused: ${playerState.isPaused}");
                    //                   if (!playerState.isPaused) {
                    //                     await SpotifySdk.pause();
                    //                     playerProvider.pause();
                    //                     // context
                    //                     //     .read<PlayerProvider>()
                    //                     //     .pause();
                    //                   } else {
                    //                     await SpotifySdk.resume();
                    //                     playerProvider.play();
                    //                     // context
                    //                     //     .read<PlayerProvider>()
                    //                     //     .play();
                    //                   }
                    //                 },
                    //                 child: Icon(
                    //                   // playerProvider.isPlaying
                    //                   playerState.isPaused
                    //                       ? Icons.play_arrow
                    //                       : Icons.pause,
                    //                   color: Colors.white,
                    //                   size: 30,
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //           Container(
                    //             height: height * 0.06,
                    //             width: height * 0.06,
                    //             decoration: BoxDecoration(
                    //                 shape: BoxShape.circle,
                    //                 color: Colors.amber,
                    //                 boxShadow: [
                    //                   BoxShadow(
                    //                     color: Colors.black.withOpacity(0.5),
                    //                     spreadRadius: 1,
                    //                     blurRadius: 7,
                    //                     offset: const Offset(
                    //                         0, 3), // changes position of shadow
                    //                   ),
                    //                 ]),
                    //             child: Center(
                    //               child: InkWell(
                    //                 onTap: () => _playerService.setRepeatMode(
                    //                     playerState.playbackOptions
                    //                                 .repeatMode ==
                    //                             RepeatMode.off
                    //                         ? RepeatMode.track
                    //                         : RepeatMode.off),
                    //                 child: Icon(
                    //                   Icons.repeat,
                    //                   color: playerState
                    //                               .playbackOptions.repeatMode ==
                    //                           RepeatMode.track
                    //                       ? Colors.white
                    //                       : Colors.black,
                    //                   size: 30,
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     )
                    //   ],
                    // ),
                  ),
          );
        },
      );
    });
    ;
  }
}
