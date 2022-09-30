import 'package:equatable/equatable.dart';

class Track extends Equatable {
  Track({
    this.image,
    this.id,
    this.name,
    this.previewUrl,
    this.uri,
    this.href,
    this.artists,
  });

  final String? id;
  final String? name;
  final String? previewUrl;
  final String? uri;
  final String? href;
  final String? image;
  List<Artist>? artists;

  @override
  List<Object?> get props => [id, name, previewUrl, uri, href, artists];
}

class Artist {
  Artist({
    this.externalUrls,
    this.href,
    this.id,
    this.name,
    this.type,
    this.uri,
  });

  ExternalUrls? externalUrls;
  String? href;
  String? id;
  String? name;
  String? type;
  String? uri;

  factory Artist.fromJson(Map<String, dynamic> json) => Artist(
        externalUrls: ExternalUrls.fromJson(json["external_urls"]),
        href: json["href"],
        id: json["id"],
        name: json["name"],
        type: json["type"],
        uri: json["uri"],
      );
}

class ExternalUrls {
  ExternalUrls({
    this.spotify,
  });

  String? spotify;

  factory ExternalUrls.fromJson(Map<String, dynamic> json) => ExternalUrls(
        spotify: json["spotify"],
      );

  Map<String, dynamic> toJson() => {
        "spotify": spotify,
      };
}
