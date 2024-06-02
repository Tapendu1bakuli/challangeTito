import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/apiService/MediaServices.dart';
import 'package:titosapp/model/winners/WinnersModel.dart';
import 'package:titosapp/screens/winners/WinnersVideoPlayBack.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';
import 'package:titosapp/util/utils.dart';
import 'package:titosapp/widgets/CustomSearchTextField.dart';

class WinnersListDance extends StatefulWidget {
  const WinnersListDance({Key? key}) : super(key: key);

  @override
  _WinnersListDanceState createState() => _WinnersListDanceState();
}

class _WinnersListDanceState extends State<WinnersListDance> {
  bool isLoading = false;
  late TextEditingController _searchTextController = TextEditingController();
  MediaService _service = MediaService();

  List<WinnersModelList> _listWinnersRap = <WinnersModelList>[];
  List<WinnersModelList> _listWinnersRapSaved = <WinnersModelList>[];

  int page = 1;

  ScrollController _scrollController = ScrollController();
  String errorMessage = "";

  int _totalvideo = 0;
  FocusNode focusNode = FocusNode();
  bool _onInit = false;

  @override
  void initState() {
    _onInit = true;
    _fetchWinnersDance();
    // _searchTextController.addListener(_onSearchTextChanged);
    _searchTextController.addListener(() {
      if (_searchTextController.text.isEmpty && focusNode.hasFocus) {
        setState(() {
          _onInit = true;

          _listWinnersRap.clear();
          _listWinnersRap.addAll(_listWinnersRapSaved);
        });
      }
    });
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // _searchTextController.removeListener(_onSearchTextChanged);
    _searchTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildWinners(),
        ],
      ),
    );
  }

  _buildWinners() {
    return GestureDetector(
      onTap: () => dismissKeyboard(context),
      child: Column(
        children: [
          _buildSearchTextField(),
          if (_listWinnersRap.length > 0)
            _buildWinnersList()
          else if (errorMessage.isNotEmpty)
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                child: Center(
                    child: Text(
                  errorMessage.tr,
                  style: TextStyles.textStyleBold.apply(color: Colors.black),
                )),
              ),
            )
          else
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                child: Center(
                    child: CircularProgressIndicator(
                  color: CustomColor.colorYellow,
                )),
              ),
            )
        ],
      ),
    );
  }

  _buildSearchTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: CustomSearchTextField(
        hintText: AppString.search.tr,
        textController: _searchTextController,
        focusNode: focusNode,
        readOnly: isLoading ? true : false,
        onTap: () {
          if (_searchTextController.text.isEmpty) {
            return;
          }
          if (focusNode.hasFocus) {
            focusNode.unfocus();
          } else {
            focusNode.requestFocus();
          }
          if (_searchTextController.text.trim().isNotEmpty) {
            setState(() {
              page = 1;
              errorMessage = "";
              if (_onInit) {
                _listWinnersRapSaved.clear();
                _listWinnersRapSaved.addAll(_listWinnersRap);

                _listWinnersRap.clear();

                _onInit = false;
              }
              _listWinnersRap.clear();
              _searchRap();
            });
          }
        },
        isLoading: isLoading,
      ),
    );
  }

  _buildWinnersList() {
    print("Winner _listWinnersRap : ${_listWinnersRap.length}");
    print("Winner _listWinnersRapSaved : ${_listWinnersRapSaved.length}");

    return Expanded(
      child: ListView.separated(
        physics: const ClampingScrollPhysics(),
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: _listWinnersRap.length,
        itemBuilder: (BuildContext context, int index) {
          return ((index == _listWinnersRap.length - 1 &&
                      index == _listWinnersRapSaved.length - 1) &&
                  _listWinnersRap.length < _totalvideo &&
                  _listWinnersRapSaved.length < _totalvideo)
              ? Container(
                  padding: EdgeInsets.only(bottom: 20),
                  height: 60,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: CustomColor.colorYellow,
                    ),
                  ))
              : _buildList(_listWinnersRap[index], index);
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: 16);
        },
      ),
    );
  }

  _buildList(WinnersModelList model, int index) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: CustomColor.colorBorderSearch)),
      child: Row(
        children: [
          _buildImageSection(model),
          SizedBox(width: 12),
          _buildInfoSection(model),
          Spacer(),
          InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => WinnersVideoPlayBack(
                              videoPath: model.path,
                              beatname: model.beatName,
                              artistName: model.artistName,
                              model: model,
                              index: index,
                            )));
              },
              child: Container(
                margin: EdgeInsets.all(16),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: CustomColor.colorGrey, shape: BoxShape.circle),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                  size: 15,
                ),
              ))
        ],
      ),
    );
  }

  _buildImageSection(WinnersModelList model) {
    return CachedNetworkImage(
      width: MediaQuery.of(context).size.width / 3.5,
      height: 140,
      imageUrl: model.imagePath,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: imageProvider, fit: BoxFit.fill),
        ),
      ),
      placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
        color: CustomColor.colorYellow,
      )),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  _buildInfoSection(WinnersModelList model) {
    return Expanded(
      flex: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            model.artistName,
            style: TextStyles.textStyleBold.apply(color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            AppString.beat.tr + " ${model.beatName}",
            overflow: TextOverflow.ellipsis,
            style: TextStyles.textStyleRegular
                .apply(color: Colors.black, fontSizeDelta: -1),
          ),
          SizedBox(height: 4),
          Text(
            AppString.date.tr + model.createdAt.split("T").first,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.textStyleRegular
                .apply(color: Colors.black, fontSizeDelta: -1),
          ),
        ],
      ),
    );
  }

  _fetchWinnersDance() async {
    print("Fetch Winners Dance");
    setState(() {
      isLoading = true;
    });

    var parsed = await _service.getWinnersList(videoType: 2, pagination: page);

    if (parsed != null) {
      if (parsed["status"] == "success") {
        if (mounted)
          setState(() {
            isLoading = false;
            _totalvideo = parsed["total_video"];

            _listWinnersRap
                .addAll(WinnersModel.fromJson(parsed).votingVideoList);
            errorMessage = "";
          });
      } else if (parsed["status"] == "failure") {
        setState(() {
          isLoading = false;
          errorMessage = parsed["error"];
        });
      }
    }
  }

  _searchRap() async {
    setState(() {
      isLoading = true;
    });

    var result = await _service.searchWinner(
        search: _searchTextController.text, pagination: page, videoType: 2);
    setState(() {
      isLoading = false;
    });
    if (result != null) {
      if (result["status"] == "success") {
        setState(() {
          WinnersModel.fromJson(result).votingVideoList.forEach((element) {
            if (element.videoType == 2) {
              _listWinnersRap.add(element);
            }
          });
          //_listWinnersRap.addAll(WinnersModel.fromJson(result).votingVideoList);
          errorMessage = "";
        });
      } else if (result["status"] == "failure") {
        setState(() {
          isLoading = false;
          errorMessage = result["error"];
          print("Error Message" + errorMessage);
        });
      }
    }
  }

  _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        _totalvideo > (12 * page)) {
      print("Scroll Call");
      page++;

      if (_searchTextController.text.trim().isNotEmpty) {
        _searchRap();
      } else {
        _fetchWinnersDance();
      }
    }
  }
}
