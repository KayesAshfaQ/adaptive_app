// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:split_view/split_view.dart';

import 'package:adaptive_app/src/playlists.dart';

import 'playlist_details.dart';

class AdaptivePlaylists extends StatelessWidget {
  const AdaptivePlaylists({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final targetPlatform = Theme.of(context).platform;

    if (targetPlatform == TargetPlatform.android ||
        targetPlatform == TargetPlatform.iOS ||
        screenWidth <= 600) {
      return const NarrowDisplayPlaylists();
    } else {
      return const WideDisplayPlaylists();
    }
  }
}

class NarrowDisplayPlaylists extends StatelessWidget {
  final bool isAppBarVisible;

  const NarrowDisplayPlaylists({
    Key? key,
    this.isAppBarVisible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isAppBarVisible
          ? AppBar(
              title: const Text('FlutterDev Playlist'),
            )
          : null,
      body: Playlists(
        playlistSelected: (playlist) {
          context.go(
            Uri(
              path: '/playlist/${playlist.id}',
              queryParameters: <String, String>{
                'title': playlist.snippet!.title!
              },
            ).toString(),
          );
        },
      ),
    );
  }
}

class WideDisplayPlaylists extends StatefulWidget {
  const WideDisplayPlaylists({super.key});

  @override
  State<WideDisplayPlaylists> createState() => _WideDisplayPlaylistsState();
}

class _WideDisplayPlaylistsState extends State<WideDisplayPlaylists> {
  Playlist? selectedPlaylist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: switch (selectedPlaylist?.snippet?.title) {
          String title => Text('FlutterDev Playlist: $title'),
          _ => const Text('FlutterDev Playlists'),
        },
      ),
      body: SplitView(
        viewMode: SplitViewMode.Horizontal,
        children: [
          Playlists(playlistSelected: (playlist) {
            setState(() {
              selectedPlaylist = playlist;
            });
          }),
          switch ((selectedPlaylist?.id, selectedPlaylist?.snippet?.title)) {
            (String id, String title) =>
              PlaylistDetails(playlistId: id, playlistName: title),
            _ => const Center(child: Text('Select a playlist')),
          },
        ],
      ),
    );
  }
}
