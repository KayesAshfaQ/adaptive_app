// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

class Playlists extends StatelessWidget {
  final PlaylistsListSelected playlistSelected;

  const Playlists({super.key, required this.playlistSelected});

  @override
  Widget build(BuildContext context) {
    return Consumer<FlutterDevPlaylists>(
      builder: (context, flutterDev, child) {
        final playlists = flutterDev.playlists;

        if (playlists.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return _PlaylistsListView(
          items: playlists,
          playlistSelected: playlistSelected,
        );
      },
    );
  }
}

typedef PlaylistsListSelected = void Function(Playlist playlist);

class _PlaylistsListView extends StatefulWidget {
  final List<Playlist> items;
  final PlaylistsListSelected playlistSelected;

  const _PlaylistsListView({
    Key? key,
    required this.items,
    required this.playlistSelected,
  }) : super(key: key);

  @override
  State<_PlaylistsListView> createState() => _PlaylistsListViewState();
}

class _PlaylistsListViewState extends State<_PlaylistsListView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final playlist = widget.items[index];
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
              widget.playlistSelected(playlist);
            },
          ),
        );
      },
    );
  }
}
