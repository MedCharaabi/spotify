import 'dart:developer';

import 'package:aimoov_spotify/core/errors/failure.dart';
import 'package:aimoov_spotify/data/models/track_model.dart';
import 'package:aimoov_spotify/data/remote/spotify_repo_impl.dart';
import 'package:aimoov_spotify/domain/entities/track.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomSearchDelegate extends SearchDelegate {
  CustomSearchDelegate()
      : super(
          searchFieldLabel: 'Search',
          searchFieldStyle: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
          keyboardType: TextInputType.text,
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return super.appBarTheme(context).copyWith(
          primaryColor: Colors.amber,
          // primaryIconTheme: Theme.of(context).primaryIconTheme.copyWith(
          //       color: Colors.black,
          //     ),
          primaryTextTheme: Theme.of(context).textTheme,
          appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
              color: Colors.amber,
              elevation: 0.0),
          textTheme: const TextTheme(
            subtitle1: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      InkWell(
        onTap: () {
          query = '';
        },
        child: Container(
          margin: const EdgeInsets.only(right: 15.0),
          padding: const EdgeInsets.all(2.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.clear,
            color: Colors.amber,
            size: 20,
          ),
        ),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back,
      ),
      onPressed: () {
        // SystemChrome.setSystemUIOverlayStyle(
        //   SystemUiOverlayStyle(
        //     statusBarColor: Colors.white,
        //   ),
        // );

        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: FutureBuilder<Either<Failure, List<TrackModel>>>(
          future: SpotifyRepoImpl().searchTrack(query),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return snapshot.data!.fold((l) {
              return Text('$l');
            }, (r) {
              final List<Track> tracks = r;

              return ListView.builder(
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final item = tracks[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.amber,
                        )),
                    child: ListTile(
                      title: Text(
                        item.name!,
                        style: const TextStyle(),
                      ),
                      onTap: () {},
                    ),
                  );
                },
              );
            });
          }),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Track> tracks = [];
    // for (var item in perspectiveData) {
    //   if (item['title'].toLowerCase().contains(query.toLowerCase())) {
    //     tracks.add(item);
    //   }
    // }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final item = tracks[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
            // title: Text(
            //     '${matchQuery[index]["title"]} ${matchQuery[index]["date"]}',
            // style: text_bold_nexa),
            title: Text(
              item.name!,
            ),
            onTap: () {},
          );
        },
      ),
    );
  }
}
