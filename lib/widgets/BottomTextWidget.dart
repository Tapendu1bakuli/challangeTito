import 'package:flutter/material.dart';

class BottomTextWidget extends StatelessWidget {
  const BottomTextWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.transparent,
        height: MediaQuery.of(context).size.height / 9,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Column(children: <Widget>[
          Text(
            'A talent should never be hidden',
            style: TextStyle(
                color: Colors.black,
                fontStyle: FontStyle.italic,
                fontFamily: "Calibre",
                fontWeight: FontWeight.w600),
          ),
          Container(
            height: 15,
          ),
          RichText(
            text: TextSpan(
                text: 'My ',
                style: TextStyle(
                  fontFamily: "Calibre",
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Ti',
                    style: TextStyle(
                      fontFamily: "Calibre",
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'me ',
                    style: TextStyle(
                      fontFamily: "Calibre",
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                  TextSpan(
                    text: 'To S',
                    style: TextStyle(
                      fontFamily: "Calibre",
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'hine',
                    style: TextStyle(
                      fontFamily: "Calibre",
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                ]),
          ),
        ]),
        // ),
      ),
    );
  }
}
