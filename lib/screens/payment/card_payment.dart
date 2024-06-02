import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titosapp/util/CustomColor.dart';

import '../../widgets/CustomTextFormField.dart';
import 'CardValidator/input_formatters.dart';
import 'CardValidator/payment_card.dart';

class CardPayment extends StatefulWidget {
  final TextEditingController numberController;
  final TextEditingController cvvController;
  final TextEditingController expiryDateController;

  CardPayment(
      {required this.numberController,
      required this.cvvController,
      required this.expiryDateController});

  @override
  _CardPaymentState createState() => _CardPaymentState();
}

class _CardPaymentState extends State<CardPayment> {
  String accessToken = "";
  bool dataLoaded = false;
  var _formKey = GlobalKey<FormState>();

  var _paymentCard = PaymentCard();
  var _autoValidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _paymentCard.type = CardType.Others;
    widget.numberController.addListener(_getCardTypeFrmNumber);
  }

  @override
  void dispose() {
    widget.numberController.removeListener(_getCardTypeFrmNumber);
    widget.numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Form(
          key: _formKey,
          autovalidateMode: _autoValidateMode,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(20),
            physics: ClampingScrollPhysics(),
            children: <Widget>[
              Text(
                "  AppString.cardDetails",
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 32),
              ),
              Container(
                child: Text(
                  " AppString.cardNumber",
                ),
              ),
              CustomTextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19),
                  CardNumberInputFormatter()
                ],
                textController: widget.numberController,
                hintText: "AppString.cardNumberDemo",
                icon: CardUtils.getCardIcon(_paymentCard.type),
                onSaved: (String? value) {
                  print('onSaved = $value');
                  print('Num controller has = ${widget.numberController.text}');
                  _paymentCard.number = CardUtils.getCleanedNumber(value!);
                },
                validator: CardUtils.validateCardNum,
              ),
              Container(
                height: MediaQuery.of(context).size.height / 32,
              ),
              Container(
                child: Text(
                  "AppString.cvv",
                ),
              ),
              CustomTextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                hintText: "AppString.cvvDemo",
                icon: Image.asset(
                  'assets/images/card/card_cvv.png',
                  width: 40.0,
                  color: CustomColor.myCustomBlack,
                ),
                validator: CardUtils.validateCVV,
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _paymentCard.cvv = int.parse(value!);
                },
                textController: widget.cvvController,
              ),
              Container(
                height: MediaQuery.of(context).size.height / 32,
              ),
              Container(
                child: Text(
                  "AppString.expDate",
                ),
              ),
              CustomTextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  CardMonthInputFormatter()
                ],
                hintText: " AppString.expDateDemo",
                icon: Image.asset(
                  'assets/images/card/calender.png',
                  width: 40.0,
                  color: CustomColor.myCustomBlack,
                ),
                validator: CardUtils.validateDate,
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  List<int> expiryDate = CardUtils.getExpiryDate(value!);
                  _paymentCard.month = expiryDate[0];
                  _paymentCard.year = expiryDate[1];
                },
                textController: widget.expiryDateController,
              ),
            ],
          )),
    );
  }

  /*  _paymentAPICall() {
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      setState(() {
        _autoValidateMode =
            AutovalidateMode.always; // Start validating on every change.
      });
      _showInSnackBar(AppString.cardValidationError);
    } else {
      form.save();
      // Encrypt and send send payment details to payment gateway
      //_showInSnackBar('Payment card is valid');
      setState(() {
        dataLoaded = true;
      });
      if (widget.rePay) {
        PaymentApiCall()
            .paymentRePayApiCall(
              widget.orderId,
              widget.priceEntered,
              widget.paymentType,
              accessToken,
              context,
              _scaffoldKey,
              cardNumber: widget.numberController.text,
              cvv: _paymentCard.cvv,
              expMonth: _paymentCard.month,
              expYear: _paymentCard.year,
            )
            .then((value) => setState(() {
                  dataLoaded = false;
                }));
      } else {
        PaymentApiCall()
            .paymentApiCall(
                widget.cities.subadminDetail!
                    .stationProductList![widget.indexToSend].id
                    .toString(),
                widget.priceEntered,
                widget.paymentType,
                accessToken,
                context,
                _scaffoldKey,
                cardNumber: widget.numberController.text,
                cvv: _paymentCard.cvv,
                expMonth: _paymentCard.month,
                expYear: _paymentCard.year,
                repay: widget.rePay)
            .then((value) => setState(() {
                  dataLoaded = false;
                }));
      }
    }
  } */

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(widget.numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._paymentCard.type = cardType;
    });
  }
}
