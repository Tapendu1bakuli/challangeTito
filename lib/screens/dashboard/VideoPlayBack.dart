import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/apiService/MediaServices.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/localStorage.dart';
import 'package:titosapp/widgets/Loader.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import '../../Service/GlobalKeys.dart';

class VideoPlayBack extends StatefulWidget {
  VideoPlayBack({Key? key, this.VideoPath, this.beatname}) : super(key: key);

  String? VideoPath;
  String? beatname;

  @override
  _VideoPlayBackState createState() => _VideoPlayBackState();
}

class _VideoPlayBackState extends State<VideoPlayBack> {
  var localStorage = LocalHiveStorage();
  String? musicId, UserId;
  MediaService service = new MediaService();
  bool isLoading = false;
  VideoPlayerController? _controller;
  Directory? dir;
  bool downloading = false;
  var progressString = "";
  bool isloaded = false;

  @override
  void initState() {
    super.initState();
    downloadFile();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  downloadFile() async {
    setState(() {
      isloaded = true;
      downloading = true;
      progressString = "Completed";
    });
    print("Download completed");

    _controller = VideoPlayerController.network(
        GlobalKeys.streamVideoBaseUrl + widget.VideoPath.toString())
      ..initialize().then((_) {
        _controller!.addListener(() {
          //custom Listner
          setState(() {
            if (!_controller!.value.isPlaying &&
                _controller!.value.isInitialized &&
                (_controller!.value.duration == _controller!.value.position)) {
              //checking the duration and position every time
              //Video Completed//

              setState(() {});
            }
          });
        });
        setState(() {});
      });
    _controller!.setLooping(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            AppString.beat.tr + "${widget.beatname}",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
          leading: IconButton(
            icon: new Icon(
              Icons.arrow_back_ios,
              color: CustomColor.myCustomYellow,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          child: Center(
            child: downloading
                ? getVideoPart()
                : Loader(
                    text: "",
                  ),
          ),
          color: CustomColor.myCustomBlack,
        ));
  }

  getVideoPart() {
    if (isloaded) {
      return Stack(
        children: [
          Center(
            child: Container(
              // width: MediaQuery.of(context).size.width,
              //height: MediaQuery.of(context).size.height,
              child: _controller!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : Loader(
                      text: "",
                    ),
            ),
          ),
          Visibility(
            child: Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (_controller!.value.isPlaying) {
                      setState(() {
                        Wakelock.disable();
                        // You could also use Wakelock.toggle(on: true);
                      });
                      // widget.player!.pause();
                      _controller!.pause();
                    } else {
                      setState(() {
                        Wakelock.enable();
                        // You could also use Wakelock.toggle(on: true);
                      });
                      // await  widget.player!.play();
                      _controller!.play();
                    }
                  });
                },
                child: CircleAvatar(
                  radius: 33,
                  backgroundColor: Colors.black38,
                  child: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: CustomColor.myCustomYellow,
                    size: 50,
                  ),
                ),
              ),
            ),
            visible: _controller!.value.isInitialized,
          )
        ],
      );
    } else {
      return Container(
        height: 120.0,
        width: 200.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
              color: CustomColor.myCustomYellow,
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              "Downloading File: $progressString",
              style: TextStyle(
                color: Colors.black,
              ),
            )
          ],
        ),
      );
    }
  }
}
