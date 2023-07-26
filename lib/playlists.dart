// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

class Playlists extends StatelessWidget {
  const Playlists({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterDev Playlists'),
      ),
      body: Consumer<FlutterDevPlaylists>(
        builder: (context, flutterDev, child) {
          final playlists = flutterDev.playlists;

          if (playlists.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return _PlaylistsListView(items: playlists);
        },
      ),
    );
  }
}

class _PlaylistsListView extends StatelessWidget {
  final List<Playlist> items;

  const _PlaylistsListView({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final playlist = items[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Image.network(
              playlist.snippet!.thumbnails!.default_!.url!,
            ),
            title: Text(
              playlist.snippet!.title!,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: Text(
              playlist.snippet!.description!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () {
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
      },
    );
  }
}
