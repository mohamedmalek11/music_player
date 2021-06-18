import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';

// ignore: must_be_immutable
class MusicPlayer extends StatefulWidget {
  SongInfo songInfo;
  Function changeTrack;
  final GlobalKey<MusicPlayerState> key;
  MusicPlayer({this.songInfo, this.changeTrack, this.key}) : super(key: key);

  @override
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {
  double minimumValue = 0, maximumValue = 0, currentValue = 0;
  String currentTime = "", endTime = "";
  bool isPlaying = false;

  final AudioPlayer player = AudioPlayer();

  void initState() {
    super.initState();
    setSong(widget.songInfo);
  }

  void dispose() {
    super.dispose();
    player?.dispose();
  }

  void changeStatus() {
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying) {
      player.play();
    } else {
      player.pause();
    }
  }

  void setSong(SongInfo songInfo) async {
    widget.songInfo = songInfo;
    await player.setUrl(widget.songInfo.uri);
    currentValue = minimumValue;
    maximumValue = player.duration.inMilliseconds.toDouble();
    // setting time
    setState(() {
      currentTime = getDuration(currentValue);
      endTime = getDuration(maximumValue);
    });
    isPlaying = false;
    changeStatus();
    player.positionStream.listen((duration) {
      currentValue = duration.inMilliseconds.toDouble();
      if (currentValue >= maximumValue) {
        widget.changeTrack(true);
      }
      setState(() {
        currentTime = getDuration(currentValue);
      });
    });
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());
    return [duration.inMinutes, duration.inSeconds]
        .map((element) => element.remainder(60).toString().padLeft(2, '0'))
        .join(":");
  }

  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            'Now Playing',
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                backgroundImage: widget.songInfo.albumArtwork == null
                    ? AssetImage("assets/images/music.png")
                    : FileImage(File(widget.songInfo.albumArtwork)),
                radius: 150,
              ),
              Container(
                  margin:
                      EdgeInsets.only(top: 15, bottom: 10, left: 10, right: 10),
                  child: Text(
                    widget.songInfo.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  )),
              Container(
                  margin:
                      EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
                  child: Text(
                    widget.songInfo.artist,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  )),
              Slider(
                min: minimumValue,
                max: maximumValue,
                value: currentValue,
                onChanged: (value) {
                  currentValue = value;
                  print(value);
                  player.seek(Duration(milliseconds: currentValue.round()));
                },
                inactiveColor: Colors.grey[400],
                activeColor: Colors.black,
              ),
              Container(
                transform: Matrix4.translationValues(0, -7, 0),
                margin: EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentTime,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      endTime,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.skip_previous,
                        color: Colors.black,
                        size: 55,
                      ),
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        widget.changeTrack(false);
                      },
                    ),
                    GestureDetector(
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                        size: 75,
                      ),
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        changeStatus();
                      },
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.skip_next,
                        color: Colors.black,
                        size: 55,
                      ),
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        widget.changeTrack(true);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
