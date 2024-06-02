import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:headset_connection_event/headset_event.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:titosapp/screens/dashboard/ChooseChallange.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/Assets.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/localStorage.dart';

class StartRecording extends StatefulWidget {
  int? category;

  StartRecording({this.category});

  @override
  StartRecordingState createState() => new StartRecordingState();
}

class StartRecordingState extends State<StartRecording> {
  final player = AudioPlayer();
  PermissionStatus? _cameraPermission,
      _microphonePermission,
      _storagePermission;
  var localStorage = new LocalHiveStorage();
  final _headsetPlugin = HeadsetEvent();
  HeadsetState? _headsetState;
  String musicName = "BEAT Name";

  @override
  void initState() {
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

    startPlayer();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.customGrey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          AppString.beat.tr + musicName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
        leading: IconButton(
          icon: new Icon(
            Icons.arrow_back_ios,
            color: CustomColor.myCustomYellow,
          ),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => ChooseChallenge()),
                (Route<dynamic> route) => false);
            //Navigator.pop(context);
          },
        ),
        actions: [
          (widget.category == 1)
              ? IconButton(
                  icon: Image.asset('images/mic.png'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              : IconButton(
                  icon: Image.asset(
                    'images/danceIcon.png',
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          int count = 2;
          if (orientation == Orientation.landscape) {
            count = 2;
          }
          return Column(
            children: [
              Expanded(
                child: Align(
                  child: Text(
                    AppString.start_Recording.tr,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  alignment: Alignment.center,
                ),
                flex: 5,
              ),
              Expanded(
                child: SafeArea(
                  child: Container(
                    color: Colors.black,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              child: IconButton(
                                icon: widget.category == 1
                                    ? Image.asset('images/headphones.png')
                                    : Image.asset(Assets.computerIcon),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: IconButton(
                              iconSize: 70.0,
                              icon: Icon(
                                Icons.radio_button_on,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _headsetPlugin.getCurrentState.then((_val) {
                                  setState(() {
                                    _headsetState = _val;
                                  });
                                });

                                if (_microphonePermission!.isGranted &&
                                    _storagePermission!.isGranted &&
                                    _cameraPermission!.isGranted) {
                                  if (widget.category == 1) {
                                    if (this._headsetState != null) {
                                      if (this._headsetState ==
                                          HeadsetState.CONNECT) {
                                        // Navigator.of(context)
                                        //     .push(MaterialPageRoute(
                                        //   builder: (context) {
                                        //     return VideoRecording(
                                        //         category: widget
                                        //             .category); //CameraScreen();//
                                        //     //return VideoRecording(category:widget.category,player:player);
                                        //   },
                                        // ));
                                      } else {
                                        snackBar(AppString.connect_headphone.tr,
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
                                    // Navigator.of(context)
                                    //     .push(MaterialPageRoute(
                                    //   builder: (context) {
                                    //     return VideoRecording(
                                    //         category: widget
                                    //             .category); //CameraScreen();//VideoRecording(category:widget.category,player:player);
                                    //     // return HomeScreen2(category:widget.category);
                                    //   },
                                    // ));
                                  }
                                } else {
                                  requestCameraPermission();
                                }

                                //  Navigator.pushNamed(context, '/CameraScreen');
                              },
                            ),
                          ),
                          Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                child: Text(
                                  "1:30",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                padding: EdgeInsets.fromLTRB(0, 0, 15, 10),
                              ))
                        ]),
                  ),
                ),
                flex: 2,
              ),
            ],
          );
        },
      ),
    );
  }

  snackBar(String? message, BuildContext _context) {
    return Fluttertoast.showToast(
        msg: message!.tr.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }

  startPlayer() async {
    musicName = await localStorage.getValue("musicName");
    String url = await localStorage.getValue("musicUrl");
    await requestCameraPermission();
    try {
      var duration = await player.setUrl(url);
      //  await player.setLoopMode(LoopMode.all);
      print(duration);
    } catch (e) {
      print(e.toString());
    }
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
}
