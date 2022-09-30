import 'dart:developer';

import 'package:aimoov_spotify/constants/constants.dart';
import 'package:aimoov_spotify/core/errors/failure.dart';
import 'package:aimoov_spotify/core/services/player_services.dart';
import 'package:aimoov_spotify/data/models/track_model.dart';
import 'package:aimoov_spotify/di/locator.dart';
import 'package:aimoov_spotify/domain/repository/spotify_repo.dart';
import 'package:aimoov_spotify/presentation/providers/player_provider.dart';
import 'package:aimoov_spotify/presentation/screens/widgets/animated_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_sdk/models/player_state.dart';
// import 'package:spotify/spotify.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:aimoov_spotify/core/extensions/string.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> searchResults = [];

  final TextEditingController _searchController = TextEditingController();

  String? searchQuery;
  String? spotifyToken;

  final _spotifyRepoImpl = locator<SpotifyRepo>();
  final _playerService = locator<PlayerService>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // get refresh token
    _getRefreshToken();

    SpotifySdk.getAccessToken(
            clientId: clientId, redirectUrl: redirect_uri, scope: spotifyScopes)
        .then((value) {
      setState(() {
        spotifyToken = value;
      });
    });
  }

  bool fullPlayer = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: spotifyToken == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                FutureBuilder(builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        // expandedHeight: 300,
                        floating: true,

                        bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(0.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search',
                                prefix: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      searchQuery = '';
                                    });

                                    FocusScope.of(context).unfocus();
                                  },
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                errorBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (searchQuery != null &&
                                  searchQuery!.isNotEmpty)
                                StreamBuilder<PlayerState>(
                                    stream: SpotifySdk.subscribePlayerState(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<PlayerState> snapshot) {
                                      var track = snapshot.data?.track;
                                      var playerState = snapshot.data;
                                      return FutureBuilder<
                                              dartz.Either<Failure,
                                                  List<TrackModel>>>(
                                          future: _spotifyRepoImpl.searchTrack(
                                              searchQuery!,
                                              token: spotifyToken!),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }

                                            if (snapshot.hasError) {
                                              return const Center(
                                                child: Text('Error'),
                                              );
                                            }

                                            return snapshot.data!.fold(
                                                (l) => Text(
                                                    'Error: ${l.diplayErrorMessage()}'),
                                                (r) {
                                              return ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount: r.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final track = r[index];

                                                    final bool
                                                        playingThisTrack =
                                                        playerState
                                                                ?.track!.uri ==
                                                            track.uri;
                                                    final bool isPlaying =
                                                        playerState != null
                                                            ? !playerState
                                                                .isPaused
                                                            : false;
                                                    return ListTile(
                                                      title: Text(track.name!),
                                                      subtitle: Text(track
                                                          .artists!
                                                          .map((e) => e.name)
                                                          .join(', ')),
                                                      onTap: () =>
                                                          _playerService
                                                              .play(track.uri!),
                                                      trailing: IconButton(
                                                        onPressed: () =>
                                                            _playerService.play(
                                                                track.uri!),
                                                        icon: Icon(
                                                          isPlaying &&
                                                                  playingThisTrack
                                                              ? Icons.pause
                                                              : Icons
                                                                  .play_arrow,
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            });
                                          });
                                    }),

                              // MaterialButton(
                              //   color: Colors.amber,
                              //   onPressed: () => _spotifyRepoImpl.getDevices(
                              //       token: spotifyToken!),
                              //   child: const Text('GetDevicesFromAPI'),
                              // ),

                              const SizedBox(
                                height: 20,
                              ),

                              // recents

                              const Text(
                                "Recents",
                              ),
                              const SizedBox(height: 15.0),
                              SizedBox(
                                height: height * 0.35,
                                child: FutureBuilder<
                                        dartz
                                            .Either<Failure, List<TrackModel>>>(
                                    // future: SpotifyApi.withAccessToken(spotifyToken).recommendations.get(),
                                    future: _spotifyRepoImpl.recentTracks(
                                        token: spotifyToken!),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      return snapshot.data!.fold(
                                          (l) => const Text('Error'), (r) {
                                        return ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: r.length,
                                            itemBuilder: (context, item) {
                                              final track = r[item];
                                              return Container(
                                                margin: const EdgeInsets.only(
                                                    right: 5.0),
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                      height: height * .3,
                                                      width: width * .4,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.amber,
                                                      ),
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 15.0),
                                                      child: Stack(
                                                        children: [
                                                          CachedNetworkImage(
                                                            imageUrl:
                                                                track.image!,
                                                            fit: BoxFit.cover,
                                                            imageBuilder: (context,
                                                                    imageProvider) =>
                                                                Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                image: DecorationImage(
                                                                    image:
                                                                        imageProvider,
                                                                    fit: BoxFit
                                                                        .cover),
                                                              ),
                                                            ),
                                                            placeholder:
                                                                (context,
                                                                        url) =>
                                                                    const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                              ),
                                                            ),
                                                            errorWidget:
                                                                (context, url,
                                                                    error) {
                                                              return const Center(
                                                                child: Icon(
                                                                  Icons.error,
                                                                  color: Colors
                                                                      .teal,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            child: Container(
                                                              decoration: const BoxDecoration(
                                                                  color: Colors
                                                                      .green,
                                                                  shape: BoxShape
                                                                      .circle),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              child: InkWell(
                                                                onTap: () =>
                                                                    _playerService
                                                                        .play(track
                                                                            .uri!),
                                                                child: const Icon(
                                                                    Icons
                                                                        .play_arrow),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Text(
                                                      track.name!.threeDots(15),
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            });
                                      });
                                    }),
                              ),
                              const SizedBox(height: 20.0),
                              const Text(
                                "Playlists",
                              ),
                              const SizedBox(height: 15.0),
                              SizedBox(
                                height: height * 0.25,
                                child: FutureBuilder<Iterable<PlaylistSimple>>(
                                    future: SpotifyApi.withAccessToken(
                                            spotifyToken!)
                                        .playlists
                                        .me
                                        .all(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      final List<PlaylistSimple> playLists =
                                          snapshot.data != null &&
                                                  snapshot.data!.isNotEmpty
                                              ? snapshot.data!.toList()
                                              : [];
                                      return ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: playLists.length,
                                          itemBuilder: (context, item) {
                                            final playlist = playLists[item];

                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  right: 15.0),
                                              child: Column(
                                                children: <Widget>[
                                                  playlist.images != null &&
                                                          playlist.images!
                                                              .isNotEmpty &&
                                                          playlist.images!.first
                                                                  .url !=
                                                              null
                                                      ? CachedNetworkImage(
                                                          imageUrl: playlist
                                                              .images![0].url!,
                                                          fit: BoxFit.cover,
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const SizedBox(),
                                                          imageBuilder: ((context,
                                                                  imageProvider) =>
                                                              Container(
                                                                height:
                                                                    height * .2,
                                                                width:
                                                                    width * .4,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .amber,
                                                                  image: playlist
                                                                                  .images !=
                                                                              null &&
                                                                          playlist
                                                                              .images!
                                                                              .isNotEmpty
                                                                      ? DecorationImage(
                                                                          image:
                                                                              imageProvider,
                                                                          fit: BoxFit
                                                                              .cover)
                                                                      : null,
                                                                ),
                                                                margin: const EdgeInsets
                                                                        .only(
                                                                    bottom:
                                                                        15.0),
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .bottomRight,
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      _playerService
                                                                          .playListPlay(
                                                                              playlist.uri!);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      decoration: const BoxDecoration(
                                                                          color: Colors
                                                                              .green,
                                                                          shape:
                                                                              BoxShape.circle),
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              10),
                                                                      child: const Icon(
                                                                          Icons
                                                                              .play_arrow),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )),
                                                        )
                                                      : const SizedBox(),
                                                  Text(
                                                    playlist.name ?? 'unknown',
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          });
                                    }),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                // bottom Player

                AnimatedPlayer(),
                // Consumer<PlayerProvider>(
                //     builder: (context, playerProvider, child) {
                //   final playertrack = playerProvider.currentTrack;

                //   return StreamBuilder<PlayerState>(
                //     stream: SpotifySdk.subscribePlayerState(),
                //     builder: (BuildContext context,
                //         AsyncSnapshot<PlayerState> snapshot) {
                //       var track = snapshot.data?.track;
                //       var playerState = snapshot.data;

                //       return AnimatedPositioned(
                //         duration: const Duration(milliseconds: 500),
                //         bottom: playerState == null || track == null ? 0 : 15,
                //         child: playerState == null || track == null
                //             ? const SizedBox()
                //             : AnimatedContainer(
                //                 duration: const Duration(milliseconds: 500),
                //                 height: height * 0.13,
                //                 width: width,
                //                 color: Colors.transparent,
                //                 child: Stack(
                //                   alignment: Alignment.bottomCenter,
                //                   children: [
                //                     Row(
                //                       children: [
                //                         Container(
                //                           height: height * 0.1,
                //                           width: width * 0.2,
                //                           decoration: const BoxDecoration(
                //                             color: Colors.amber,
                //                             borderRadius: BorderRadius.only(
                //                                 topLeft: Radius.circular(33),
                //                                 bottomLeft:
                //                                     Radius.circular(33)),
                //                           ),
                //                           child: Center(
                //                               child: InkWell(
                //                                   onTap: () async {
                //                                     await _playerService
                //                                         .skipPrevious();

                //                                     // playerProvider
                //                                     //     .setCurrentTrack(
                //                                     //         playertrack!);
                //                                   },
                //                                   child: const Icon(
                //                                       Icons.skip_previous))),
                //                         ),
                //                         InkWell(
                //                           onTap: () {
                //                             // Navigator.push(
                //                             //     context,
                //                             //     MaterialPageRoute(
                //                             //         builder: (context) =>
                //                             //             const PlayerScreen()));
                //                           },
                //                           child: Container(
                //                             height: height * 0.1,
                //                             width: width * 0.6,
                //                             color: Colors.black,
                //                             child: Column(
                //                               mainAxisAlignment:
                //                                   MainAxisAlignment.center,
                //                               children: [
                //                                 SizedBox(
                //                                   height: height * .03,
                //                                 ),
                //                                 Text(
                //                                   track.name.threeDots(20),
                //                                   style: const TextStyle(
                //                                     color: Colors.white,
                //                                     fontSize: 15,
                //                                     fontWeight: FontWeight.w600,
                //                                   ),
                //                                 ),
                //                                 const SizedBox(
                //                                   height: 5,
                //                                 ),
                //                                 Text(
                //                                   track.artists[0].name!
                //                                       .threeDots(20),
                //                                   style: const TextStyle(
                //                                     color: Colors.white,
                //                                     fontSize: 12,
                //                                     fontWeight: FontWeight.w600,
                //                                   ),
                //                                 ),
                //                               ],
                //                             ),
                //                           ),
                //                         ),
                //                         Container(
                //                           height: height * 0.1,
                //                           width: width * 0.2,
                //                           decoration: const BoxDecoration(
                //                             color: Colors.amber,
                //                             borderRadius: BorderRadius.only(
                //                               topRight: Radius.circular(33),
                //                               bottomRight: Radius.circular(33),
                //                             ),
                //                           ),
                //                           child: Center(
                //                               child: InkWell(
                //                                   onTap:
                //                                       _playerService.skipNext,
                //                                   child:
                //                                       Icon(Icons.skip_next))),
                //                         ),
                //                       ],
                //                     ),
                //                     Positioned(
                //                       top: 0,
                //                       right: 40,
                //                       left: 40,
                //                       child: Row(
                //                         mainAxisAlignment:
                //                             MainAxisAlignment.spaceAround,
                //                         children: [
                //                           Container(
                //                             height: height * 0.06,
                //                             width: height * 0.06,
                //                             decoration: BoxDecoration(
                //                                 shape: BoxShape.circle,
                //                                 color: Colors.amber,
                //                                 boxShadow: [
                //                                   BoxShadow(
                //                                     color: Colors.black
                //                                         .withOpacity(0.5),
                //                                     spreadRadius: 1,
                //                                     blurRadius: 7,
                //                                     offset: const Offset(0,
                //                                         3), // changes position of shadow
                //                                   ),
                //                                 ]),
                //                             child: Center(
                //                               child: InkWell(
                //                                 onTap: () => _playerService
                //                                     .setShuffle(!playerState
                //                                         .playbackOptions
                //                                         .isShuffling),
                //                                 child: Icon(
                //                                   Icons.shuffle,
                //                                   color: playerState
                //                                           .playbackOptions
                //                                           .isShuffling
                //                                       ? Colors.white
                //                                       : Colors.black,
                //                                   size: 30,
                //                                 ),
                //                               ),
                //                             ),
                //                           ),
                //                           Container(
                //                             height: height * 0.06,
                //                             width: height * 0.06,
                //                             decoration: BoxDecoration(
                //                                 shape: BoxShape.circle,
                //                                 color: Colors.amber,
                //                                 boxShadow: [
                //                                   BoxShadow(
                //                                     color: Colors.black
                //                                         .withOpacity(0.5),
                //                                     spreadRadius: 1,
                //                                     blurRadius: 7,
                //                                     offset: const Offset(0,
                //                                         3), // changes position of shadow
                //                                   ),
                //                                 ]),
                //                             child: Center(
                //                               child: InkWell(
                //                                 onTap: () async {
                //                                   log("playerState.isPaused: ${playerState.isPaused}");
                //                                   if (!playerState.isPaused) {
                //                                     await SpotifySdk.pause();
                //                                     playerProvider.pause();
                //                                     // context
                //                                     //     .read<PlayerProvider>()
                //                                     //     .pause();
                //                                   } else {
                //                                     await SpotifySdk.resume();
                //                                     playerProvider.play();
                //                                     // context
                //                                     //     .read<PlayerProvider>()
                //                                     //     .play();
                //                                   }
                //                                 },
                //                                 child: Icon(
                //                                   // playerProvider.isPlaying
                //                                   playerState.isPaused
                //                                       ? Icons.play_arrow
                //                                       : Icons.pause,
                //                                   color: Colors.white,
                //                                   size: 30,
                //                                 ),
                //                               ),
                //                             ),
                //                           ),
                //                           Container(
                //                             height: height * 0.06,
                //                             width: height * 0.06,
                //                             decoration: BoxDecoration(
                //                                 shape: BoxShape.circle,
                //                                 color: Colors.amber,
                //                                 boxShadow: [
                //                                   BoxShadow(
                //                                     color: Colors.black
                //                                         .withOpacity(0.5),
                //                                     spreadRadius: 1,
                //                                     blurRadius: 7,
                //                                     offset: const Offset(0,
                //                                         3), // changes position of shadow
                //                                   ),
                //                                 ]),
                //                             child: Center(
                //                               child: InkWell(
                //                                 onTap: () => _playerService
                //                                     .setRepeatMode(playerState
                //                                                 .playbackOptions
                //                                                 .repeatMode ==
                //                                             RepeatMode.off
                //                                         ? RepeatMode.track
                //                                         : RepeatMode.off),
                //                                 child: Icon(
                //                                   Icons.repeat,
                //                                   color: playerState
                //                                               .playbackOptions
                //                                               .repeatMode ==
                //                                           RepeatMode.track
                //                                       ? Colors.white
                //                                       : Colors.black,
                //                                   size: 30,
                //                                 ),
                //                               ),
                //                             ),
                //                           ),
                //                         ],
                //                       ),
                //                     )
                //                   ],
                //                 ),
                //               ),
                //       );
                //     },
                //   );
                // }),
              ],
            ),
    );
  }

  void _getRefreshToken() async {
    SpotifyApi.asyncFromCredentials(
            SpotifyApiCredentials(clientId, clientSecret))
        .then((spotifyApi) {
      spotifyApi.getCredentials().then((credentials) {
        print(credentials.refreshToken);
      });
    });
  }
}
