import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/Store/HiveStore.dart';
import 'package:titosapp/screens/dashboard/HomeScreen.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';

class VotingSubmitted extends StatefulWidget {
  const VotingSubmitted(
      {Key? key, required this.vote, required this.artistName})
      : super(key: key);
  final String vote;
  final String artistName;

  @override
  _VotingSubmittedState createState() => _VotingSubmittedState();
}

class _VotingSubmittedState extends State<VotingSubmitted> {
  HiveStore? prefs;
  String language = "";

  @override
  void initState() {
    _getPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("Language" "$language");
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          AppString.voteCast.tr.toUpperCase(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 1,
            color: CustomColor.dividecolr,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: language == "한국어"
                    ? _buildSuccessKorean()
                    : language == "English"
                        ? _buildSuccess()
                        : _buildSuccessFrench(),
              )
            ],
          ),
        ],
      ),
    );
  }

  _buildSuccess() {
    return Column(
      children: <Widget>[
        Icon(
          Icons.check_circle_outline_rounded,
          color: Colors.white,
          size: 80,
        ),
        SizedBox(height: 40),
        Text(
          widget.vote +
              " ${AppString.vote.tr}${int.parse(widget.vote) > 1 ? "s" : ""}",
          style: TextStyles.textStyleSemiBold.apply(fontSizeFactor: 1.35),
        ),
        Text(
          AppString.voteSuccessCasted.tr,
          style: TextStyles.textStyleSemiBold.apply(fontSizeFactor: 1.35),
        ),
        SizedBox(height: 20),
        Text(
          widget.artistName,
          style: TextStyles.textStyleSemiBold.apply(fontSizeFactor: 1.35),
        ),
        SizedBox(height: 20),
        _buildCloseButton()
      ],
    );
  }

  _buildSuccessKorean() {
    return Column(
      children: <Widget>[
        Icon(
          Icons.check_circle_outline_rounded,
          color: Colors.white,
          size: 80,
        ),
        SizedBox(height: 40),
        Text(
          widget.artistName,
          style: TextStyles.textStyleSemiBold.apply(fontSizeFactor: 1.35),
        ),
        Text(
          "에게 성공적으로",
          style: TextStyles.textStyleSemiBold.apply(fontSizeFactor: 1.35),
        ),
        Text(
          " ${int.parse(widget.vote)}",
          style: TextStyles.textStyleSemiBold.apply(fontSizeFactor: 1.35),
        ),
        Text(
          " 표를 투표했습니다",
          style: TextStyles.textStyleSemiBold.apply(fontSizeFactor: 1.35),
        ),
        SizedBox(height: 20),
        _buildCloseButton()
      ],
    );
  }

  _buildSuccessFrench() {
    return Column(
      children: <Widget>[
        Icon(
          Icons.check_circle_outline_rounded,
          color: Colors.white,
          size: 80,
        ),
        SizedBox(height: 40),
        Text(
          widget.vote +
              " ${AppString.vote.tr}${int.parse(widget.vote) > 1 ? "s" : ""}",
          style: TextStyles.textStyleSemiBold.apply(fontSizeFactor: 1.35),
        ),
        Text(
          int.parse(widget.vote) > 1
              ? "ont été attribués avec succès à "
              : "a été attribué avec succès à ",
          style: TextStyles.textStyleSemiBold.apply(fontSizeFactor: 1.35),
        ),
        SizedBox(height: 20),
        Text(
          widget.artistName,
          style: TextStyles.textStyleSemiBold.apply(fontSizeFactor: 1.35),
        ),
        SizedBox(height: 20),
        _buildCloseButton()
      ],
    );
  }

  _buildCloseButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
            (Route<dynamic> route) => false);
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), backgroundColor: CustomColor.colorYellow,
        minimumSize: Size(MediaQuery.of(context).size.width / 1.7, 50),
      ),
      child: Text(
        AppString.close.tr,
        style: TextStyles.textStyleSemiBold.apply(color: Colors.black),
      ),
    );
  }

  _getPref() {
    setState(() {
      language = HiveStore().get(Keys.language);
    });
  }
}
