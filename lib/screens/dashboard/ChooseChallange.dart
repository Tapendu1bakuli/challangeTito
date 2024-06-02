import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/apiService/MediaServices.dart';
import 'package:titosapp/screens/ChallengeDone.dart';
import 'package:titosapp/screens/DanceChallenge.dart';
import 'package:titosapp/screens/SingingChallenge.dart';
import 'package:titosapp/screens/dashboard/HomeScreen.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/LocalNotification.dart';
import 'package:titosapp/util/TextStyles.dart';
import 'package:titosapp/util/localStorage.dart';
import 'package:titosapp/widgets/Loader.dart';

class ChooseChallenge extends StatefulWidget {
  int? category;

  @override
  ChooseChallengeState createState() => new ChooseChallengeState();
}

class ChooseChallengeState extends State<ChooseChallenge>
    with WidgetsBindingObserver {
  bool isLoading = false, isBackground = false;
  String musicName = "BEAT Name";
  var localStorage = LocalHiveStorage();
  Stream<LocalNotification>? _notificationsStream;
  String musicUrl = "";
  int videoType = 0, videoTypeDance = 0;
  MediaService service = new MediaService();

  @override
  void initState() {
    isBackground = true;
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream!.listen((notification) {
      if (notification.type == "new") {
        _getMusicTrack();
        _getVideoTrack();
      }
    });

    _getMusicTrack();
    _getVideoTrack();

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      isBackground = false;
    }

    isBackground = state == AppLifecycleState.resumed;

    if (isBackground) {
      if (mounted) _getMusicTrack();
      if (mounted) _getVideoTrack();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.customGrey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(AppString.challenge.tr,
            // AppString.beat + beatName,
            style: TextStyles.textStyleSemiBold
                .apply(fontSizeFactor: 1.34, color: Colors.white)
            // TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
        iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
        leading: IconButton(
          icon: new Icon(
            Icons.arrow_back_ios,
            color: CustomColor.myCustomYellow,
          ),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => HomeScreen()),
                (Route<dynamic> route) => false);
          },
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 6.5,
        child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            // icon: Image.asset('images/headphones.png'),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                  (Route<dynamic> route) => false);
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          OrientationBuilder(
            builder: (context, orientation) {
              int count = 2;
              if (orientation == Orientation.landscape) {
                count = 2;
              }
              return Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(AppString.choose_Challenge.tr,
                          textAlign: TextAlign.center,
                          style: TextStyles.textStyleSemiBold
                              .apply(color: Colors.black, fontSizeFactor: 1.2)),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: GridView.count(
                      physics: ClampingScrollPhysics(),
                      crossAxisCount: count,
                      children: <Widget>[
                        Container(
                          color: Colors.black,
                          child: Align(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => videoType == 1
                                            ? ChallengeDone(videoType)
                                            : SingingChallenge()
                                        // StartRecording(category: 1),
                                        ));
                              },
                              child: Text(AppString.sing_on_beat.tr,
                                  style: TextStyles.textStyleBold.apply(
                                      fontSizeFactor: 1.2,
                                      color: Colors.white)),
                            ),
                            alignment: Alignment.center,
                          ),
                        ),
                        Container(
                          color: CustomColor.customGrey,
                        ),
                        Container(
                          color: CustomColor.customGrey,
                        ),
                        Container(
                          color: CustomColor.myCustomYellow,
                          child: Align(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            videoTypeDance == 2
                                                ? ChallengeDone(videoTypeDance)
                                                : DanceChallenge()

                                        // StartRecording(category: 2),
                                        ));
                              },
                              child: Text(AppString.dance_to_beat.tr,
                                  style: TextStyles.textStyleBold.apply(
                                      fontSizeFactor: 1.2,
                                      color: Colors.black)),
                            ),
                            alignment: Alignment.center,
                          ),
                        ),
                      ],
                    ),
                    flex: 4,
                  ),
                  Container(height: 10),
                ],
              );
            },
          ),
          Visibility(
            child: Loader(),
            visible: isLoading,
          )
        ],
      ),
    );
  }

  _getMusicTrack() async {
    setState(() {
      isLoading = true;
    });
    var parsed = await service.getMusicTrack();

    if (parsed != null) {
      videoType = parsed["videoType"] ?? 0;

      setState(() {
        isLoading = false;
      });
    }
  }

  _getVideoTrack() async {
    setState(() {
      isLoading = true;
    });
    var parsed = await service.getVideoTrack();

    if (parsed != null) {
      musicUrl = parsed["musicPath"];

      videoTypeDance = parsed["videoType"] ?? 0;
    }

    setState(() {
      isLoading = false;
    });
  }
}
