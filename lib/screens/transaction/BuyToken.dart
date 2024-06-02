import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/screens/wallet/Wallet.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/Assets.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';

class BuyToken extends StatefulWidget {
  const BuyToken({Key? key}) : super(key: key);

  @override
  _BuyTokenState createState() => _BuyTokenState();
}

class _BuyTokenState extends State<BuyToken> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.colorBgTransaction,
      appBar: _appBar(context),
      body: Column(
        children: [
          SizedBox(height: 32),
          Image.asset(Assets.transaction_chain, width: 80),
          SizedBox(height: 20),
          Expanded(
              child: Container(
            padding: EdgeInsets.all(28),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppString.notEnoughTokens.tr,
                  textAlign: TextAlign.center,
                  style: TextStyles.textStyleRegular,
                ),
                SizedBox(height: 64),
                _buildBuyTokenButton()
              ],
            ),
          ))
        ],
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      centerTitle: true,
      title: Text(
        AppString.transaction.tr.toUpperCase(),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      automaticallyImplyLeading: false,
      actions: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Icon(Icons.close),
          ),
        )
      ],
    );
  }

  _buildBuyTokenButton() {
    return ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => Wallet()));
        },
        style: ElevatedButton.styleFrom(
            minimumSize: Size(double.maxFinite, 50), backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: Text(
          AppString.buyToken.tr,
          style: TextStyles.textStyleSemiBold,
        ));
  }
}
