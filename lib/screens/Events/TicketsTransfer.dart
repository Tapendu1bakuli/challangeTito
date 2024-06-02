import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:titosapp/Store/HiveStore.dart';
import 'package:titosapp/apiService/MediaServices.dart';
import 'package:titosapp/model/Event/MyTIcketsResponseModel.dart';
import 'package:titosapp/model/wallet/UserDetailsModel.dart';
import 'package:titosapp/screens/Events/ticket_card.dart';
import 'package:titosapp/screens/transaction/ValidateTransaction.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';
import 'package:titosapp/widgets/Loader.dart';

class TicketsTransfer extends StatefulWidget {
  final Tickets ticketData;

  TicketsTransfer({Key? key, required this.ticketData}) : super(key: key);

  @override
  _TicketsTransferState createState() => _TicketsTransferState();
}

class _TicketsTransferState extends State<TicketsTransfer>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  late TextEditingController tosController = TextEditingController();

  //late TextEditingController searchController = TextEditingController();

  MediaService service = MediaService();
  num _balance = 0;
  num _tosToken = 0;
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

  late Tickets _ticketData;

  @override
  void initState() {
    //focusNode.addListener(getFocusAndSetText);
    _fetchWalletDetails();
    _getPref();
    super.initState();
    _ticketData = widget.ticketData;
  }

  /*getFocusAndSetText() {
    if (focusNode.hasFocus && searchController.text.isEmpty) {
      searchController.text = "#TOS";
    }
  }*/
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
                        height: MediaQuery.of(context).size.height / 2.5,
                        width: MediaQuery.of(context).size.width,
                        color: CustomColor.white,
                        child: _findUserWithWalletID(),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 3,
                        color: CustomColor.colorBgTokenTransfer,
                        child: TicketCard(
                          title: _ticketData.eventTitle,
                          subTitle:
                              "${AppString.Purchase.tr}: ${_ticketData.purchaseDate}",
                          price: "${_ticketData.amount} ${AppString.tos}",
                          expDate:
                              "${AppString.Expired.tr}: ${_ticketData.expireOn}",
                          validityStatus: _ticketData.ticketStatus.tr,
                          categoryName: _ticketData.category,
                          categorySeat: _ticketData.numberOfSets.toString(),
                          senderName: _ticketData.senderName.toString(),
                          receiverName: _ticketData.receiverName.toString(),
                        ),
                      ),
                      _buildBuyButton()
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
        AppString.MakeAGift.tr.toUpperCase(),
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      iconTheme: IconThemeData(color: CustomColor.myCustomYellow),
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
                                  backgroundColor: CustomColor.myCustomBlack,
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
                      leading: CircleAvatar(
                        child: Icon(Icons.done),
                        backgroundColor: CustomColor.myCustomBlack,
                      ),
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

  Widget _buildBuyButton() {
    return Container(
      alignment: Alignment.center,
      width: double.maxFinite,
      padding: EdgeInsets.all(20),
      color: Colors.black,
      child: ElevatedButton(
        onPressed: () {
          if (selectedUser.selected) {
            Map<String, dynamic> model = {
              "ticket_code": _ticketData.ticketCode,
              "receiver_user_id": selectedUser.id,
            };
            Get.to(() => ValidateTransaction(
                  page: "GiftTicket",
                  model: model,
                ));
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
