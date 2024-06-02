import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:titosapp/model/winners/WinnersModel.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class WinnersVideoPlayBack extends StatefulWidget {
  WinnersVideoPlayBack(
      {Key? key,
      this.videoPath,
      this.beatname,
      this.artistName,
      required this.model,
      this.index})
      : super(key: key);
  final WinnersModelList model;
  final String? videoPath;
  final String? beatname;
  final String? artistName;
  final int? index;

  @override
  _WinnersVideoPlayBackState createState() => _WinnersVideoPlayBackState();
}

class _WinnersVideoPlayBackState extends State<WinnersVideoPlayBack>
    with WidgetsBindingObserver {
  WinnersModel winnerList = WinnersModel(votingVideoList: <WinnersModelList>[]);

  bool isLoading = false;
  bool _isPlaying = false;
  VideoPlayerController? _controller = VideoPlayerController.network("");
  Directory? dir;
  var progressString = "";
  bool isloaded = false;
  bool onInit = false;
  bool _isDisposed = false;
  WinnersModel _listWinners = WinnersModel(votingVideoList: []);

  @override
  void initState() {
    onInit = true;
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _initializeVideo(0);

    // downloadFile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isDisposed = true;
    super.dispose();
    if (!mounted) _controller!.pause();
    _controller!.removeListener(() {
      setState(() {});
    });
    _controller!.dispose();
  }

  @override
  void deactivate() {
    print("deactivate");
    if (!mounted) _controller!.pause();
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) _controller!.pause();
    _isPlaying = false;
    switch (state) {
      case AppLifecycleState.inactive:
        print('appLifeCycleState inactive');
        break;
      case AppLifecycleState.resumed:
        print('appLifeCycleState resumed');
        break;
      case AppLifecycleState.paused:
        print('appLifeCycleState paused');
        break;
      case AppLifecycleState.detached:
        print('appLifeCycleState suspending');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Text(
              AppString.beat.tr + "${widget.beatname}",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(35),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  widget.artistName!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.textStyleSemiBold,
                ),
              )),
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
        body: SafeArea(
          child: Container(
            child: Center(child: getVideoPart()),
            color: CustomColor.myCustomBlack,
          ),
        ));
  }

  getVideoPart() {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        _playView(context),
        Visibility(
          child: Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: () {
                if (_controller!.value.isPlaying) {
                  setState(() {
                    _controller!.pause();
                    _isPlaying = false;
                    Wakelock.disable();
                  });
                } else {
                  setState(() {
                    _controller!.play();
                    _isPlaying = true;
                    Wakelock.enable();
                  });
                }
              },
              child: CircleAvatar(
                radius: 33,
                backgroundColor: _controller!.value.isPlaying
                    ? Colors.transparent
                    : Colors.black38,
                child: _controller!.value.isPlaying
                    ? _controller!.value.isBuffering
                        ? CircularProgressIndicator(
                            color: CustomColor.colorYellow,
                          )
                        : Offstage()
                    : Icon(
                        Icons.play_arrow,
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
  }

  Widget _playView(BuildContext context) {
    if (_controller!.value.isInitialized) {
      return GestureDetector(
        onTap: () {
          if (_controller!.value.isPlaying) {
            setState(() {
              _controller!.pause();
              _isPlaying = false;
              Wakelock.disable();
            });
          }
        },
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VideoPlayer(_controller!),
              VideoProgressIndicator(_controller!, allowScrubbing: true),
              Positioned(bottom: 30,left: 20,child: Text("${AppString.tos} : ${widget.model.tos}",style: TextStyles.textStyleSemiBold,)),
            ],
          ),
        ),
      );
    } else {
      return AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
              color: CustomColor.secondarycolro,
              child: Center(
                  child: CircularProgressIndicator(
                color: CustomColor.colorYellow,
              ))));
    }
  }

  void saveWinnersVideo(element) async {
    String dirLoc = (await getApplicationDocumentsDirectory()).path;
    await downloadFile(element.path, element.uniqueName, dirLoc, element);
  }

  Future<String> downloadFile(
      String url, String fileName, String dir, element) async {
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = '';

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '$dir/$fileName';
        file = File(filePath);
        await file.writeAsBytes(bytes);
      } else
        filePath = 'Error code: ' + response.statusCode.toString();
    } catch (ex) {
      filePath = 'Can not fetch url';
    }
    print("FilePath : $filePath");
    element.savedVideoLocation = filePath;
    return filePath;
  }

  _initializeVideo(int index) async {
    if (_controller!.value.isInitialized) {
      _controller!.pause();
      _controller!.dispose();
    }
    _controller = VideoPlayerController.network("");

    _initWinnersController();
  }

  void _initWinnersController() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File('$dir/${widget.model.uniqueName}');
    print("File Exist: ${await file.exists()}");
    if (await file.exists()) {
      setState(() {
        _controller = VideoPlayerController.file(
          file,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      });
    } else {
      saveWinnersVideo(widget.model);
      setState(() {
        _controller = VideoPlayerController.network(
          widget.videoPath!,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      });
    }
    _controller!.addListener(() {
      setState(() {});
    });
    _controller!.setLooping(false);
    _controller!.initialize().then((_) => setState(() {
          if (onInit) {
            _controller!.pause();
            onInit = false;
          } else {
            _controller!.play();
          }
          Wakelock.enable();
        }));
  }
}
