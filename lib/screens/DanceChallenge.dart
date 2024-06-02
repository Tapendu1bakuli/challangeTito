import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/apiService/MediaServices.dart';
import 'package:titosapp/screens/video/VideoRecording.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/LocalNotification.dart';
import 'package:titosapp/util/TextStyles.dart';
import 'package:titosapp/util/localStorage.dart';
import 'package:titosapp/widgets/CircledText.dart';
import 'package:titosapp/widgets/CustomTextField.dart';
import 'package:titosapp/widgets/CustomYoutubePlayer.dart';
import 'package:titosapp/widgets/Loader.dart';

class DanceChallenge extends StatefulWidget {
  final String? stageName;

  DanceChallenge({this.stageName});

  @override
  _DanceChallengeState createState() => _DanceChallengeState();
}

class _DanceChallengeState extends State<DanceChallenge>
    with WidgetsBindingObserver {
  bool isPlaying = false, musicAdded = false;
  var localStorage = new LocalHiveStorage();
  MediaService service = new MediaService();
  bool isLoading = false, isBackground = false;
  String musicUrl = "", beatName = "Beat Name";

  int videoType = 0;
  var token = '';
  String videoPath = "";
  String youTubeLink = "";
  TextEditingController stageNameTextController = TextEditingController();

  @override
  void initState() {
    stageNameTextController.text = widget.stageName ?? "";
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                AppString.danceChallenge.tr,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
            ),
            body: Stack(children: [
              Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                        color: CustomColor.myCustomBlack,
                        child: FutureBuilder<String>(
                          future:
                              _getVideoTrack(), // function where you call your api
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            // AsyncSnapshot<Your object type>
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                  child: Text(
                                'Please wait its loading...',
                                style: TextStyle(color: Colors.white),
                              ));
                            } else {
                              if (snapshot.hasError)
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              else
                                return new CustomYoutubePlayer(
                                    youTubeUrl: snapshot.data
                                        .toString()); // snapshot.data  :- get your object which is pass from your downloadData() function
                            }
                          },
                        )),
                  ),
                  /* Expanded(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.center,
                      color: CustomColor.white,
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [],
                        ),
                      ),
                    ),
                  ), */
                  Expanded(
                      flex: 6,
                      child: Container(
                        width: double.maxFinite,
                        padding: EdgeInsets.all(20),
                        color: CustomColor.customGrey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Text(
                          AppString.onlyOneVideo.tr,
                          textAlign: TextAlign.left,
                          style: TextStyles.textStyleRegular,
                        ),
                      )),
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: Colors.black,
                      child: Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () async {
                              final snackBar = SnackBar(
                                content: Text(AppString.enterStageName.tr),
                              );
                              if (stageNameTextController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                                return;
                              }
                              setState(() {
                                isPlaying = false;
                              });
                              ScaffoldMessenger.of(context).clearSnackBars();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoRecording(
                                      stageName: stageNameTextController.text,
                                      category: 2,
                                    ),
                                  ));
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
            ])));
  }

  Future<String> _getVideoTrack() async {
    var parsed = await service.getVideoTrack();

    if (parsed != null) {
      musicUrl = parsed["musicPath"];
      localStorage.storeMusic(musicUrl, parsed["musicId"].toString(),
          parsed["musicName"].toString(), parsed["youtubeChannelLink"]);

      videoType = parsed["videoType"] ?? 0;
      beatName = parsed["musicName"] ?? "Beat Name".tr;
    }

    return Future.value(parsed["DanceYoutubeLink"]);
  }
}
