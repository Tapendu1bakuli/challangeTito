import 'package:flutter/material.dart';
import 'package:titosapp/screens/payment/card_payment.dart';

class RenderWidgetByType extends StatelessWidget {
  final String type;
  final numberController;
  final cvvController;
  final expiryDateController;

  RenderWidgetByType(
      {required this.numberController,
      required this.cvvController,
      required this.expiryDateController,
      required this.type});

  @override
  Widget build(BuildContext context) {
    print("Ww${numberController.text}");
    switch (type) {
      case "card":
        return CardPayment(
          numberController: numberController,
          expiryDateController: expiryDateController,
          cvvController: cvvController,
        );

      default:
        return Container();
    }
  }
}
