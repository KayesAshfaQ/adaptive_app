import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:http/http.dart' as http;

class AuthedUserPlaylists extends ChangeNotifier {
  YouTubeApi? _api;

  set authClient(http.Client client) {
    // Drop constructor, add setter
    _api = YouTubeApi(client);
    _loadPlaylists();
  }

  bool get isLoggedIn => _api != null; // Add property

  final List<Playlist> _playlists = [];

  List<Playlist> get playlists => UnmodifiableListView(_playlists);

  final Map<String, List<PlaylistItem>> _playlistItems = {};

  // It fetches the list of playlists from the YouTube API and stores them in the _playlists list.
  Future<void> _loadPlaylists() async {
    String? nextPageToken;
    _playlists.clear();

    do {
      final response = await _api!.playlists.list(
        ['snippet', 'contentDetails', 'id'],
        mine: true,
        maxResults: 50,
        pageToken: nextPageToken,
      );
      _playlists.addAll(response.items!);
      _playlists.sort((a, b) => a.snippet!.title!
          .toLowerCase()
          .compareTo(b.snippet!.title!.toLowerCase()));
      notifyListeners();
      nextPageToken = response.nextPageToken;
    } while (nextPageToken != null);
  }

  // This method is responsible for retrieving the data from _playlistItems map
  // by using the playlistId and returns an unmodifiable list of PlaylistItem objects.
  List<PlaylistItem> playlistItems({required String playlistId}) {
    if (!_playlistItems.containsKey(playlistId)) {
      _playlistItems[playlistId] = [];
      _retrievePlaylist(playlistId);
    }
    return UnmodifiableListView(_playlistItems[playlistId]!);
  }

  // It fetches the list of playlist items (videos) from the YouTube API
  // and stores them in the _playlistItems map.
  Future<void> _retrievePlaylist(String playlistId) async {
    String? nextPageToken;
    do {
      var response = await _api!.playlistItems.list(
        ['snippet', 'contentDetails'],
        playlistId: playlistId,
        maxResults: 25,
        pageToken: nextPageToken,
      );
      var items = response.items;
      if (items != null) {
        _playlistItems[playlistId]!.addAll(items);
      }
      notifyListeners();
      nextPageToken = response.nextPageToken;
    } while (nextPageToken != null);
  }
}
