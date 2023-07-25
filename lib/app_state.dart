import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:http/http.dart' as http;

class FlutterDevPlaylists extends ChangeNotifier {
  final String _flutterDevAccountId;
  late final YouTubeApi _api;

  final List<Playlist> _playlists = [];

  List<Playlist> get playlists => UnmodifiableListView(_playlists);

  final Map<String, List<PlaylistItem>> _playlistItems = {};

  FlutterDevPlaylists({
    required String flutterDevAccountId,
    required String youTubeApiKey,
  }) : _flutterDevAccountId = flutterDevAccountId {
    // The YouTubeApi initialized with an instance of _ApiKeyClient, which is a custom HTTP client
    _api = YouTubeApi(
      _ApiKeyClient(
        client: http.Client(),
        key: youTubeApiKey,
      ),
    );

    _loadPlayLists();
  }

  // It fetches the list of playlists from the YouTube API and stores them in the _playlists list.
  Future<void> _loadPlayLists() async {
    String? nextPageToken;
    _playlists.clear();

    do {
      final response = await _api.playlists.list(
        ['snippet', 'contentDetails', 'id'],
        channelId: _flutterDevAccountId,
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
      var response = await _api.playlistItems.list(
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

class _ApiKeyClient extends http.BaseClient {
  _ApiKeyClient({required this.key, required this.client});

  final String key;
  final http.Client client;

  /*
    This code is to add the API key to the query parameters of the HTTP request before it is sent to the YouTube API. 
    This is necessary to authenticate the request and ensure that it is authorized to access the requested resources.
  */
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // replaces the queryParameters of the request URL with a new map that creates
    // a new map that includes all the existing query parameters of the URL
    // and adds a new key-value pair for the API key.
    final url = request.url.replace(queryParameters: <String, List<String>>{
      ...request.url.queryParametersAll,
      'key': [key]
    });

    // The modified URL is then used to create a new http.Request instance, which is passed to the send method
    // of the underlying HTTP client. The send method returns a Future that resolves to an instance of
    // http.StreamedResponse, which represents the HTTP response received from the server.
    return client.send(http.Request(request.method, url));
  }
}
