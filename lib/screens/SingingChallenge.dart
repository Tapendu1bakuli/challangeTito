import 'dart:io' show Platform, exit;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:headset_connection_event/headset_event.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:titosapp/apiService/AuthServices.dart';
import 'package:titosapp/apiService/MediaServices.dart';
import 'package:titosapp/screens/video/VideoRecording.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/LocalNotification.dart';
import 'package:titosapp/util/TextStyles.dart';
import 'package:titosapp/util/localStorage.dart';
import 'package:titosapp/widgets/AudioWave.dart';
import 'package:titosapp/widgets/CircledText.dart';
import 'package:titosapp/widgets/CustomTextField.dart';
import 'package:titosapp/widgets/Loader.dart';

import '../Store/ShareStore.dart';
import '../util/utils.dart';

class SingingChallenge extends StatefulWidget {
  final String? stageName;

  SingingChallenge({this.stageName});

  @override
  SingingChallengeState createState() => new SingingChallengeState();
}

class SingingChallengeState extends State<SingingChallenge>
    with WidgetsBindingObserver {
  final player = AudioPlayer();
  PermissionStatus _cameraPermission = PermissionStatus.denied,
      _microphonePermission = PermissionStatus.denied,
      _storagePermission = PermissionStatus.denied;
  var localStorage = new LocalHiveStorage();
  final _headsetPlugin = HeadsetEvent();
  HeadsetState? _headsetState;

  bool isPlaying = false, musicAdded = false;

  DateTime? backbuttonpressedTime;
  MediaService service = new MediaService();
  AuthService authservice = new AuthService();
  bool isLoading = false, isBackground = false;
  String musicUrl = "", beatName = "Beat Name";
  Duration? duration, _remaining;
  Stream<LocalNotification>? _notificationsStream;
  int videoType = 0;
  var token = '';
  TextEditingController stageNameTextController = TextEditingController();

  @override
  void initState() {
    stageNameTextController.text = widget.stageName ?? "";
    isBackground = true;
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream!.listen((notification) {
      if (notification.type == "new") {
        getMusicTrack();
      }
    });

    getMusicTrack();
    _headsetPlugin.getCurrentState.then((_val) {
      setState(() {
        _headsetState = _val;
      });
    });

    _headsetPlugin.setListener((_val) {
      setState(() {
        _headsetState = _val;
      });
    });
    ShareStore().saveContext(object: context);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    isPlaying = false;
    super.dispose();
    player.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    player.pause();
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      isBackground = false;
    }

    isBackground = state == AppLifecycleState.resumed;

    if (isBackground) {
      if (mounted) getMusicTrack();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: SafeArea(
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  leading: IconButton(
                    icon: new Icon(
                      Icons.arrow_back_ios,
                      color: CustomColor.myCustomYellow,
                    ),
                    onPressed: () {
                      NotificationsBloc.instance
                          .newNotification(LocalNotification("new"));
                      Navigator.of(context).pop();
                    },
                  ),
                  backgroundColor: Colors.black,
                  centerTitle: true,
                  title: Text(
                    AppString.singChallenge.tr.toUpperCase(),
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
                ),
                body: GestureDetector(
                  onTap: (){
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                  },
                  child: Stack(children: [
                    Column(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Container(
                            color: CustomColor.customGrey,
                            child: Align(
                                alignment: Alignment.center,
                                child: (isPlaying)
                                    ? CustomAudioWave(
                                        animation: isPlaying,
                                        context: context,
                                      )
                                    : StoppedAudioWave(
                                        context: context,
                                      )),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            alignment: Alignment.center,
                            color: CustomColor.white,
                            child: IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  StreamBuilder<PlayerState>(
                                    stream: player.playerStateStream,
                                    builder: (context, snapshot) {
                                      final playerState = snapshot.data;
                                      final processingState =
                                          playerState?.processingState;
                                      final playing = playerState?.playing;
                                      if (processingState ==
                                              ProcessingState.loading ||
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
                                  VerticalDivider(
                                    thickness: 1,
                                    width: 1,
                                    color: Color(0xFF959595),
                                  ),
                                  // isPlaying
                                  //     ? CustomVisibility(
                                  //         child: IconButton(
                                  //           icon: isPlaying
                                  //               ? Icon(Icons.pause)
                                  //               : Icon(Icons.play_arrow),
                                  //           onPressed: () async {
                                  //             if (isPlaying)
                                  //               await player.pause();
                                  //             else {
                                  //               if (player.processingState ==
                                  //                   ProcessingState.completed) {
                                  //                 print(isPlaying);
                                  //                 player.seek(Duration.zero);
                                  //               } else {
                                  //                 print(player.processingState);
                                  //                 player.play();
                                  //               }
                                  //             }

                                  //             setState(() {
                                  //               isPlaying = !isPlaying;
                                  //             });
                                  //           },
                                  //           iconSize: 40,
                                  //         ),
                                  //         visibility: VisibilityFlag.invisible)
                                  //     : Offstage(),
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
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 5,
                            child: Container(
                              width: double.maxFinite,
                              padding: EdgeInsets.all(20),
                              color: CustomColor.customGrey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppString.beat.tr,
                                        style: TextStyles.textStyleRegular,
                                      ),
                                      Expanded(
                                        child: Text(
                                          beatName.tr,
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyles.textStyleRegular,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    AppString.stageName.tr,
                                    style: TextStyles.textStyleRegular,
                                  ),
                                  SizedBox(height: 12),
                                  CustomTextField(
                                    fillColor: Colors.white,
                                    suffixIcon: Opacity(opacity: 0),
                                    textController: stageNameTextController,
                                    focusNode: FocusNode(),
                                  )
                                ],
                              ),
                            )),
                        Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.center,
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 4),
                              child: Text(
                                AppString.onlyOneVideo.tr,
                                textAlign: TextAlign.left,
                                style: TextStyles.textStyleRegular,
                                // overflow: TextOverflow.ellipsis,
                              ),
                            )),
                        Expanded(
                          flex: 4,
                          child: Container(
                            color: Colors.black,
                            child: Align(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () async {
                                    final snackBar = SnackBar(
                                      content: Text(AppString.enterStageName.tr),
                                    );
                                    if (stageNameTextController.text
                                        .trim()
                                        .isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                      return;
                                    } else {
                                      if (_microphonePermission.isGranted &&
                                          _storagePermission.isGranted &&
                                          _cameraPermission.isGranted) {
                                        if (this._headsetState != null) {
                                          _headsetPlugin.getCurrentState
                                              .then((_val) {
                                            setState(() {
                                              _headsetState = _val;
                                            });
                                          });
                                          if (this._headsetState ==
                                              HeadsetState.CONNECT) {
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
                                        requestCameraPermission();
                                      }
                                      setState(() {
                                        isPlaying = false;
                                      });
                                      await player.stop();
                                      ScaffoldMessenger.of(context)
                                          .clearSnackBars();
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VideoRecording(
                                                category: 1,
                                                stageName:
                                                    stageNameTextController.text),
                                          ));
                                    }
                                  },
                                  child: CircledText(
                                    context: context,
                                    color: CustomColor.myCustomYellow,
                                    text: AppString.start.tr,
                                  ),
                                )),
                          ),
                        )
                      ],
                    ),
                    Visibility(
                      child: Loader(),
                      visible: isLoading,
                    )
                  ]),
                ))),
        onWillPop: onWillPop);
  }

  _startPlayer(String url) async {
    try {
      //  duration = await player.setUrl(url);
      //  await player.setLoopMode(LoopMode.off);

      player.playbackEventStream.listen((event) {
        var dur = event.duration;
        var pos = event.processingState;

        if (pos == ProcessingState.completed) {
          // player.stop();
          setState(() {
            isPlaying = false;
          });
        }
      }, onError: (Object e, StackTrace stackTrace) {
        print('A stream error occurred: $e');
      });
      await player.setAudioSource(AudioSource.uri(Uri.parse(url)));

      musicAdded = true;

      print(duration);
    } catch (e) {
      print(e.toString());
    }
  }

  String accesstoken = "";

  getMusicTrack() async {
    setState(() {
      isLoading = true;
    });
    var parsed = await service.getMusicTrack();

    if (parsed != null) {
      musicUrl = parsed["musicPath"] ??
          "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3";
      localStorage.storeMusic(musicUrl, parsed["musicId"].toString(),
          parsed["musicName"].toString(), parsed["youtubeChannelLink"]);

      videoType = parsed["videoType"] ?? 0;
      await _startPlayer(musicUrl);
      if(mounted){
        setState(() {
          beatName = parsed["musicName"] ?? "Beat Name".tr;
          isLoading = false;
        });
      }
    }
  }

  Future<bool> onWillPop() async {
    DateTime currentTime = DateTime.now();

    bool backButton = backbuttonpressedTime == null ||
        currentTime.difference(backbuttonpressedTime!) > Duration(seconds: 3);

    if (backButton) {
      backbuttonpressedTime = currentTime;
      Fluttertoast.showToast(
          msg: AppString.exitApp.tr,
          backgroundColor: Colors.black,
          textColor: Colors.white);
      return false;
    }
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
    return true;
  }

  Future<void> requestCameraPermission() async {
    var cameraStatus = await Permission.camera.request();
    var microphoneStatus = await Permission.microphone.request();
    var storageStatus = await Permission.storage.request();
    setState(() {
      _cameraPermission = cameraStatus;
      _microphonePermission = microphoneStatus;
      _storagePermission = storageStatus;
    });
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
