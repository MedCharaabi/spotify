import 'package:aimoov_spotify/core/services/player_services.dart';
import 'package:aimoov_spotify/data/remote/spotify_repo_impl.dart';
import 'package:aimoov_spotify/domain/repository/spotify_repo.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<SpotifyRepo>(() => SpotifyRepoImpl());
  locator.registerLazySingleton<PlayerService>(() => PlayerService());
}
