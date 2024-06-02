import 'dart:io' show File, Platform;
import 'dart:math';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:headset_connection_event/headset_event.dart';
import 'package:just_audio/just_audio.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/Assets.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/localStorage.dart';
import 'package:titosapp/widgets/Loader.dart';
import 'package:titosapp/widgets/OtpTimer.dart';
import 'package:wakelock/wakelock.dart';

import '../../main.dart';
import '../DanceChallenge.dart';
import '../SingingChallenge.dart';
import 'VideoView.dart';

//List<CameraDescription> cameras=[];

class VideoRecording extends StatefulWidget {
  int? category;
  String stageName;

  VideoRecording({this.category, required this.stageName});

  @override
  VideoRecordingState createState() => new VideoRecordingState();
}

late AudioHandler _audioHandler;

class VideoRecordingState extends State<VideoRecording>
    with TickerProviderStateMixin {
  AudioPlayer player = AudioPlayer();
  late CameraController _cameraController = CameraController(
    cameras[cameras.length - 1],
    ResolutionPreset.medium,
    enableAudio: true,
    imageFormatGroup: ImageFormatGroup.jpeg,
  );
  Future<void>? cameraValue;
  bool isRecoring = false;
  bool flash = false;
  bool iscamerafront = true, musicLoaded = false;
  double transform = 0;
  int time = 120;
  late int totalTimeInSeconds;
  late AnimationController _controller;
  late Animation<double> animation;
  late AnimationController expandController;
  int videoLength = 0;
  double mirror = 0;
  var localStorage = new LocalHiveStorage();
  String url = "";
  final _headsetPlugin = HeadsetEvent();
  HeadsetState? _headsetState;

  startPlayer() async {
    url = await localStorage.getValue("musicUrl");
    await player.setUrl(url);
    player.play();
    player.stop();
    setState(() {
      musicLoaded = true;
    });
    try {
      /*  cameras = await availableCameras();
      _audioHandler = await AudioService.init(
        builder: () => AudioPlayerHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.titos.titosmusic.channel.audio',
          androidNotificationChannelName: 'Audio playback',
          androidNotificationOngoing: true,
        ),
      ); */
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    startPlayer();
    super.initState();

    /// if headset is plugged
    _headsetPlugin.getCurrentState.then((_val) {
      setState(() {
        _headsetState = _val;
      });
    });

    /// Detect the moment headset is plugged or unplugged
    _headsetPlugin.setListener((_val) {
      setState(() {
        _headsetState = _val;
      });
    });
    if (Platform.isIOS) {
      _cameraController = CameraController(
        cameras[cameras.length - 1],
        ResolutionPreset.medium,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.bgra8888,
      );
    } else {
      _cameraController = CameraController(
        cameras[cameras.length - 1],
        ResolutionPreset.medium,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
    }
    cameraValue = _cameraController.initialize();

    totalTimeInSeconds = time;
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: time))
          ..addStatusListener((status) {
            if (status == AnimationStatus.dismissed) {
              player.stop();
              endRecording();
            }
          });
  }

  Future<Null> _startCountdown() async {
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
    setState(() {
      totalTimeInSeconds = time;
    });
    _controller.reverse(
        from: _controller.value == 0.0 ? 1.0 : _controller.value);
  }

  void prepareAnimations() {
    expandController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  endRecording() async {
    Duration duration = _controller.duration! * _controller.value;
    XFile videopath = await _cameraController.stopVideoRecording();

    _cameraController.setFlashMode(FlashMode.off);
    setState(() {
      flash = !flash;
      isRecoring = false;
    });
    final file = File(videopath.path);
    Uint8List bytes = file.readAsBytesSync();

    int sizeInBytes = file.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);

    String size = sizeInMb.toStringAsFixed(2);

    int videLength = 60 - duration.inSeconds;

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (builder) => VideoViewPage(
                stageName: widget.stageName,
                path: videopath.path,
                category: widget.category,
                file: file,
                size: size,
                videLength: videLength)));
  }

  @override
  void dispose() {
    _controller.dispose();
    _cameraController.dispose();
    //if(expandController.isAnimating)
    //expandController.dispose();
    player.dispose();
    super.dispose();
  }

  // Future<bool> onWillPop() async {
  //   _controller.dispose();
  //   _cameraController.dispose();
  //   // expandController.dispose();
  //   //player.dispose();
  //   Navigator.of(context).pushAndRemoveUntil(
  //       MaterialPageRoute(
  //           builder: (context) => StartRecording(
  //                 category: widget.category,
  //               )),
  //       (Route<dynamic> route) => false);
  //   return true;
  // }

  @override
  Widget build(BuildContext context) {
    //  print("ratio:"+ _cameraController.value.aspectRatio.toString());
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            FutureBuilder(
                future: cameraValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: AspectRatio(
                          aspectRatio: _cameraController.value.aspectRatio,
                          child: CameraPreview(_cameraController),
                        ));
                  } else {
                    return Center(
                      child: Loader(
                        text: "",
                      ),
                    );
                  }
                }),
            Positioned(
              bottom: 0.0,
              child: Container(
                color: isRecoring ? Colors.transparent : Colors.black,
                padding: EdgeInsets.only(top: 5, bottom: 5),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    musicLoaded
                        ? Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Visibility(
                                child: IconButton(
                                    icon: Icon(
                                      flash ? Icons.flash_on : Icons.flash_off,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        flash = !flash;
                                      });
                                      flash
                                          ? _cameraController
                                              .setFlashMode(FlashMode.torch)
                                          : _cameraController
                                              .setFlashMode(FlashMode.off);
                                    }),
                                visible: !isRecoring,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (!isRecoring) {
                                    if (widget.category == 1) {
                                      print("Status: ${this._headsetState}");
                                      if (this._headsetState != null) {
                                        _headsetPlugin.getCurrentState
                                            .then((_val) {
                                          setState(() {
                                            _headsetState = _val;
                                          });
                                        });
                                        if (this._headsetState ==
                                            HeadsetState.CONNECT) {
                                          if (_cameraController
                                              .value.isInitialized)
                                            await _cameraController
                                                .startVideoRecording()
                                                .then((value) => {
                                                      setState(() {
                                                        Wakelock.enable();
                                                      }),
                                                      _startCountdown(),
                                                      prepareAnimations(),
                                                      player.play(),
                                                      setState(() {
                                                        isRecoring = true;
                                                      }),
                                                    });
                                        } else {
                                          _snackBar(
                                              AppString.connect_headphone.tr,
                                              context);
                                        }
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: AppString.connect_headphone.tr,
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.white,
                                            textColor: Colors.black,
                                            fontSize: 16.0);
                                        // snackBar("Please Connect Your Headphones!",context);
                                      }
                                    } else {
                                      if (_cameraController.value.isInitialized)
                                        await _cameraController
                                            .startVideoRecording()
                                            .then((value) => {
                                                  setState(() {
                                                    Wakelock.enable();
                                                  }),
                                                  _startCountdown(),
                                                  prepareAnimations(),
                                                  player.play(),
                                                  setState(() {
                                                    isRecoring = true;
                                                  }),
                                                });
                                    }
                                  } else {
                                    //_audioHandler.stop();
                                    player.stop();

                                    endRecording();
                                  }
                                },
                                child: isRecoring
                                    ? Icon(
                                        Icons.radio_button_on,
                                        color: CustomColor.myCustomYellow,
                                        size: 80,
                                      )
                                    : Icon(
                                        Icons.radio_button_on,
                                        color: Colors.white,
                                        size: 80,
                                      ),
                              ),
                              Visibility(
                                child: IconButton(
                                    icon: Transform.rotate(
                                      angle: transform,
                                      child: Icon(
                                        Icons.flip_camera_ios,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        iscamerafront = !iscamerafront;
                                        transform = transform + pi;
                                      });
                                      int cameraPos = iscamerafront ? 1 : 0;
                                      _cameraController = CameraController(
                                          cameras[cameraPos],
                                          ResolutionPreset.high);
                                      cameraValue =
                                          _cameraController.initialize();
                                    }),
                                visible: !isRecoring,
                              ),
                            ],
                          )
                        : CircularProgressIndicator(
                            color: CustomColor.myCustomYellow,
                          ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          child: IconButton(
                            icon: widget.category == 1
                                ? Image.asset('images/headphones.png',height: 34,width: 34,)
                                : Image.asset(Assets.computerIcon,height: 34,width: 34,),
                            onPressed: () async {
                              player.stop();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => widget.category == 1
                                        ? SingingChallenge(
                                            stageName: widget.stageName,
                                          )
                                        : DanceChallenge(
                                            stageName: widget.stageName,
                                          )),
                              );
                            },
                          ),
                          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        ),
                        Padding(
                          child: isRecoring
                              ? OtpTimer(_controller, 15.0, Colors.white)
                              : Text(
                                  "2:00",
                                  style: new TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                          padding: EdgeInsets.fromLTRB(0, 0, 15, 10),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 14,
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  _snackBar(String? message, BuildContext _context) {
    return Fluttertoast.showToast(
        msg: message.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }
}

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  static final _item = MediaItem(
    id: 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
    album: "Science Friday",
    title: "A Salute To Head-Scratching Science",
    artist: "Science Friday and WNYC Studios",
    duration: const Duration(milliseconds: 5739820),
    artUri: Uri.parse(
        'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
  );

  final _player = AudioPlayer();

  /// Initialise our audio handler.
  AudioPlayerHandler() {
    // So that our clients (the Flutter UI and the system notification) know
    // what state to display, here we set up our audio handler to broadcast all
    // playback state changes as they happen via playbackState...
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    // ... and also the current media item via mediaItem.
    mediaItem.add(_item);

    // Load the player.
    _player.setAudioSource(AudioSource.uri(Uri.parse(_item.id)));
  }

  // In this simple example, we handle only 4 actions: play, pause, seek and
  // stop. Any button press from the Flutter UI, notification, lock screen or
  // headset will be routed through to these 4 methods so that you can handle
  // your audio playback logic in one place.

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  /// Transform a just_audio event into an audio_service state.
  ///
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
