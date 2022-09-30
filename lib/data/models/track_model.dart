import 'package:aimoov_spotify/domain/entities/track.dart';
import 'package:flutter/material.dart';

class TrackModel extends Track {
  TrackModel({
    String? id,
    String? name,
    String? previewUrl,
    String? uri,
    String? href,
    String? image,
    List<Artist>? artists,
  }) : super(
          id: id,
          name: name,
          previewUrl: previewUrl,
          uri: uri,
          href: href,
          artists: artists,
          image: image,
        );

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    debugPrint("json: $json");

    return TrackModel(
      id: json["id"],
      name: json["name"],
      image: json['album']['images'][0]['url'],
      previewUrl: json["preview_url"],
      uri: json["uri"],
      href: json["href"],
      artists:
          List<Artist>.from(json["artists"].map((x) => Artist.fromJson(x))),
    );
  }
}
