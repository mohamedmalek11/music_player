import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

import 'music_player.dart';

class Tracks extends StatefulWidget {
  @override
  TracksState createState() => TracksState();
}

class TracksState extends State<Tracks> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  List<SongInfo> songs = [];
  int currentIndex = 0;
  final GlobalKey<MusicPlayerState> key = GlobalKey<MusicPlayerState>();
  void getTracks() async {
    songs = await audioQuery.getSongs();
    setState(() {
      songs = songs;
    });
  }

  void changeTrack(bool isNext) {
    if (isNext) {
      if (currentIndex != songs.length - 1) {
        currentIndex++;
      }
    } else {
      if (currentIndex != 0) {
        currentIndex--;
      }
    }
    key.currentState.setSong(songs[currentIndex]);
  }

  void initState() {
    super.initState();
    getTracks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Music app",
          style: TextStyle(color: Colors.black),
        ),
        leading: Icon(
          Icons.music_note,
          color: Colors.black,
        ),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: songs.length,
        itemBuilder: (context, index) => ListTile(
          leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              backgroundImage: songs[index].albumArtwork == null
                  ? AssetImage("assets/images/music.png")
                  : FileImage(File(songs[index].albumArtwork))),
          title: Text(songs[index].title),
          subtitle: Text(songs[index].artist),
          onTap: () {
            currentIndex = index;
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MusicPlayer(
                      changeTrack: changeTrack,
                      songInfo: songs[currentIndex],
                      key: key
                    )));
          },
        ),
      ),
    );
  }
}
