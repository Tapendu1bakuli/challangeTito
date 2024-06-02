import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:titosapp/Store/HiveStore.dart';
import 'package:titosapp/apiService/MediaServices.dart';
import 'package:titosapp/model/VotingDancingVideoModel.dart';
import 'package:titosapp/model/VotingSingVideoModel.dart';
import 'package:titosapp/screens/voting/VoteCasting.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';
import 'package:titosapp/widgets/Loader.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class VotingList extends StatefulWidget {
  final int option;

  const VotingList({Key? key, required this.option}) : super(key: key);

  @override
  _VotingListState createState() => _VotingListState();
}

class _VotingListState extends State<VotingList> with WidgetsBindingObserver {
  String _beatName = "Beat Name".tr;
  String _artistName = "Artist Name";
  num _tosAmount = 0;
  int _videoId = 0;
  int currentIndex = 0;
  String _videoName = "";
  bool _isPlaying = false;
  bool _isDisposed = false;
  bool onInit = false;
  late VideoPlayerController _controller = VideoPlayerController.network("");
  bool isLoading = false;
  num maxVote = 0;
  MediaService service = MediaService();
  VotingSingingVideoModel _listSingingVideo =
      VotingSingingVideoModel(votingVideoList: []);
  VotingDancingVideoModel _listDanceVideo =
      VotingDancingVideoModel(votingVideoList: []);

  Map<dynamic, dynamic> storeRaps = <dynamic, dynamic>{};
  Map<dynamic, dynamic> storeDance = <dynamic, dynamic>{};
  String _videoPath = "";

  @override
  void initState() {
    super.initState();
    onInit = true;
    _getVotingSingingVideo();
    getStoreData();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    print("dispose");
    WidgetsBinding.instance.removeObserver(this);
    _isDisposed = true;
    super.dispose();
    if (!mounted) _controller.pause();
    _controller.removeListener(() {
      setState(() {});
    });
    _controller.dispose();
  }

  @override
  void deactivate() {
    print("deactivate");
    if (!mounted) _controller.pause();
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) _controller.pause();
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
      appBar: _buildAppBar(context),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                    child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    _playView(context),
                    Visibility(
                      child: Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () {
                            if (_controller.value.isPlaying) {
                              setState(() {
                                _controller.pause();
                                _isPlaying = false;
                                Wakelock.disable();
                              });
                            } else {
                              setState(() {
                                _controller.play();
                                _isPlaying = true;
                                Wakelock.enable();
                              });
                            }
                          },
                          child: CircleAvatar(
                            radius: 33,
                            backgroundColor: _controller.value.isPlaying
                                ? Colors.transparent
                                : Colors.black38,
                            child: _controller.value.isPlaying
                                ? _controller.value.isBuffering
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
                      visible: _controller.value.isInitialized,
                    )
                  ],
                )),
                // _controlView(context),
                _buildList()
              ],
            ),
          ),
          Visibility(
            child: Loader(),
            visible: isLoading,
          )
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: new Icon(
          Icons.arrow_back_ios,
          color: CustomColor.myCustomYellow,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      backgroundColor: Colors.black,
      centerTitle: true,
      title: Container(
        padding: EdgeInsets.only(right: 20),
        child: Text(
          AppString.beat.tr.toUpperCase() + " $_beatName".tr,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
      bottom: _controller.value.isPlaying
          ? PreferredSize(
              preferredSize: Size.fromHeight(0),
              child: Container(),
            )
          : PreferredSize(
              preferredSize: Size.fromHeight(55),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInSine,
                switchOutCurve: Curves.easeOutSine,
                child: _controller.value.isPlaying
                    ? Offstage()
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _artistName.tr,
                              style: TextStyles.textStyleSemiBold,
                            ),
                            Visibility(
                              visible: _controller.value.isInitialized,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _controller.pause();
                                    _isPlaying = false;
                                  });
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => VoteCasting(
                                                artistName: _artistName,
                                                beatName: _beatName,
                                                type: widget.option == 1
                                                    ? "s"
                                                    : "d",
                                                videoId: _videoId,
                                                videoName: _videoName,
                                                maxVote: maxVote,
                                              )));
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(120, 40), backgroundColor: CustomColor.colorYellow,
                                ),
                                child: Text(
                                  AppString.vote.tr,
                                  style: TextStyles.textStyleSemiBold.apply(
                                      color: Colors.black, fontSizeDelta: -1),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
              ),
            ),
    );
  }

  _buildList() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInSine,
      switchOutCurve: Curves.easeOutSine,
      child: _controller.value.isPlaying
          ? Offstage()
          : Container(
              height: 120,
              child: ListView.builder(
                physics: ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: widget.option == 1
                    ? _listSingingVideo.votingVideoList.length
                    : _listDanceVideo.votingVideoList.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      _onTapVideo(index);
                      setState(() {
                        _videoPath = widget.option == 1
                            ? _listSingingVideo.votingVideoList[index].path
                            : _listDanceVideo.votingVideoList[index].path;
                        _beatName = widget.option == 1
                            ? _listSingingVideo.votingVideoList[index].beatName
                            : _listDanceVideo.votingVideoList[index].beatName;
                        _artistName = widget.option == 1
                            ? _listSingingVideo
                                .votingVideoList[index].artistName
                            : _listDanceVideo.votingVideoList[index].artistName;
                        _videoName = widget.option == 1
                            ? _listSingingVideo.votingVideoList[index].videoName
                            : _listDanceVideo.votingVideoList[index].videoName;
                        _videoId = widget.option == 1
                            ? _listSingingVideo.votingVideoList[index].id
                            : _listDanceVideo.votingVideoList[index].id;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(5.0),
                      color: currentIndex == index
                          ? CustomColor.colorYellow
                          : Colors.transparent,
                      child: CachedNetworkImage(
                        width: 80,
                        height: 100,
                        imageUrl: widget.option == 1
                            ? _listSingingVideo.votingVideoList[index].imagePath
                            : _listDanceVideo.votingVideoList[index].imagePath,
                        imageBuilder: (context, imageProvider) => Container(
                          margin: EdgeInsets.all(8),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                          color: CustomColor.colorYellow,
                        )),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  _getVotingSingingVideo() async {
    /*setState(() {
      isLoading = true;
    });*/

    var parsed = widget.option == 1
        ? await service.getVotingSingingVideo()
        : await service.getVotingDancingVideo();
    if (parsed != null) {
      setState(() {
        maxVote = int.parse(parsed["max_vote"].toString());
        print("Max Vote: $maxVote");
      });
      if (widget.option == 1) {
        setState(() {
          _listSingingVideo = VotingSingingVideoModel.fromJson(parsed);
          print("Data : ${_listSingingVideo.version != storeRaps["version"]}");
          if (_listSingingVideo.version != storeRaps["version"]) {
            HiveStore().remove(Keys.RAPS);
            saveRapVideos();
            _onTapVideo(0);
          } else {
            _onTapVideo(0);
          }
        });
      } else {
        setState(() {
          _listDanceVideo = VotingDancingVideoModel.fromJson(parsed);
          if (_listDanceVideo.version != storeDance["version"]) {
            HiveStore().remove(Keys.DANCE);
            saveDanceVideos();
            _onTapVideo(0);
          } else {
            _onTapVideo(0);
          }
        });
      }
      /*setState(() {
        isLoading = false;
      });*/
    }
  }

  _initializeVideo(int index) async {
    if (_controller.value.isInitialized) {
      _controller.pause();
      _controller.dispose();
    }
    _controller = VideoPlayerController.network("");
    getStoreData();
    if (widget.option == 1) {
      initRapController(index);
    } else {
      initDanceController(index);
    }
  }

  _onTapVideo(int index) async {
    setState(() {
      currentIndex = index;
      if (widget.option == 1) {
        _beatName = _listSingingVideo.votingVideoList[index].beatName;
        _artistName = _listSingingVideo.votingVideoList[index].artistName;
        _videoId = _listSingingVideo.votingVideoList[index].id;
        _videoName = _listSingingVideo.votingVideoList[index].videoName;
        _videoPath = _listSingingVideo.votingVideoList[index].path;
        _tosAmount = _listSingingVideo.votingVideoList[index].tos;
      } else {
        _beatName = _listDanceVideo.votingVideoList[index].beatName;
        _artistName = _listDanceVideo.votingVideoList[index].artistName;
        _videoId = _listDanceVideo.votingVideoList[index].id;
        _videoName = _listDanceVideo.votingVideoList[index].videoName;
        _videoPath = _listDanceVideo.votingVideoList[index].path;
        _tosAmount = _listDanceVideo.votingVideoList[index].tos;
      }
      _initializeVideo(index);
    });
  }

  Widget _playView(BuildContext context) {
    if (_controller.value.isInitialized) {
      return GestureDetector(
        onTap: () {
          if (_controller.value.isPlaying) {
            setState(() {
              _controller.pause();
              _isPlaying = false;
              Wakelock.disable();
            });
          }
        },
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VideoPlayer(_controller),
              VideoProgressIndicator(_controller, allowScrubbing: true),
              Positioned(bottom: 30,left: 20,child: Text("${AppString.tos} : $_tosAmount",style: TextStyles.textStyleSemiBold,)),
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

  void saveRapVideos() {
    _listSingingVideo.votingVideoList.forEach((element) {
      saveRapVideo(element);
    });
  }

  void saveRapVideo(element) async {
    String dirLoc = (await getApplicationDocumentsDirectory()).path;
    await downloadFile(element.path, element.uniqueName, dirLoc, element);
    //await downloadImageFile(
    //element.imagePath, element.imageUniqueName, dirLoc, element);

    HiveStore().put(Keys.RAPS, _listSingingVideo.toJson());
  }

  void saveDanceVideo(
    element,
  ) async {
    String dirLoc = (await getApplicationDocumentsDirectory()).path;
    await downloadFile(element.path, element.uniqueName, dirLoc, element);
    //await downloadImageFile(
    //element.imagePath, element.imageUniqueName, dirLoc, element);
    HiveStore().put(Keys.DANCE, _listDanceVideo.toJson());
  }

  void saveDanceVideos() {
    _listDanceVideo.votingVideoList.forEach((element) {
      saveDanceVideo(element);
    });
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

  Future<String> downloadImageFile(
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

  void initRapController(
    int index,
  ) async {
    if (storeRaps.isNotEmpty) {
      File file = File(storeRaps["voting_video_list"][index]["saved_location"]);
      print(
          "Store: ${storeRaps["voting_video_list"][index]["saved_location"]}");
      print("File exists: ${await file.exists()}");
      if (await file.exists()) {
        setState(() {
          _controller = VideoPlayerController.file(
            file,
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );
        });
      } else {
        saveRapVideo(_listSingingVideo.votingVideoList[index]);
        setState(() {
          _controller = VideoPlayerController.network(
            _videoPath,
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );
        });
      }
    } else {
      setState(() {
        _controller = VideoPlayerController.network(
          _videoPath,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      });
    }
    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(false);
    _controller.initialize().then((_) => setState(() {
          if (onInit) {
            _controller.pause();
            onInit = false;
          } else {
            _controller.pause();
          }
          Wakelock.enable();
        }));
  }

  void initDanceController(
    int index,
  ) async {
    if (storeDance.isNotEmpty) {
      File file =
          File(storeDance["voting_video_list"][index]["saved_location"]);
      print(
          "Store: ${storeDance["voting_video_list"][index]["saved_location"]}");
      print("File exists: ${await file.exists()}");
      if (await file.exists()) {
        setState(() {
          _controller = VideoPlayerController.file(
            file,
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );
        });
      } else {
        saveDanceVideo(_listDanceVideo.votingVideoList[index]);
        setState(() {
          _controller = VideoPlayerController.network(
            _videoPath,
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );
        });
      }
    } else {
      setState(() {
        _controller = VideoPlayerController.network(
          _videoPath,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      });
    }
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.setLooping(false);
    _controller.initialize().then((_) => setState(() {
          if (onInit) {
            _controller.pause();
            onInit = false;
          } else {
            _controller.pause();
          }
          Wakelock.enable();
        }));
  }

  void getStoreData() {
    if (widget.option == 1) {
      setState(() {
        storeRaps = HiveStore().get(Keys.RAPS) == null
            ? <dynamic, dynamic>{}
            : HiveStore().get(Keys.RAPS);
      });
    } else {
      setState(() {
        storeDance = HiveStore().get(
                  Keys.DANCE,
                ) ==
                null
            ? <dynamic, dynamic>{}
            : HiveStore().get(
                Keys.DANCE,
              );
      });
    }
  }

  Future<Widget> getThumbImage(int index) async {
    Widget img = Container();
    if (widget.option == 1) {
      if (storeRaps.isNotEmpty) {
        File file = File(storeRaps["voting_video_list"][index]["saved_thumb"]);
        print("Store: ${storeRaps["voting_video_list"][index]["saved_thumb"]}");
        print("Image exists: ${await file.exists()}");
        if (await file.exists()) {
          img = Container(
            padding: EdgeInsets.all(5.0),
            color: currentIndex == index
                ? CustomColor.colorYellow
                : Colors.transparent,
            child: Image.file(
              file,
              width: 80,
              height: 100,
              fit: BoxFit.cover,
            ),
          );
        } else {
          img = Container(
            padding: EdgeInsets.all(5.0),
            color: currentIndex == index
                ? CustomColor.colorYellow
                : Colors.transparent,
            child: CachedNetworkImage(
              width: 80,
              height: 100,
              imageUrl: _listSingingVideo.votingVideoList[index].imagePath,
              imageBuilder: (context, imageProvider) => Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                color: CustomColor.colorYellow,
              )),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          );
        }
      } else {
        img = Container(
          padding: EdgeInsets.all(5.0),
          color: currentIndex == index
              ? CustomColor.colorYellow
              : Colors.transparent,
          child: CachedNetworkImage(
            width: 80,
            height: 100,
            imageUrl: _listSingingVideo.votingVideoList[index].imagePath,
            imageBuilder: (context, imageProvider) => Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) => Center(
                child: CircularProgressIndicator(
              color: CustomColor.colorYellow,
            )),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        );
      }
    } else {
      if (storeDance.isNotEmpty) {
        File file = File(storeDance["voting_video_list"][index]["saved_thumb"]);
        print(
            "Store: ${storeDance["voting_video_list"][index]["saved_thumb"]}");
        print("Image exists: ${await file.exists()}");
        if (await file.exists()) {
          img = Container(
            padding: EdgeInsets.all(5.0),
            color: currentIndex == index
                ? CustomColor.colorYellow
                : Colors.transparent,
            child: Image.file(
              file,
              width: 80,
              height: 100,
              fit: BoxFit.cover,
            ),
          );
        } else {
          img = Container(
            padding: EdgeInsets.all(5.0),
            color: currentIndex == index
                ? CustomColor.colorYellow
                : Colors.transparent,
            child: CachedNetworkImage(
              width: 80,
              height: 100,
              imageUrl: _listDanceVideo.votingVideoList[index].imagePath,
              imageBuilder: (context, imageProvider) => Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                color: CustomColor.colorYellow,
              )),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          );
        }
      } else {
        img = Container(
          padding: EdgeInsets.all(5.0),
          color: currentIndex == index
              ? CustomColor.colorYellow
              : Colors.transparent,
          child: CachedNetworkImage(
            width: 80,
            height: 100,
            imageUrl: _listDanceVideo.votingVideoList[index].imagePath,
            imageBuilder: (context, imageProvider) => Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) => Center(
                child: CircularProgressIndicator(
              color: CustomColor.colorYellow,
            )),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        );
      }
    }

    return img;
  }
}
