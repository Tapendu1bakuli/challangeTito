import 'dart:io' show Platform, exit;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:titosapp/apiService/AuthServices.dart';
import 'package:titosapp/apiService/MediaServices.dart';
import 'package:titosapp/screens/Events/EventsList.dart';
import 'package:titosapp/screens/LanguageSelectionScreen.dart';
import 'package:titosapp/screens/dashboard/DashboardStep2Screen.dart';
import 'package:titosapp/screens/wallet/Wallet.dart';
import 'package:titosapp/screens/winners/WinnersList.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/Assets.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/LocalNotification.dart';
import 'package:titosapp/util/TextStyles.dart';
import 'package:titosapp/util/localStorage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../Store/HiveStore.dart';
import '../../Store/ShareStore.dart';
import '../../main.dart';
import '../../widgets/CustomDialogOverlay.dart';
import '../../widgets/CustomDialogOverlayTOS.dart';
import '../../widgets/Loader.dart';
import 'PaymentAccount.dart';

class HomeScreen extends StatefulWidget {
  final String walletBalance;

  HomeScreen({this.walletBalance = ""});

  @override
  HomeScreenState createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
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
  Stream<LocalNotification>? _updateNameStream;

  int videoType = 0;
  var token = '';
  String _email = "";
  String _name = "";
  String _lastName = "";
  String youTubeChannelLink = "";
  CarouselController buttonCarouselController = CarouselController();
  late List<ImageLinkModel> imgList = [];
  late List<Widget> imageSliders;

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

      print(duration);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> requestCameraPermission2() async {
    var status = await Permission.camera.request();
    if(mounted)
    setState(() {
      var _cameraPermission = status;
    });
  }

  Future<void> requestCameraPermission() async {
    requestCameraPermission2();

    await Permission.camera.request();

    await Permission.microphone.request();
    await Permission.storage.request();
    if(mounted)
    setState(() {
      // _cameraPermission = status;
    });
  }

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print("message received" + message.data.toString());

    if (!isBackground) {
      flutterLocalNotificationsPlugin.show(
          message.data.hashCode,
          message.data['title'],
          message.data['body'],
          NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                styleInformation: BigTextStyleInformation("")),
          ));
    }
  }

  firebaseandroid() async {
    if (Platform.isAndroid) {
      if (isBackground) {
        WidgetsFlutterBinding.ensureInitialized();
        await Firebase.initializeApp();
        var initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/ic_launcher');
        var initializationSettings =
            InitializationSettings(android: initializationSettingsAndroid);
        flutterLocalNotificationsPlugin.initialize(initializationSettings);
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          RemoteNotification? notification = message.notification;
          AndroidNotification? android = message.notification?.android;
          if (notification != null && android != null) {
            final newnotification = LocalNotification("new");
            NotificationsBloc.instance.newNotification(newnotification);
            flutterLocalNotificationsPlugin.show(
                notification.hashCode,
                notification.title,
                notification.body,
                NotificationDetails(
                  android: AndroidNotificationDetails(channel.id, channel.name,
                      icon: android.smallIcon,
                      styleInformation: BigTextStyleInformation('')),
                ));
          }
        });

        var prefs = await HiveStore.getInstance();
        token = (await FirebaseMessaging.instance.getToken())!;
        prefs.setString("notificationtoken", token);

        FirebaseMessaging.onBackgroundMessage(
            firebaseMessagingBackgroundHandler);
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    }
  }

  @override
  void initState() {
    isBackground = true;
    firebaseandroid();
    ShareStore().saveContext(object: context);

    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _updateNameStream = NotificationsBloc.instance.notificationsStream;
    _updateNameStream!.listen((notification) {
      if (notification.type == "new") {
        _getNameAndEmail();
      }
    });
    _notificationsStream!.listen((notification) {
      if (notification.type == "new") {
        getMusicTrack();
      }
    });
    _controller = VideoPlayerController.network("");
    getSliderDetails();
    getMusicTrack();
    _getNameAndEmail();
    super.initState();
    if (widget.walletBalance.isNotEmpty) {
      print("NEW");
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        showDialog(
          context: context,
          builder: (_) => VotingOverlayTOS(walletBalance: widget.walletBalance),
        );
      });
    }

    imageSliders = imgList
        .map((item) => Container(
              margin: EdgeInsets.all(5.0),
              child: InkWell(
                onTap: () {
                  if (item.linkUrl.isNotEmpty) _launchURL(item.linkUrl);
                },
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[
                        Image.network(item.imageUrl,
                            fit: BoxFit.cover, width: 1000.0),
                        /*Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(200, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Text(
                              'No. ${imgList.indexOf(item)} image',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),*/
                      ],
                    )),
              ),
            ))
        .toList();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    isPlaying = false;

    _controller!.dispose();
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
      if (mounted) getMusicTrack();
    }
    setState(() {});
  }

  String accesstoken = "";

  getMusicTrack() async {
    var parsed = await service.getMusicTrack();

    if (parsed != null) {
      musicUrl = parsed["musicPath"] ??
          "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3";
      localStorage.storeMusic(musicUrl, parsed["musicId"].toString(),
          parsed["musicName"].toString(), parsed["youtubeChannelLink"]);
      videoPath = parsed["videoUrl"] ?? "";
      videoType = parsed["videoType"] ?? 0;
      youTubeChannelLink = parsed["youtubeChannelLink"];
      await startPlayer(musicUrl);
      if (mounted)
        setState(() {
          beatName = parsed["musicName"] ?? "Beat Name".tr;
        });
    } else {}
  }

  getSliderDetails() async {
    setState(() {
      isLoading = true;
    });
    var parsed = await service.getSliderDetails();
    if (parsed != null) {
      if (mounted)
        setState(() {
          imgList = List.from(parsed['data']['sliders'])
              .map((e) => ImageLinkModel(
                  imageUrl: e["image_path"] == null ? "" : e["image_path"],
                  linkUrl: e["url"] == null ? "" : e["url"],
                  country: e["country"] == null ? "" : e["country"]))
              .toList();
          isLoading = false;
        });
    } else {
      setState(() {
        isLoading = false;
      });
    }
    imageSliders = imgList
        .map((item) => Container(
              margin: EdgeInsets.all(5.0),
              child: InkWell(
                onTap: () {
                  if (item.linkUrl.isNotEmpty) _launchURL(item.linkUrl);
                },
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[
                        CachedNetworkImage(
                          height: MediaQuery.of(context).size.height / 4,
                          imageUrl: item.imageUrl,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.fill),
                            ),
                          ),
                          placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                            color: CustomColor.colorYellow,
                          )),
                          errorWidget: (context, url, error) =>
                              Center(child: Icon(Icons.error)),
                        ),
                        /*Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(200, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Text(
                              'No. ${imgList.indexOf(item)} image',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),*/
                      ],
                    )),
              ),
            ))
        .toList();
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: CustomColor.white,
          appBar: AppBar(
            backgroundColor: Colors.black,
            centerTitle: true,
            title: Text(AppString.home.tr,
                // AppString.beat + beatName,
                style: TextStyles.textStyleSemiBold
                    .apply(fontSizeFactor: 1.34, color: Colors.white)
                // TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
            iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
          ),
          drawer: Drawer(
            child: Column(
              // physics: ClampingScrollPhysics(),
              // padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 60,
                              width: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Icon(Icons.contacts_outlined),
                            ),
                            SizedBox(height: 12),
                            Text(
                              _name + " $_lastName",
                              style: TextStyles.textStyleSemiBold,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              _email,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyles.textStyleRegular
                                  .apply(color: CustomColor.white),
                            ),
                          ],
                        ),
                      ),
                      // Visibility(child: Loader(),visible: isLoading,)
                    ],
                  ),
                ),
                ListTile(
                  leading: Image.asset(
                    Assets.payment,
                    width: 24,
                  ),
                  title: Text(
                    AppString.rewardAccounts.tr,
                    style:
                        TextStyles.textStyleRegular.apply(color: Colors.black),
                  ),
                  onTap: () async {
                    if (isPlaying) {
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                      await player.stop();
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PaymentAccount(
                                  isFromHome: false,
                                )));
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    Assets.wallet,
                    width: 24,
                  ),
                  title: Text(
                    AppString.wallet.tr,
                    style:
                        TextStyles.textStyleRegular.apply(color: Colors.black),
                  ),
                  onTap: () async {
                    if (isPlaying) {
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                      await player.stop();
                    }
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Wallet()));
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    Assets.resume,
                    width: 24,
                  ),
                  title: Text(
                    AppString.editProfile.tr,
                    style:
                        TextStyles.textStyleRegular.apply(color: Colors.black),
                  ),
                  onTap: () async {
                    if (isPlaying) {
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                      await player.stop();
                    }
                    Navigator.of(context).pushNamed("/EditProfileScreen");
                  },
                ),
                // ListTile(
                //   leading: Image.asset(
                //     Assets.myTicket,
                //     width: 24,
                //   ),
                //   title: Text(
                //     AppString.myTicket.tr,
                //     style:
                //         TextStyles.textStyleRegular.apply(color: Colors.black),
                //   ),
                //   onTap: () async {
                //     if (isPlaying) {
                //       setState(() {
                //         isPlaying = !isPlaying;
                //       });
                //       await player.stop();
                //     }
                //     Navigator.of(context).pushNamed("/MyTickets");
                //   },
                // ),
                ListTile(
                  leading: Image.asset(
                    Assets.lock,
                    width: 24,
                  ),
                  title: Text(
                    AppString.change_Password.tr,
                    style:
                        TextStyles.textStyleRegular.apply(color: Colors.black),
                  ),
                  onTap: () async {
                    if (isPlaying) {
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                      await player.stop();
                    }
                    Navigator.of(context).pushNamed("/ChangePasswordScreen");
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    Assets.share,
                    width: 24,
                  ),
                  title: Text(
                    AppString.inviteFriend.tr,
                    style:
                        TextStyles.textStyleRegular.apply(color: Colors.black),
                  ),
                  onTap: () async {
                    if (isPlaying) {
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                      await player.stop();
                    }
                    Share.share("https://mytitos.com/#");
                  },
                ),
                ListTile(
                    leading: Icon(Icons.delete),
                    title: Text(
                      AppString.deleteAccount.tr,
                      style: TextStyles.textStyleRegular
                          .apply(color: Colors.black),
                    ),
                    onTap: () {
                      _showDeleteDialog(context);
                    }),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    alignment: Alignment.bottomCenter,
                    child: OutlinedButton.icon(
                        onPressed: () async {
                          if (isPlaying) {
                            setState(() {
                              isPlaying = !isPlaying;
                            });
                            await player.stop();
                          }
                          authservice.logOut();
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      LanguageSelectionScreen()),
                              (Route<dynamic> route) => false);
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          minimumSize:
                              Size(MediaQuery.of(context).size.width, 48),
                          side: BorderSide(
                              width: 2.0,
                              color: CustomColor.colorButtonBorderLogout),
                        ),
                        icon: Image.asset(
                          Assets.logout,
                          width: 24,
                          height: 20,
                        ),
                        label: Text(
                          AppString.logout.tr,
                          style: TextStyles.textStyleRegular
                              .apply(color: Colors.black),
                        )),
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                ListView(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  children: [
                    SizedBox(height: 15),
                    CarouselSlider(
                      options: CarouselOptions(
                        aspectRatio: 2.0,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                        autoPlay: true,
                      ),
                      items: imageSliders,
                    ),
                    SizedBox(height: 15),
                    Center(
                      child: Text(AppString.challenge.tr,
                          textAlign: TextAlign.center,
                          style: TextStyles.textStyleSemiBold
                              .apply(color: Colors.black, fontSizeFactor: 1.2)),
                    ),
                    SizedBox(height: 15),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 4.5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (_) {
                                return DashboardStep2Screen();
                              }));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 3.5,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    bottom: 40,
                                    child: Container(
                                      color: CustomColor.myCustomBlack,
                                      padding: EdgeInsets.all(20),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                Assets.takeChallenge),
                                            fit: BoxFit.scaleDown,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: Text(AppString.takeAChallenge.tr,
                                          textAlign: TextAlign.center,
                                          style:
                                              TextStyles.textStyleDashSubTitle),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) {
                                return WinnersList();
                              }));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 3.5,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    bottom: 40,
                                    child: Container(
                                      color: CustomColor.colorGrey,
                                      padding: EdgeInsets.all(20),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  Assets.checkWinners),
                                              fit: BoxFit.scaleDown,
                                              isAntiAlias: true),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: Text(AppString.checkTheWinners.tr,
                                          textAlign: TextAlign.center,
                                          style:
                                              TextStyles.textStyleDashSubTitle),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => VotingOverlay(),
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 3.5,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    bottom: 40,
                                    child: Container(
                                      color: CustomColor.colorYellow,
                                      padding: EdgeInsets.all(20),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image:
                                                  AssetImage(Assets.castVote),
                                              fit: BoxFit.scaleDown,
                                              isAntiAlias: true),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: Text(AppString.castYourVote.tr,
                                          textAlign: TextAlign.center,
                                          style:
                                              TextStyles.textStyleDashSubTitle),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Center(
                      child: Text(AppString.events.tr,
                          textAlign: TextAlign.center,
                          style: TextStyles.textStyleSemiBold
                              .apply(color: Colors.black, fontSizeFactor: 1.2)),
                    ),
                    SizedBox(height: 15),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EventsList()),
                        );
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height / 4,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(Assets.eventView),
                              fit: BoxFit.fill,
                              isAntiAlias: true),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 20,
                              top: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(Assets.bubble),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 8),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EventsList()),
                                    );
                                  },
                                  child: Text(AppString.buyTickets.tr,
                                      softWrap: true,
                                      style: TextStyles.textStyleDashSubTitle),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    /*Row(
                      children: [
                        _buildHomeOptions(AppString.challenge.tr, Assets.challenge,
                            Colors.black, Colors.white, () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) {
                            return DashboardStep2Screen();
                          }));
                        }),
                        _buildHomeOptions(AppString.winner.tr, Assets.winner,
                            Colors.white, Colors.black, () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) {
                            return WinnersList();
                          }));
                        })
                      ],
                    ),
                    Row(
                      children: [
                        _buildHomeOptions(AppString.events.toUpperCase().tr,
                            Assets.events, Colors.white, Colors.black, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EventsList()),
                          );
                        }),
                        _buildHomeOptions(AppString.voting.tr, Assets.voting,
                            CustomColor.colorYellow, Colors.black, () {
                          showDialog(
                            context: context,
                            builder: (_) => VotingOverlay(),
                          );
                          // Navigator.push(context, MaterialPageRoute(builder: (_) {
                          //   return VotingList();
                          // }));
                        }),
                      ],
                    ),*/
                  ],
                ),
                Visibility(visible: isLoading, child: Loader()),
              ],
            ),
          ),
        ),
        onWillPop: onWillPop);
  }

  Widget _buildHomeOptions(String title, String image, Color bgColor,
      Color textColor, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 188,
        width: MediaQuery.of(context).size.width * 0.5,
        color: bgColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              title,
              style: TextStyles.textStyleBold.apply(color: textColor),
            ),
            Image.asset(
              image,
              height: 60,
              width: 60,
            )
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppString.deleteAccount.tr,
            style: TextStyle(color: Colors.redAccent),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(AppString.deleteAccountMessage.tr,
                    style: Get.textTheme.bodyMedium),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppString.cancel.tr, style: Get.textTheme.bodyMedium),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              child: Text(
                AppString.confirm.tr,
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () async {
                Get.back();
                Get.back();
                setState(() {
                  isLoading = true;
                });
                await AuthService().deleteAccountFromServer();
                setState(() {
                  isLoading = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _launchURL(String _url) async {
    if (!(_url.contains("http://") || _url.contains("https://"))) {
      _url = "http://$_url";
    }
    Uri url = Uri.parse(_url);
    if (await canLaunchUrl(url))
      await launchUrl(url);
    else
      // can't launch url, there is some error
      throw "Could not launch $url";
  }

  void _getNameAndEmail() async {
    _name = await localStorage.getValue('first_name');
    _lastName = await localStorage.getValue('last_name');

    _email = await localStorage.getValue("email");
  }
}

class ImageLinkModel {
  late final String imageUrl;
  late final String linkUrl;
  late final String country;

  ImageLinkModel({this.imageUrl = "", this.linkUrl = "", this.country = ""});
}
