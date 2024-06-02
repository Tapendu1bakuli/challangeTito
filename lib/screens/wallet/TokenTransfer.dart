import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/Store/HiveStore.dart';
import 'package:titosapp/apiService/MediaServices.dart';
import 'package:titosapp/model/wallet/UserDetailsModel.dart';
import 'package:titosapp/screens/transaction/ValidateTransaction.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';
import 'package:titosapp/widgets/Loader.dart';

import '../../util/utils.dart';

class TokenTransfer extends StatefulWidget {
  const TokenTransfer({Key? key}) : super(key: key);

  @override
  _TokenTransferState createState() => _TokenTransferState();
}

class _TokenTransferState extends State<TokenTransfer>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  late TextEditingController tosController = TextEditingController();

  //late TextEditingController searchController = TextEditingController();

  MediaService service = MediaService();
  int _balance = 0;
  int _tosToken = 0;
  String _walletId = "";
  UserDetailsModel userList =
      UserDetailsModel(msg: "", status: "", userList: <UserList>[]);
  late UserList selectedUser = UserList.empty();
  late FocusNode focusNode = FocusNode();
  bool noUser = false;
  num minTopUp = 0;
  num maxTopUp = 0;
  num minTransfer = 0;
  num maxTransfer = 0;
  late List<UserList> _suggestions = <UserList>[];

  HiveStore? prefs;
  String language = "";

  @override
  void initState() {
    //focusNode.addListener(getFocusAndSetText);
    _fetchWalletDetails();
    _getPref();
    super.initState();
  }

  /*getFocusAndSetText() {
    if (focusNode.hasFocus && searchController.text.isEmpty) {
      searchController.text = "#TOS";
    }
  }*/

  @override
  void dispose() {
    Fluttertoast.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(context),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            ListView(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              children: [
                Card(
                  color: CustomColor.colorBgTokenTransfer,
                  margin: EdgeInsets.zero,
                  child: ListView(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 6,
                        color: CustomColor.colorBgTokenTransfer,
                        child: _buildShowBalance(),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 3,
                        width: MediaQuery.of(context).size.width,
                        color: CustomColor.white,
                        child: _findUserWithWalletID(),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 4,
                        width: MediaQuery.of(context).size.width,
                        color: CustomColor.colorBgVoteCast,
                        child: _buildOperateToken(),
                      ),
                      _buildBuyButton()
                      /*Container(
                        height: MediaQuery.of(context).size.height / 6 -20,
                        width: MediaQuery.of(context).size.width,
                        color: CustomColor.colorBgVoteCast,
                        child: _buildBuyButton(),
                      ),*/
                    ],
                  ),
                ),
              ],
            ),
            Visibility(
              child: Loader(
                text: "",
              ),
              visible: isLoading,
            )
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
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
        AppString.wallet.tr.toUpperCase(),
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
    );
  }

  Widget _buildShowBalance() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppString.transferToken.tr,
            style: TextStyles.textStyleSemiBold.apply(color: Colors.black),
          ),
          SizedBox(height: 4),
          _walletId.toString().isEmpty
              ? Offstage()
              : Text(
                  "From ${_walletId.toString()}",
                  style:
                      TextStyles.textStyleRegular.apply(fontSizeFactor: 0.93),
                ),
          Expanded(
            child: RichText(
              text: TextSpan(
                  text: _balance.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},'),
                  style: TextStyles.textStyleLight
                      .apply(fontSizeFactor: 2.5, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                      text: " ${AppString.tos.tr}",
                      style: TextStyles.textStyleRegular.apply(
                        fontSizeFactor: 1.3,
                      ),
                    ),
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _findUserWithWalletID() {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppString.to.tr,
            style: TextStyles.textStyleRegular.apply(
              fontSizeFactor: 0.50,
              fontSizeDelta: 12,
            ),
          ),
          SizedBox(height: 20),
          Autocomplete<UserList>(
            fieldViewBuilder: (BuildContext context,
                TextEditingController fieldTextEditingController,
                FocusNode fieldFocusNode,
                VoidCallback onFieldSubmitted) {
              if (fieldFocusNode.hasFocus) {
                fieldTextEditingController.text =
                    fieldTextEditingController.text == ""
                        ? "#TOS"
                        : fieldTextEditingController.text;
                fieldTextEditingController.selection =
                    TextSelection.fromPosition(TextPosition(
                        offset: fieldTextEditingController.text.length));
              }
              return TextField(
                controller: fieldTextEditingController,
                focusNode: fieldFocusNode,
                decoration: InputDecoration(
                  fillColor: CustomColor.colorBgVoteCast,
                  filled: true,
                  hintText: AppString.tokenTransferLabel.tr,
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (selectedUser.walletId.isEmpty ||
                          selectedUser.walletId == "wallet_id") {
                        FocusScope.of(context).unfocus();
                        if (fieldTextEditingController.text.isNotEmpty &&
                            fieldTextEditingController.text.toLowerCase() !=
                                "#TOS".toLowerCase())
                          _fetchUserDetails(fieldTextEditingController.text);
                      }
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              );
            },
            optionsViewBuilder: (context, onAutoCompleteSelect, options) {
              return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: Theme.of(context).primaryColorLight,
                    elevation: 4.0,
                    // size works, when placed here below the Material widget
                    child: Container(
                        height: options.length > 2
                            ? MediaQuery.of(context).size.width / 2
                            : null,
                        width: MediaQuery.of(context).size.width - 40,
                        child: Scrollbar(
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(8.0),
                            itemCount: options.length,
                            separatorBuilder: (context, i) {
                              return Divider();
                            },
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                onTap: () {
                                  setState(() {
                                    FocusScope.of(context).unfocus();
                                    userList.userList.clear();
                                    options.elementAt(index).selected = true;
                                    userList.userList
                                        .add(options.elementAt(index));
                                    selectedUser = options.elementAt(index);
                                  });
                                },
                                //selected: options.elementAt(index).selected,
                                leading: CircleAvatar(
                                  child: Icon(Icons.done),
                                  backgroundColor: Colors.white,
                                ),
                                title: Text(
                                    "${options.elementAt(index).firstName} ${options.elementAt(index).lastName}"),
                              );
                            },
                          ),
                        )),
                  ));
            },
            optionsBuilder: (TextEditingValue value) {
              // When the field is empty
              if (value.text.isEmpty) {
                return [];
              }

              if (value.text == "#TOS") {
                return [];
              }

              // The logic to find out which ones should appear
              return _suggestions.where((suggestion) => suggestion.walletId
                  .toLowerCase()
                  .contains(value.text.toLowerCase()));
            },
            onSelected: (value) {
              print("VAL: $value");
              setState(() {
                userList.userList.clear();
                value.selected = true;
                userList.userList.add(value);
                selectedUser = value;
              });
            },
          ),
          SizedBox(height: 10),
          noUser
              ? Center(child: Text(AppString.noUser.tr))
              : Expanded(
                  child: ListView.separated(
                  physics: ClampingScrollPhysics(),
                  itemCount: userList.userList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        setState(() {
                          userList.userList[index].selected =
                              !(userList.userList[index].selected);
                          selectedUser = userList.userList[index];
                        });
                      },
                      selected: userList.userList[index].selected,
                      leading: userList.userList[index].selected
                          ? Icon(
                              Icons.check_circle_outline_outlined,
                              size: 20,
                              color: Colors.black,
                            )
                          : Offstage(),
                      title: Text(
                          "${userList.userList[index].firstName} ${userList.userList[index].lastName}"),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                )),
        ],
      ),
    );
  }

  Widget _buildOperateToken() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppString.amount.tr,
          style: TextStyles.textStyleSemiBold.apply(color: Colors.black),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: CustomColor.colorBorder),
                borderRadius: BorderRadius.circular(5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                        splashRadius: 1,
                        onPressed: () => decrementMethod(),
                        icon: Icon(
                          Icons.remove,
                          size: 30,
                        )),
                    Container(
                      color: CustomColor.colorBgVoteCast,
                      width: 1,
                      height: 40,
                    ),
                  ],
                ),
                DropdownButton(
                  iconSize: 0.0,
                  underline: SizedBox.shrink(),
                  alignment: Alignment.center,
                  style: TextStyles.textStyleRegular
                      .apply(color: Colors.black, fontSizeFactor: 1.7),
                  hint: RichText(
                    text: TextSpan(
                        text: tosController.text,
                        style: TextStyles.textStyleRegular
                            .apply(color: Colors.black, fontSizeFactor: 1.7),
                        children: <TextSpan>[
                          TextSpan(
                            text: " ${AppString.tos.tr}",
                            style: TextStyles.textStyleRegular
                                .apply(fontSizeFactor: 1.3),
                          ),
                        ]),
                  ),
                  items: <String>[
                    "10000 TOS",
                    "20000 TOS",
                    "50000 TOS",
                    "100000 TOS"
                  ].map(
                    (val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(
                          val,
                          textAlign: TextAlign.end,
                          style: TextStyles.textStyleRegular
                              .apply(color: Colors.black, fontSizeFactor: 1.7),
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: (String? val) {
                    setState(
                      () {
                        tosController.text =
                            val.toString().replaceAll(" TOS", "");
                      },
                    );
                  },
                ),
                Row(
                  children: [
                    Container(
                      color: CustomColor.colorBgVoteCast,
                      width: 1,
                      height: 40,
                    ),
                    IconButton(
                        splashRadius: 1,
                        onPressed: () => incrementMethod(),
                        icon: Icon(
                          Icons.add,
                          size: 30,
                        )),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBuyButton() {
    return Container(
      alignment: Alignment.center,
      width: double.maxFinite,
      padding: EdgeInsets.all(20),
      color: Colors.black,
      child: ElevatedButton(
        onPressed: () {
          if (selectedUser.selected) {
            if (_balance >= int.parse(tosController.text)) {
              if (minTransfer <= int.parse(tosController.text) &&
                  maxTransfer >= int.parse(tosController.text)) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ValidateTransaction(
                              tosToken: tosController.text,
                              userId: selectedUser.id.toString(),
                            )));
              } else if (maxTransfer <= int.parse(tosController.text)) {
                snackBar(language == "한국어"
                    ? "거래당 최대 $maxTransfer TOS까지만 전송할 수 있습니다."
                    : language == "FRANÇAIS"
                        ? "Vous pouvez seulement transférer jusqu’à $maxTransfer TOS par transaction."
                        : "You can only transfer up to $maxTransfer TOS per transaction.");
              } else {
                snackBar(language == "한국어"
                    ? "$minTopUp ${AppString.minTopUpNotValidate.tr}."
                    : "${AppString.minTopUpNotValidate.tr} $minTopUp.");
              }
            } else {
              Fluttertoast.showToast(
                  gravity: ToastGravity.BOTTOM,
                  msg: AppString.walletValidation.tr,
                  backgroundColor: CustomColor.myCustomBlack,
                  textColor: Colors.white);
            }
          } else {
            Fluttertoast.showToast(
                gravity: ToastGravity.BOTTOM,
                msg: AppString.selectAUser.tr,
                backgroundColor: CustomColor.myCustomBlack,
                textColor: Colors.white);
          }
        },
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), backgroundColor: CustomColor.colorYellow,
          minimumSize: Size(MediaQuery.of(context).size.width, 50),
        ),
        child: Text(
          AppString.send.tr,
          style: TextStyles.textStyleSemiBold.apply(color: Colors.black),
        ),
      ),
    );
  }

  void incrementMethod() {
    setState(() {
      tosController.text =
          (int.parse(tosController.text) + _tosToken).toString();
    });
  }

  void decrementMethod() {
    setState(() {
      if (int.parse(tosController.text) <= _tosToken) {
        return;
      } else {
        tosController.text =
            (int.parse(tosController.text) - _tosToken).toString();
      }
    });
  }

  _fetchWalletDetails() async {
    setState(() {
      isLoading = true;
    });
    var parsed = await service.getWalletDetails();

    if (parsed != null) {
      setState(() {
        _balance = parsed["wallet_ballence"];
        _tosToken = parsed["tos_token"];
        _walletId = parsed["Wallet ID"];
        maxTransfer = int.parse(parsed["max_transfer"].toString());
        minTransfer = int.parse(parsed["min_transfer"].toString());
        maxTopUp = int.parse(parsed["max_topup"].toString());
        minTopUp = int.parse(parsed["min_topup"].toString());
        tosController = TextEditingController(text: _tosToken.toString());
        _suggestions = List.from(parsed["benefeshery_user_list"])
            .map((e) => UserList.fromJson(e))
            .toList();
        isLoading = false;
      });
    }
  }

  _fetchUserDetails(String text) async {
    setState(() {
      isLoading = true;
    });
    var parsed = await service.getUseDetailsWithWalletId(walletId: text);

    if (parsed != null) {
      userList = UserDetailsModel.fromJson(parsed);
      if (userList.userList.isEmpty) {
        setState(() {
          noUser = true;
        });
      } else {
        noUser = false;
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  _getPref() {
    setState(() {
      language = HiveStore().get(Keys.language);
    });
  }
}
