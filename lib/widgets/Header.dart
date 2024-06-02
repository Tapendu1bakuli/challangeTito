import 'package:flutter/material.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';

class Header extends StatelessWidget {
  Header();

  Widget build(BuildContext _context) {
    return RichText(
      text: TextSpan(
          text: 'My',
          style: TextStyles.textStyleTitosTitle,
          children: <TextSpan>[
            TextSpan(
              text: '.',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: CustomColor.myCustomYellowDark,
                  fontSize: 35),
            ),
            TextSpan(
              text: 'Tit',
              style: TextStyles.textStyleTitosTitle,
            ),
            TextSpan(
              text: 'os',
              style: TextStyles.textStyleTitosTitle
                  .apply(color: CustomColor.myCustomYellowDark),
            )
          ]),
    );
  }
}
