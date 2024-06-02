import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/screens/wallet/Wallet.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';

class TransactionSuccessful extends StatefulWidget {
  final bool transfer;

  const TransactionSuccessful({Key? key, this.transfer = false})
      : super(key: key);

  @override
  _TransactionSuccessfulState createState() => _TransactionSuccessfulState();
}

class _TransactionSuccessfulState extends State<TransactionSuccessful> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          widget.transfer
              ? AppString.transferToken.tr.toUpperCase()
              : AppString.tokenTransfer.tr.toUpperCase(),
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
                child: _buildSuccess(),
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
          widget.transfer
              ? AppString.tokenTransferred.tr
              : AppString.succesTokenTransfer.tr,
          textAlign: TextAlign.center,
          style: TextStyles.textStyleSemiBold.apply(fontSizeFactor: 1.35),
        ),
        SizedBox(height: 24),
        _buildCloseButton()
      ],
    );
  }

  _buildCloseButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        if (widget.transfer) {
          Navigator.pop(context);
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Wallet()),
        );
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
}
