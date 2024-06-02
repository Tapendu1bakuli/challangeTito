import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/apiService/PaymentServices.dart';
import 'package:titosapp/model/PaymentAccountModel.dart';
import 'package:titosapp/model/UserModel.dart';
import 'package:titosapp/screens/dashboard/MobileMoneyList.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';
import 'package:titosapp/util/localStorage.dart';
import 'package:titosapp/widgets/CustomTextField.dart';
import 'package:titosapp/widgets/Loader.dart';
import 'package:titosapp/widgets/Visibility.dart';

class PaymentAccount extends StatefulWidget {
  @override
  PaymentAccountState createState() => new PaymentAccountState();
  bool isFromHome;

  PaymentAccount({this.isFromHome = true});
}

class PaymentAccountState extends State<PaymentAccount> {
  PaymentService service = new PaymentService();
  PaymentAccountModel? accounts;
  bool isLoading = true;
  List<PaymentAccountTypes> accountTypes = [];
  List<MobileMoney> mobileMoney = [];

  PaymentAccountTypes? selectedAccountType;
  MobileMoney? selectedMobileAccountType = MobileMoney(
      id: 0,
      isMobileSelected: false,
      logoPath: '',
      parrentId: 0,
      paymentTypeDescription: '',
      paymentTypeName: '',
      status: 0);

  TextEditingController accountTypeController = TextEditingController(text: "");
  var localStorage = new LocalHiveStorage();
  String payment_account_id = "0";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CustomColor.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            AppString.payment_Account_Header.tr,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
          leading: IconButton(
            icon: new Icon(
              Icons.arrow_back_ios,
              color: CustomColor.myCustomYellow,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        bottomNavigationBar: Container(
            color: Colors.black,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 6.5,
            child: _buildSaveButton()
            /*  CustomVisibility(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Image.asset('images/headphones.png'),
                          onPressed: () {},
                        ),
                      ),
                      visibility: VisibilityFlag.invisible), */
            /* GestureDetector(
                    onTap: () {
                      setState(() {
                        isLoading = true;
                      });
                      if (accountTypeController.text.isNotEmpty)
                        savePaymentAccount();
                      else {
                        setState(() {
                          isLoading = false;
                        });
                        snackBar(AppString.accountDetails);
                      }
                      //print('login');
                    },
                    child: Container(
                      color: CustomColor.myCustomYellow,
                      child: Text(
                        AppString.save,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            fontSize: 16),
                      ),
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    ),
                  ), */
            /*  CustomVisibility(
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios_sharp),
                      onPressed: () async {},
                      iconSize: 40,
                    ),
                    visibility: VisibilityFlag.invisible,
                  ), */
            ),
        body: GestureDetector(
          onTap: () {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          },
          child: ListView(
            physics: ClampingScrollPhysics(),
            children: [
              Stack(
                children: [
                  Column(
                    children: [
                      CustomVisibility(
                        child: GestureDetector(
                          child: Container(
                            child: Text(
                              AppString.skip.tr,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black),
                            ),
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/ChooseChallenge');
                          },
                        ),
                        visibility: (widget.isFromHome)
                            ? VisibilityFlag.visible
                            : VisibilityFlag.gone,
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 35, 0, 25),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppString.subhead_Account_Type.tr,
                          style: TextStyles.textStyleSemiBold
                              .apply(color: CustomColor.colorTextHint),
                        ),
                      ),
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.all(0),
                        itemCount: accountTypes.length,
                        itemBuilder: (BuildContext ctxt, int index) => Column(
                          children: [
                            ListTile(
                              onTap: () {
                                setState(() {
                                  accountTypeController.text =
                                      int.parse(payment_account_id) ==
                                              accountTypes[index].id
                                          ? getValues().toString()
                                          : "";
                                  print("object" +
                                      accountTypes[index].paymentTypeDescription);
                                  for (int i = 0; i < accountTypes.length; i++) {
                                    accountTypes[i].isSelected = false;
                                  }
                                  accountTypes[index].isSelected =
                                      !accountTypes[index].isSelected!;
                                  mobileMoney = accountTypes[index].mobileMoney;

                                  selectedAccountType = accountTypes[
                                      accountTypes.indexWhere((element) =>
                                          element.isSelected == true)];
                                });
                                if (accountTypes[index].isSelected == true &&
                                    accountTypes[index].paymentTypeName ==
                                        "Mobile Money") {
                                  accountTypeController.text = "";
                                  // _showDialog(index);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                    print(
                                        "I  ${selectedMobileAccountType!.isMobileSelected}");
                                    print("sel" +
                                        "${selectedMobileAccountType!.paymentTypeDescription}");

                                    return MobileMoneyList(
                                      model: accountTypes[index].mobileMoney,
                                      selected: selectedMobileAccountType!,
                                    );
                                  })).then((value) {
                                    if (value != null) {
                                      setState(() {
                                        accountTypeController.text = "";
                                        selectedMobileAccountType = value;
                                      });
                                    }
                                  });
                                }
                              },
                              // tileColor: accountTypes[index].isSelected!
                              //     ? CustomColor.colorGrey
                              //     : Colors.white,
                              leading: CachedNetworkImage(
                                width: 50,
                                height: 50,
                                imageUrl: accountTypes[index].logoPath,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  margin: EdgeInsets.all(8),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                  color: CustomColor.colorYellow,
                                )),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              title: Text(
                                accountTypes[index].paymentTypeName.tr.toString(),
                                style: TextStyles.textStyleRegular,
                              ),
                              trailing: mobileMoney.length > 0
                                  ? Visibility(
                                      visible: accountTypes[index].id ==
                                          mobileMoney[0].parrentId,
                                      child: Offstage(),
                                    )
                                  : mobileMoney.length < 0 ||
                                          accountTypes[index].isSelected!
                                      ? Icon(
                                          Icons.check_circle_outline_outlined,
                                          color: Colors.green,
                                        )
                                      : Offstage(),
                              /*  trailing: Checkbox(
                              activeColor: Colors.black.withOpacity(0.3),
                                checkColor: Colors.black,
                                onChanged: (bool? value) {
                                  if (value!) {
                                    setState(() {
                                      accountTypeController.text = "";
                                      for (int i = 0; i < accountTypes.length; i++) {
                                        accountTypes[i].isSelected = false;
                                      }
                                      accountTypes[index].isSelected = value;

                                      selectedAccountType = accountTypes[
                                          accountTypes.indexWhere((element) =>
                                              element.isSelected == true)];
                                    });
                                  }
                                },
                                value: accountTypes[index].isSelected,

                              ), */
                            ),
                            if (selectedAccountType != null &&
                                accountTypes[index].isSelected == true)
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: CustomTextField(
                                    hintText:
                                        (accountTypes[1].isSelected == false)
                                            ? selectedAccountType!
                                                .paymentTypeDescription.tr
                                                .toString()
                                            : selectedMobileAccountType!
                                                    .paymentTypeDescription
                                                    .isNotEmpty
                                                ? selectedMobileAccountType!
                                                    .paymentTypeDescription.tr
                                                    .toString()
                                                : selectedAccountType!
                                                    .paymentTypeDescription.tr
                                                    .toString(),
                                    textController: accountTypeController,
                                    suffixIcon: Offstage(),
                                    focusNode: FocusNode()),
                              ),
                          ],
                        ),
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            indent: 20,
                            endIndent: 20,
                            color: CustomColor.colorDividerPayment,
                          );
                        },
                      ),
                      SizedBox(height: 40),
                      // if (mobileMoney.length>0)

                      /* Container(
                        padding: EdgeInsets.all(25),
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          controller: accountTypeController,
                          decoration: InputDecoration(
                            hintText: AppString.enterYour +
                                selectedAccountType!.paymentTypeDescription
                                    .toString(),
                            fillColor: CustomColor.customGrey,
                            filled: true,
                            hintStyle: TextStyle(
                                letterSpacing: 0,
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.normal),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                  color: CustomColor.myCustomBlack, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                  color: CustomColor.myCustomBlack, width: 2),
                            ),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(
                                  color: CustomColor.myCustomBlack,
                                  width: 2,
                                )),
                          ),
                        ),
                      ), */
                    ],
                  ),
                  Visibility(
                    child: Loader(),
                    visible: isLoading,
                  )
                ],
              )
            ],
          ),
        ));
  }

  getAccountTypes() async {
    accounts = await service.getAccountTypes();

    if (accounts != null) {
      accountTypes = accounts!.paymentAccountTypes;
      if (payment_account_id == "0") {
        accountTypes[0].isSelected = true;
        selectedAccountType = accountTypes[
            accountTypes.indexWhere((element) => element.isSelected == true)];
      } else {
        accountTypes[accountTypes.indexWhere(
                (element) => element.id == int.parse(payment_account_id))]
            .isSelected = true;
        selectedAccountType = accountTypes[accountTypes.indexWhere(
            (element) => element.id == int.parse(payment_account_id))];
      }

      setState(() {
        isLoading = false;
      });
      print(accounts);
    }
  }

  getValues() async {
    String paymentAccountAddress =
        await localStorage.getValue("payment_account_address");
    payment_account_id = await localStorage.getValue("payment_account_id");

    if (paymentAccountAddress.isNotEmpty) {
      accountTypeController.text = paymentAccountAddress;
    }
    return paymentAccountAddress;
  }

  @override
  void initState() {
    getValues();
    getAccountTypes();
    super.initState();
  }

  snackBar(String? message) {
    return Fluttertoast.showToast(
        msg: message!.tr,
        backgroundColor: Colors.black,
        textColor: Colors.white);
  }

  void savePaymentAccount() async {
    UserModel result = await service.paymentAccountSave(
        (selectedAccountType!.id != null)
            ? selectedAccountType!.id
            : selectedMobileAccountType!.id,
        accountTypeController.text,mobileMoneyId: selectedMobileAccountType!.id.toString());

    setState(() {
      isLoading = false;
    });

    print("AD: ${result.msg}");
    if (result.msg == AppString.payment_Account_Save) {
      localStorage.updateValue(
          "payment_account_id", result.paymentAccountId.toString());
      localStorage.updateValue(
          "payment_account_address", accountTypeController.text.toString());

      if (widget.isFromHome) {
        _showDialog();
        // Navigator.pushNamed(context, '/ChooseChallenge');
      } else {
        _showDialog();
        // Navigator.pop(context);
      }
    } else {
      snackBar(result.msg);
    }
  }

  Widget _buildSaveButton() {
    return Container(
      alignment: Alignment.center,
      width: double.maxFinite,
      padding: EdgeInsets.all(20),
      color: Colors.black,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            isLoading = true;
          });
          if (accountTypeController.text.isNotEmpty)
            savePaymentAccount();
          else {
            setState(() {
              isLoading = false;
            });
            snackBar(AppString.accountDetails);
          }
        },
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), backgroundColor: CustomColor.colorYellow,
          minimumSize: Size(MediaQuery.of(context).size.width, 50),
        ),
        child: Text(
          AppString.saveLower.tr,
          style: TextStyles.textStyleSemiBold.apply(color: Colors.black),
        ),
      ),
    );
  }

  _showDialog() {
    showGeneralDialog(
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) => SafeArea(
              child: Scaffold(
                  backgroundColor: Colors.black,
                  appBar: AppBar(
                    backgroundColor: Colors.black,
                    centerTitle: true,
                    title: Text(
                      AppString.payment_Account_Header.tr,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    automaticallyImplyLeading: false,
                  ),
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppString.payment_Account_Save.tr,
                        style: TextStyles.textStyleSemiBold,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)), backgroundColor: CustomColor.colorYellow,
                            minimumSize:
                                Size(MediaQuery.of(context).size.width, 50),
                          ),
                          child: Text(
                            AppString.close.tr,
                            style: TextStyles.textStyleSemiBold
                                .apply(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  )),
            ));
  }
}
