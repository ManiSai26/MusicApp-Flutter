import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicPlayerComponent extends StatefulWidget {
  final String url;
  final String title;
  final Function nextSong;

  const MusicPlayerComponent(
      {super.key,
      required this.url,
      required this.title,
      required this.nextSong});

  @override
  _MusicPlayerComponentState createState() => _MusicPlayerComponentState();
}

class _MusicPlayerComponentState extends State<MusicPlayerComponent> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = true;
      });
      widget.nextSong();
    });
  }

  @override
  void didUpdateWidget(covariant MusicPlayerComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _playNewSong();
    }
  }

  void _playNewSong() {
    _audioPlayer.stop();
    _audioPlayer.play(UrlSource(widget.url.split('?mp3').first));
    setState(() {
      isPlaying = true;
    });
  }

  @override
  void dispose() {
    _audioPlayer.release();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      print(widget.url.split('?mp3').first);
      _audioPlayer.play(UrlSource(widget.url.split('?mp3').first));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: _togglePlayPause,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                widget.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
            IconButton(
                onPressed: () {
                  widget.nextSong();
                },
                icon: Icon(Icons.skip_next_rounded))
          ],
        ),
      ),
    );
  }
}
