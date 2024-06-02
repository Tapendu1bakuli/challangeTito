import 'package:flutter/material.dart';
import 'package:titosapp/Store/HiveStore.dart';
import 'package:titosapp/languages/LocalizationService.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/widgets/BottomTextWidget.dart';
import 'package:titosapp/widgets/CustomOutlinedButton.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: CustomColor.myCustomYellow,
            ),
            BottomTextWidget(),
            _buildLanguageList(),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 32),
                  Container(
                    height: MediaQuery.of(context).size.height / 4,
                    width: MediaQuery.of(context).size.width / 1.5,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/logo.png"),
                        // fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildLanguageList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: LocalizationService.languages.length,
      itemBuilder: (BuildContext context, int index) {
        var model = LocalizationService.languages[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: CustomOutlinedButton(
              text: "$model".toUpperCase(),
              widthFactor: 1,
              onTap: () {
                setState(() {
                  HiveStore().put(Keys.language, model);
                  LocalizationService().changeLocale(model);
                });

                _navigate();
              }),
        );
      },
      separatorBuilder: (BuildContext context, int index) =>
          SizedBox(height: 28),
    );
  }

  _navigate() {
    Navigator.pushReplacementNamed(
      context,
      "/Login",
    );
  }
}
