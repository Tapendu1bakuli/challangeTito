import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/Store/HiveStore.dart';
import 'package:titosapp/apiService/MediaServices.dart';
import 'package:titosapp/screens/transaction/BuyToken.dart';
import 'package:titosapp/screens/voting/VotingSubmitted.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';
import 'package:titosapp/widgets/Loader.dart';

import '../../util/utils.dart';

class VoteCasting extends StatefulWidget {
  int videoId;
  String artistName;
  String beatName;
  String videoName;
  String type;
  num maxVote;

  VoteCasting({
    Key? key,
    required this.videoId,
    required this.artistName,
    required this.beatName,
    required this.videoName,
    required this.type,
    required this.maxVote,
  }) : super(key: key);

  @override
  _VoteCastingState createState() => _VoteCastingState();
}

class _VoteCastingState extends State<VoteCasting> {
  TextEditingController textController = TextEditingController(text: "1");
  bool isLoading = false;
  MediaService service = MediaService();
  HiveStore? prefs;
  String language = "";

  @override
  void initState() {
    super.initState();
    _getPref();
    textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: InkWell(
        onTap: () {
          dismissKeyboard(context);
        },
        child: Stack(
          children: [
            Center(
              child: Card(
                color: CustomColor.colorBgVoteCast,
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: CustomColor.colorBgVoteCast,
                        child: _buildOperationVotes(),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: CustomColor.colorBgVoteCast,
                        child: _buildDeductedTokens(),
                      ),
                    ),
                    Expanded(flex: 4, child: _buildSummary())
                  ],
                ),
              ),
            ),
            Visibility(
              child: Loader(),
              visible: isLoading,
            )
          ],
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
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
      title: Text(
        AppString.voteCast.tr.toUpperCase(),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
    );
  }

  _buildOperationVotes() {
    return Column(
      children: [
        SizedBox(height: 16),
        Text(
          AppString.noOfVotes.tr,
          style: TextStyles.textStyleRegular.apply(color: Colors.black),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: CustomColor.colorBorder),
                borderRadius: BorderRadius.circular(5)),
            child: Row(
              children: [
                IconButton(
                    splashRadius: 1,
                    onPressed: () => decrementmethod(),
                    icon: Icon(
                      Icons.remove,
                      size: 30,
                    )),
                Container(
                  color: CustomColor.colorBgVoteCast,
                  width: 1,
                  height: 40,
                ),
                Spacer(),
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                    onTap: () {
                      if (textController.text == "1") textController.clear();
                    },
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    showCursor: false,
                    style: TextStyles.textStyleRegular
                        .apply(color: Colors.black, fontSizeFactor: 1.7),
                  ),
                ),
                /*Text(
                  textController.text,
                  style: TextStyles.textStyleRegular
                      .apply(color: Colors.black, fontSizeFactor: 1.7),
                ),*/
                Spacer(),
                Container(
                  color: CustomColor.colorBgVoteCast,
                  width: 1,
                  height: 40,
                ),
                IconButton(
                    splashRadius: 1,
                    onPressed: () => incrementmethod(),
                    icon: Icon(
                      Icons.add,
                      size: 30,
                    )),
              ],
            ),
          ),
        ),
        Text(
          AppString.tokensPerVotes.tr,
          style: TextStyles.textStyleRegular.apply(fontSizeFactor: 0.93),
        ),
      ],
    );
  }

  _buildDeductedTokens() {
    return Column(
      children: [
        RichText(
          text: TextSpan(
              text:
                  "${textController.text.isEmpty ? 0 : int.parse(textController.text) * 500}",
              style: TextStyles.textStyleRegular
                  .apply(fontSizeFactor: 3, color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: AppString.tos.tr,
                  style: TextStyles.textStyleRegular.apply(fontSizeFactor: 1.3),
                ),
              ]),
        ),
        SizedBox(height: 16),
        Text(
          AppString.tobeDecducted.tr,
          style: TextStyles.textStyleRegular.apply(fontSizeFactor: 0.93),
        ),
      ],
    );
  }

  _buildSummary() {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.artistName,
            style: TextStyles.textStyleSemiBold
                .apply(fontSizeFactor: 1.35, color: CustomColor.colorUserName),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  AppString.beat.tr + "${widget.beatName}",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.textStyleRegular
                      .apply(color: CustomColor.colorUserName),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  AppString.vote.tr + " # : ${textController.text}",
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.textStyleRegular
                      .apply(color: CustomColor.colorUserName),
                ),
              )
            ],
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () {
              if (widget.maxVote > int.parse(textController.text)) {
                _submitVote();
              } else {
                language == "한국어"
                    ? snackBar(
                        "거래당 한도를 초과했습니다. ${widget.maxVote} 보다 작은 숫자를 입력하세요")
                    : snackBar(
                        "${AppString.maxVoteReached.tr} ${widget.maxVote}");
                // snackBar("${AppString.maxVoteReached.tr}");
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)), backgroundColor: CustomColor.colorYellow,
              minimumSize: Size(MediaQuery.of(context).size.width, 50),
            ),
            child: Text(
              AppString.submt.tr,
              style: TextStyles.textStyleSemiBold.apply(color: Colors.black),
            ),
          )
        ],
      ),
    );
  }

  void incrementmethod() {
    setState(() {
      textController.text = (int.parse(textController.text) + 1).toString();
    });
  }

  void decrementmethod() {
    setState(() {
      if (int.parse(textController.text) <= 1) {
        return;
      } else {
        textController.text = (int.parse(textController.text) - 1).toString();
      }
    });
  }

  _submitVote() async {
    setState(() {
      isLoading = true;
    });
    var result = widget.type == "s"
        ? await service.submitVotingSingVideo(
            widget.videoId,
            widget.artistName,
            widget.beatName,
            widget.videoName,
            widget.type,
            int.parse(textController.text))
        : await service.submitVotingDanceVideo(
            widget.videoId,
            widget.artistName,
            widget.beatName,
            widget.videoName,
            widget.type,
            int.parse(textController.text));
    setState(() {
      isLoading = false;
    });
    if (result != null) {
      if (result["status"] == "success") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => VotingSubmitted(
                    vote: textController.text, artistName: widget.artistName)));
      } else if (result["status"] == "failure") {
        Navigator.push(context, MaterialPageRoute(builder: (_) => BuyToken()));
      }
    }
  }

  snackBar(String? message) {
    return Fluttertoast.showToast(
        msg: message!.tr,
        backgroundColor: Colors.black,
        textColor: Colors.white);
  }

  _getPref() {
    setState(() {
      language = HiveStore().get(Keys.language);
    });
  }
}
