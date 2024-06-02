import 'package:flutter/material.dart';
import 'package:youtube_player_flutter_quill/youtube_player_flutter_quill.dart';

class CustomYoutubePlayer extends StatefulWidget {
  final String youTubeUrl;

  const CustomYoutubePlayer({Key? key, required this.youTubeUrl})
      : super(key: key);

  @override
  _CustomYoutubePlayerState createState() => _CustomYoutubePlayerState();
}

class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    _controller = YoutubePlayerController(
        initialVideoId: convertUrlToId(widget.youTubeUrl),
        flags: const YoutubePlayerFlags(
          loop: true,
        ));
    super.initState();
    print("youTubeUrl++" + widget.youTubeUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SizedBox(
      height: screenSize.height * 2 / 5,
      width: screenSize.width,
      child: YoutubePlayer(
        controller: _controller,
      ),
    );
  }

  String convertUrlToId(String url, {bool trimWhitespaces = true}) {
    print("url++" + url);
    if (!url.contains("http") && (url.length == 11)) return url;
    if (trimWhitespaces) url = url.trim();

    for (var exp in [
      RegExp(
          r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(
          r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
    ]) {
      Match? match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1)
        return match.group(1).toString();
    }

    return "";
  }
}
