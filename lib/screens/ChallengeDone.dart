import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titosapp/Service/GlobalKeys.dart';
import 'package:titosapp/Store/HiveStore.dart';
import 'package:titosapp/apiService/AuthServices.dart';
import 'package:titosapp/apiService/MediaServices.dart';
import 'package:titosapp/model/PositionData.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/LocalNotification.dart';
import 'package:titosapp/util/TextStyles.dart';
import 'package:titosapp/util/localStorage.dart';
import 'package:titosapp/widgets/AudioWave.dart';
import 'package:titosapp/widgets/Loader.dart';
import 'package:titosapp/widgets/Visibility.dart';
import 'package:video_player/video_player.dart';


// ignore: must_be_immutable
class ChallengeDone extends StatefulWidget {
  int? videoType;

  ChallengeDone(this.videoType);

  @override
  ChallengeDoneState createState() => new ChallengeDoneState();
}

class ChallengeDoneState extends State<ChallengeDone>
    with WidgetsBindingObserver {
  final player = AudioPlayer();
  bool isPlaying = false, musicAdded = false;
  var localStorage = new LocalHiveStorage();
  DateTime? backbuttonpressedTime;
  MediaService service = new MediaService();
  AuthService authservice = new AuthService();
  bool isLoading = false, isBackground = false;
  String musicUrl = "", videoPath = "", beatName = "Beat Name";
  VideoPlayerController? _controller;
  Duration? duration, _remaining;
  Stream<LocalNotification>? _notificationsStream;
  int videoType = 0;
  var token = '';

  String date = "";
  HiveStore? prefs;
  String language = "";

  startPlayer(String url) async {
    await requestCameraPermission();
    try {
      player.playbackEventStream.listen((event) {
        var dur = event.duration;
        var pos = event.processingState;
        if (pos == ProcessingState.completed) {
          if (_remaining != null) {
            if (_remaining!.inSeconds == 0) {
              // player.stop();
              setState(() {
                isPlaying = false;
              });
            }
          }
        }
      }, onError: (Object e, StackTrace stackTrace) {
        print('A stream error occurred: $e');
      });
      await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      musicAdded = true;
    } catch (e) {
      print(e.toString());
    }
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          player.positionStream,
          player.bufferedPositionStream,
          player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  Future<void> requestCameraPermission2() async {
    await Permission.camera.request();
  }

  Future<void> requestCameraPermission() async {
    requestCameraPermission2();
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.storage.request();
    setState(() {});
  }

  @override
  void initState() {
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream!.listen((notification) {
      if (notification.type == "new") {
        getMusicTrack();
      }
    });
    _controller = VideoPlayerController.network("");

    getMusicTrack();
    _getPref();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    isPlaying = false;
    player.pause();
    _controller!.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      player.pause();
      isPlaying = false;
      isBackground = true;
    }
    if (state == AppLifecycleState.resumed) {
      isBackground = false;
    }
    setState(() {});
  }

  initializeVideoPlayer() async {
    if (videoPath.isNotEmpty) {
      _controller = VideoPlayerController.network(
          GlobalKeys.streamVideoBaseUrl + videoPath)
        ..initialize().then((_) {
          _controller!.addListener(() {
            //custom Listner
            setState(() {
              if (!_controller!.value.isPlaying &&
                  _controller!.value.isInitialized &&
                  (_controller!.value.duration ==
                      _controller!.value.position)) {
                setState(() {});
              }
            });
          });
          setState(() {});
        });
      _controller!.setLooping(false);
    }
  }

  getMusicTrack() async {
    setState(() {
      isLoading = true;
    });
    var parsed = widget.videoType == 1
        ? await service.getMusicTrack()
        : await service.getVideoTrack();

    if (parsed != null) {
      musicUrl = parsed["musicPath"] ??
          "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3";
      videoPath = parsed["videoUrl"] ?? "";
      await startPlayer(musicUrl);
      //initializeVideoPlayer();
      setState(() {
        date = parsed["video_created_at"] == null
            ? ""
            : parsed["video_created_at"];
        beatName = parsed["musicName"] ?? "Beat Name".tr;
        isLoading = false;
      });
    }
  }

  _buildThankYouNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Text(
        language == "한국어"
            ? '''$date 에 퍼포먼스 비디오를 제출해 주셔서 감사합니다. 다음 랩 챌린지 비트가 올라오면 알림을 받게 됩니다\n친구들에게 제출한 비디오 투표를 권유해보세요.'''
            : language == "FRANÇAIS"
                ? '''Nous vous remercions d’avoir soumis votre vidéo le $date. Vous serez avisé(e) lorsque le beat du prochain challenge de danse sera diffusé. En attendant, invitez vos amis à voter pour votre vidéo.'''
                : '''${AppString.videoPerformance} $date. ${AppString.notifiedNext} ${widget.videoType == 1 ? "Rap" : "Dance"} ${AppString.challengePosted}.
\n${AppString.meanwhile}.''',
        style: TextStyles.textStyleSemiBold,
      ),
    );
    /*if (VideoPath.isNotEmpty) {
      return Align(
          alignment: Alignment.center,
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                //width: MediaQuery.of(context).size.width,
                child: _controller!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: 2 / 3,
                        child: VideoPlayer(_controller!),
                      )
                    : Container(),
              ),
              Align(
                alignment: Alignment.center,
                child: _controller!.value.isInitialized
                    ? InkWell(
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VideoPlayBack(
                                        beatname: beatName,
                                        VideoPath: VideoPath,
                                      )));
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
                      )
                    : CircularProgressIndicator(
                        color: CustomColor.myCustomYellow,
                      ),
              ),
            ],
          ));
    } else
      return Container();*/
  }

  String get timerString {
    Duration duration = _remaining ?? Duration(seconds: 0);
    if (duration.inHours > 0) {
      return '${duration.inHours}:${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              centerTitle: true,
              title: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  AppString.beat.tr.toUpperCase() + beatName.tr,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: CustomColor.myCustomYellow,
                ),
                onPressed: () {
                  NotificationsBloc.instance
                      .newNotification(LocalNotification("new"));
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: Stack(children: [
              Column(
                children: [
                  Expanded(
                    child: Container(
                      color: CustomColor.customGrey,
                      child: Align(
                          alignment: Alignment.center,
                          child: isPlaying
                              ? CustomAudioWave(
                                  animation: isPlaying,
                                  context: context,
                                )
                              : StoppedAudioWave(
                                  context: context,
                                )),
                    ),
                    flex: 5,
                  ),
                  Expanded(
                    child: Container(
                      color: CustomColor.customGrey,
                      child: Row(
                        children: [
                          StreamBuilder<PlayerState>(
                            stream: player.playerStateStream,
                            builder: (context, snapshot) {
                              final playerState = snapshot.data;
                              final processingState =
                                  playerState?.processingState;
                              final playing = playerState?.playing;
                              if (processingState == ProcessingState.loading ||
                                  processingState ==
                                      ProcessingState.buffering) {
                                return Container(
                                  margin: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                );
                              } else if (playing != true) {
                                return IconButton(
                                  icon: Icon(Icons.play_arrow),
                                  iconSize: 40.0,
                                  onPressed: () {
                                    player.play();
                                    setState(() {
                                      isPlaying = true;
                                    });
                                  },
                                );
                              } else if (processingState !=
                                  ProcessingState.completed) {
                                return IconButton(
                                  icon: Icon(Icons.pause),
                                  iconSize: 40.0,
                                  onPressed: () {
                                    player.pause();
                                    setState(() {
                                      isPlaying = false;
                                    });
                                  },
                                );
                              } else {
                                return IconButton(
                                  icon: Icon(Icons.replay),
                                  iconSize: 40.0,
                                  onPressed: () async {
                                    await player.seek(Duration.zero);
                                    setState(() {
                                      isPlaying = true;
                                    });
                                  },
                                );
                              }
                            },
                          ),
                          CustomVisibility(
                              child: IconButton(
                                icon: isPlaying
                                    ? Icon(Icons.pause)
                                    : Icon(Icons.play_arrow),
                                onPressed: () async {
                                  if (isPlaying)
                                    await player.pause();
                                  else {
                                    if (player.processingState ==
                                        ProcessingState.completed) {
                                      print(isPlaying);
                                      player.seek(Duration.zero);
                                    } else {
                                      print(player.processingState);
                                      player.play();
                                    }
                                  }

                                  setState(() {
                                    isPlaying = !isPlaying;
                                  });
                                },
                                iconSize: 40,
                              ),
                              visibility: VisibilityFlag.invisible),
                          IconButton(
                            icon: Icon(Icons.stop),
                            onPressed: () async {
                              setState(() {
                                isPlaying = false;
                              });

                              await player.stop();

                              if (musicUrl.isNotEmpty)
                                await player.setUrl(musicUrl);
                            },
                            iconSize: 40,
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      ),
                      padding: EdgeInsets.all(10),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Card(
                      color: Colors.black,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                ),
                                clipBehavior: Clip.hardEdge,
                                width: MediaQuery.of(context).size.width,
                                child: _getAudioTimer()),
                            flex: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: Colors.black,
                      ),
                      child: _buildThankYouNote(),
                    ),
                    flex: 3,
                  ),
                ],
              ),
              Visibility(
                child: Loader(),
                visible: isLoading,
              )
            ])));
  }

  _getAudioTimer() {
    if (musicAdded == true) {
      return Align(
        child: StreamBuilder<PositionData>(
          stream: _positionDataStream,
          builder: (context, snapshot) {
            final positionData = snapshot.data ??
                PositionData(Duration(seconds: 0), Duration(seconds: 0),
                    Duration(seconds: 0));
            _remaining = positionData.duration - positionData.position;
            return Padding(
              child: Text(
                timerString,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              padding: EdgeInsets.fromLTRB(10, 5, 0, 5),
            );
          },
        ),
        alignment: Alignment.centerLeft,
      );
    } else {
      return Container();
    }
  }

  _getPref() {
    setState(() {
      language = HiveStore().get(Keys.language);
    });
  }
}
