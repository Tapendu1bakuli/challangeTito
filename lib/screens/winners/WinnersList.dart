import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/screens/winners/WinnersListDance.dart';
import 'package:titosapp/screens/winners/WinnersListRap.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';
import 'package:titosapp/util/utils.dart';

class WinnersList extends StatefulWidget {
  const WinnersList({Key? key}) : super(key: key);

  @override
  _WinnersListState createState() => _WinnersListState();
}

class _WinnersListState extends State<WinnersList>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  bool isLoading = false;

  late final TabController _tabController;
  int page = 1;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      dismissKeyboard(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: TabBarView(
        controller: _tabController,
        children: [WinnersListDance(), WinnersListRap()],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final tab = TabBar(
        indicatorWeight: 4.0,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: CustomColor.colorYellow,
        controller: _tabController,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
            page = 1;
          });
        },
        tabs: <Tab>[
          Tab(
              icon: Text(
            AppString.dance.tr,
            style: TextStyles.textStyleSemiBold.apply(
                color: _selectedTabIndex == 0
                    ? CustomColor.myCustomYellow
                    : CustomColor.white),
          )),
          Tab(
              icon: Text(
            AppString.sing.tr,
            style: TextStyles.textStyleSemiBold.apply(
                color: _selectedTabIndex == 1
                    ? CustomColor.myCustomYellow
                    : CustomColor.white),
          )),
        ]);
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: CustomColor.myCustomYellow,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      backgroundColor: Colors.black,
      centerTitle: true,
      title: Text(
        AppString.pastWinners.tr.toUpperCase(),
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
      bottom: PreferredSize(preferredSize: Size.fromHeight(55), child: tab),
    );
  }
}
/*  _buildWinners() {
    return GestureDetector(
      onTap: () => dismissKeyboard(context),
      child: Column(
        children: [
          _buildSearchTextField(),
          // _listWinners.length > 0
          // ?
          _buildWinnersList(),

          // : Expanded(
          //     child: Container(
          //         color: CustomColor.white,
          //         height: MediaQuery.of(context).size.height / 2,
          //         child: Center(
          //           child: CircularProgressIndicator(
          //             color: CustomColor.colorYellow,
          //           ),
          //         )),
          //   ),
        ],
      ),
    );
  }

  _buildSearchTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: CustomSearchTextField(
        textController: _searchTextController,
        focusNode: FocusNode(),
        onTap: () {
          // if (focusNode.hasFocus)
          //   focusNode.unfocus();
          // else
          //   focusNode.requestFocus();
          // page = 1;
          // _searchWinners();
        },
        isLoading: isLoading,
      ),
    );
  }

  _buildWinnersList() {
    print("Winner ListView Dance: ${_listWinnersDance.length}");
    print("Winner ListView Rap: ${_listWinnersRap.length}");

    if (_selectedTabIndex == 0) {
      return Expanded(
        child: ListView.separated(
          physics: const ClampingScrollPhysics(),
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: _listWinnersDance.length,
          itemBuilder: (BuildContext context, int index) {
            return _listWinnersDance.length > 0
                ? _buildList(_listWinnersDance[index])
                : Offstage();
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(height: 16);
          },
        ),
      );
    } else {
      return Expanded(
        child: ListView.separated(
          controller: _scrollController,
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          itemCount: _listWinnersRap.length,
          itemBuilder: (BuildContext context, int index) {
            return _listWinnersRap.length > 0
                ? _buildList(_listWinnersRap[index])
                : Offstage();
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(height: 16);
          },
        ),
      );
    }
  }

  _buildList(WinnersModelList model) {
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
            AppString.beat + " ${model.beatName}",
            overflow: TextOverflow.ellipsis,
            style: TextStyles.textStyleRegular
                .apply(color: Colors.black, fontSizeDelta: -1),
          ),
          SizedBox(height: 4),
          Text(
            AppString.date + model.createdAt.split("T").first,
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
        setState(() {
          isLoading = false;

          _listWinnersDance
              .addAll(WinnersModel.fromJson(parsed).votingVideoList);
        });
      } else if (parsed["status"] == "failure") {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            gravity: ToastGravity.BOTTOM,
            msg: parsed["error"],
            backgroundColor: CustomColor.myCustomBlack,
            textColor: Colors.white);
      }
    }
  }

  _fetchWinnersRap() async {
    print("Fetch Winners Rap");
    setState(() {
      isLoading = true;
    });

    var parsed = await _service.getWinnersList(videoType: 1, pagination: page);

    if (parsed != null) {
      if (parsed["status"] == "success") {
        setState(() {
          isLoading = false;

          _listWinnersRap.addAll(WinnersModel.fromJson(parsed).votingVideoList);
        });
      } else if (parsed["status"] == "failure") {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            gravity: ToastGravity.BOTTOM,
            msg: parsed["error"],
            backgroundColor: CustomColor.myCustomBlack,
            textColor: Colors.white);
      }
    }
  }

  _searchWinners() async {
    setState(() {
      isLoading = true;
    });

    var result = await _service.searchWinner(
        search: _searchTextController.text,
        pagination: page,
        videoType: _selectedTabIndex == 0 ? 2 : 1);
    setState(() {
      isLoading = false;
    });
    if (result != null) {
      if (result["status"] == "success") {
        setState(() {
          if (_selectedTabIndex == 0) {
            _listWinnersDanceSearch
                .addAll(WinnersModel.fromJson(result).votingVideoList);
          } else {
            _listWinnersRapSearch
                .addAll(WinnersModel.fromJson(result).votingVideoList);
          }
        });
      } else if (result["status"] == "failure") {
        Fluttertoast.showToast(
            gravity: ToastGravity.BOTTOM,
            msg: result["error"],
            backgroundColor: CustomColor.myCustomBlack,
            textColor: Colors.white);
      }
    }
  }

  _onSearchTextChanged() async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      if (_searchTextController.text.trim().isEmpty) {
        page = 1;

        if (_selectedTabIndex == 0) {
          _fetchWinnersDance();
        } else {
          _fetchWinnersRap();
        }
      } else {
        _searchWinners();
      }
    });
    setState(() {});
  }

  _onTabChanged() {
    setState(() {
      _selectedTabIndex = _tabController.index;
      _listWinnersRap.clear();
      _listWinnersDance.clear();
      page = 1;
      _searchTextController.clear();
      if (_selectedTabIndex == 0) {
        print("danceIndex: $_selectedTabIndex");

        print("danceIndexList: ${_listWinnersDance.length}");

        _fetchWinnersDance();
      } else {
        print("RapIndex: $_selectedTabIndex");

        print("RapIndexList: ${_listWinnersRap.length}");

        _fetchWinnersRap();
      }
    });
  }

  _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !isLoading) {
      print("Scroll Call");
      page++;

      if (_searchTextController.text.trim().isNotEmpty) {
        _searchWinners();
      } else {
        if (_selectedTabIndex == 0) {
          _fetchWinnersDance();
        } else {
          _fetchWinnersRap();
        }
      }
    }
  }
}
 */
