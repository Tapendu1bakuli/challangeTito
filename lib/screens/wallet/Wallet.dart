import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:titosapp/Store/HiveStore.dart';
import 'package:titosapp/apiService/MediaServices.dart';
import 'package:titosapp/languages/LocalizationService.dart';
import 'package:titosapp/model/wallet/WalletHistoryModel.dart';
import 'package:titosapp/screens/transaction/ValidateTransaction.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/Assets.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';
import 'package:titosapp/widgets/Loader.dart';

import '../../util/utils.dart';
import 'TokenTransfer.dart';

class Wallet extends StatefulWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  bool isLoading = false;
  late TextEditingController textController = TextEditingController();
  late final TabController _tabController;
  MediaService service = MediaService();
  num _balance = 0;
  num _tosToken = 0;
  String _walletId = "";
  num _usd = 0;
  num minTopUp = 0;
  num maxTopUp = 0;
  num minTransfer = 0;
  num maxTransfer = 0;
  List<TransctionList> transctionList = <TransctionList>[];
  var _parsedDate;
  HiveStore? prefs;
  String language = "";

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
      if (_selectedTabIndex == 1) {
        _fetchWalletHistoryDetails();
      } else {
        _fetchWalletDetails();
      }
      print("Selected Index: " + _tabController.index.toString());
    });
    _fetchWalletDetails();
    _getPref();
    super.initState();
  }

  // @override
  // void didUpdateWidget(covariant Wallet oldWidget) {
  //   // TODO: implement didUpdateWidget
  //   super.didUpdateWidget(oldWidget);
  //   initState();
  // }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWallet(),
          Stack(
            children: [
              _buildWalletHistoryList(),
              Visibility(
                child: Loader(),
                visible: isLoading,
              )
            ],
          )
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final tab = TabBar(
        indicatorWeight: 4.0,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: CustomColor.colorYellow,
        controller: _tabController,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        tabs: <Tab>[
          Tab(
              icon: Text(
            AppString.balance.tr,
            style: TextStyles.textStyleSemiBold.apply(
                color: _selectedTabIndex == 0
                    ? CustomColor.myCustomYellow
                    : CustomColor.white),
          )),
          Tab(
              icon: Text(
            AppString.history.tr,
            style: TextStyles.textStyleSemiBold.apply(
                color: _selectedTabIndex == 1
                    ? CustomColor.myCustomYellow
                    : CustomColor.white),
          )),
        ]);
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
      bottom: PreferredSize(preferredSize: Size.fromHeight(55), child: tab),
    );
  }

  Widget _buildWallet() {
    return InkWell(
      onTap: () {
        dismissKeyboard(context);
      },
      child: Stack(
        children: [
          Card(
            color: Colors.black,
            margin: EdgeInsets.zero,
            child: ListView(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 6,
                  width: MediaQuery.of(context).size.width,
                  color: CustomColor.colorYellow,
                  child: _buildShowBalance(),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 5,
                  width: MediaQuery.of(context).size.width,
                  color: CustomColor.white,
                  child: _buildTopUPWallet(),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 3,
                  width: MediaQuery.of(context).size.width,
                  color: CustomColor.colorBgVoteCast,
                  child: _buildOperateToken(),
                ),
                _buildBuyButton()
              ],
            ),
          ),
          Visibility(
            child: Loader(),
            visible: isLoading,
          )
        ],
      ),
    );
  }

  Widget _buildShowBalance() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppString.acBalance.tr,
          style: TextStyles.textStyleSemiBold.apply(color: Colors.black),
        ),
        SizedBox(height: 4),
        Text(
          _walletId.toString(),
          style: TextStyles.textStyleRegular.apply(fontSizeFactor: 0.93),
        ),
        SizedBox(height: 8),
        RichText(
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
              text: _balance.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},'),
              style: TextStyles.textStyleLight
                  .apply(fontSizeFactor: 2.5, color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: " ${AppString.tos.tr}",
                  style: TextStyles.textStyleRegular.apply(fontSizeFactor: 1.3),
                ),
              ]),
        ),
      ],
    );
  }

  Widget _buildTopUPWallet() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppString.sendToken.tr,
          style: TextStyles.textStyleRegular.apply(
            fontSizeFactor: 0.50,
            fontSizeDelta: 12,
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => TokenTransfer()));
          },
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), backgroundColor: Colors.black,
            minimumSize: Size(MediaQuery.of(context).size.width / 2, 45),
          ),
          child: Text(
            AppString.send.tr,
            style: TextStyles.textStyleSemiBold.apply(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildOperateToken() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppString.topUpWallet.tr,
          style: TextStyles.textStyleRegular.apply(
            fontSizeFactor: 0.50,
            fontSizeDelta: 12,
          ),
        ),
        SizedBox(height: 20),
        Text(
          AppString.purchaseTOS.tr,
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
                        onPressed: () => decrementmethod(),
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
                        text: textController.text,
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
                        textController.text =
                            val.toString().replaceAll(" TOS", "");
                        _usd =
                            (int.parse(val.toString().replaceAll(" TOS", "")) /
                                    _tosToken)
                                .ceil();
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
                        onPressed: () => incrementmethod(),
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
        Text(
          AppString.usd.tr + " $_usd" + ".00",
          style: TextStyles.textStyleSemiBold
              .apply(fontSizeFactor: 1.2, color: Colors.black),
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
          if (minTopUp <= int.parse(textController.text) &&
              maxTopUp >= int.parse(textController.text)) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ValidateTransaction(
                          tosToken: textController.text,
                        )));
          } else if (maxTopUp <= int.parse(textController.text)) {
            snackBar(language == "한국어"
                ? "거래당 한도를 초과했습니다. $maxTopUp 작은 숫자를 입력하세요"
                : language == "FRANÇAIS"
                    ? "Vous pouvez seulement acheter jusqu’à $maxTopUp TOS par transaction."
                    : "You can only buy up to $maxTopUp TOS per transaction.");
          } else {
            snackBar(language == "한국어"
                ? "$minTopUp ${AppString.minTopUpNotValidate.tr}."
                : "${AppString.minTopUpNotValidate.tr} $minTopUp.");
          }
        },
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), backgroundColor: CustomColor.colorYellow,
          minimumSize: Size(MediaQuery.of(context).size.width, 50),
        ),
        child: Text(
          AppString.buy.tr,
          style: TextStyles.textStyleSemiBold.apply(color: Colors.black),
        ),
      ),
    );
  }

  void incrementmethod() {
    setState(() {
      textController.text =
          (int.parse(textController.text) + _tosToken).toString();
      _usd += 1;
    });
  }

  void decrementmethod() {
    setState(() {
      if (int.parse(textController.text) <= _tosToken) {
        return;
      } else {
        textController.text =
            (int.parse(textController.text) - _tosToken).toString();
        _usd -= 1;
      }
    });
  }

  _fetchWalletDetails() async {
    setState(() {
      isLoading = true;
    });
    var parsed = await service.getWalletDetails();

    if (parsed != null) {
      _balance = parsed["wallet_ballence"];
      _tosToken = parsed["tos_token"];
      _walletId = parsed["Wallet ID"];
      _usd = parsed["usd"];
      maxTransfer = int.parse(parsed["max_transfer"].toString());
      minTransfer = int.parse(parsed["min_transfer"].toString());
      maxTopUp = int.parse(parsed["max_topup"].toString());
      minTopUp = int.parse(parsed["min_topup"].toString());
      textController = TextEditingController(text: _tosToken.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  _buildWalletHistoryList() {
    return transctionList.length > 0
        ? ListView.separated(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: transctionList.length,
            itemBuilder: (BuildContext context, int index) {
              var model = transctionList[index];
              var parsedDate = DateTime.parse(model.createdAt);
              var now = new DateTime.now();
              var timezoneOffset = now.timeZoneOffset;
              parsedDate = parsedDate.add(timezoneOffset);
              var localeLanguage =
                  LocalizationService().getLocaleFromLanguages(language);

              // print("localeLanguage:" +
              //     "${localeLanguage!.languageCode}_${localeLanguage.countryCode}");

              var dateFormatted = DateFormat('d MMM, y ',
                      "${localeLanguage?.languageCode}_${localeLanguage?.countryCode}")
                  .format(parsedDate);
              print(dateFormatted);
              var timeFormatted = DateFormat('h:mm a',
                      "${localeLanguage?.languageCode}_${localeLanguage?.countryCode}")
                  .format(parsedDate);
              print(timeFormatted);
              String assetName = "";
              switch (model.message.toLowerCase().trim()) {
                case "transfer":
                  assetName = Assets.transfer;
                  break;
                case "topup":
                  assetName = Assets.topup;
                  break;
                case "vote":
                  assetName = Assets.vote;
                  break;
                case "vote":
                  assetName = Assets.event;
                  break;
                default:
                  assetName = Assets.event;
              }
              return Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                          height: 36,
                          width: 36,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.black),
                          child: Image.asset(assetName)),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  " ${model.message.tr}".toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyles.textStyleRegular
                                      .apply(fontSizeFactor: 0.8),
                                ),
                                Container(
                                  width: 10,
                                ),
                                Text(model.transactionId.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyles.textStyleSemiBold
                                        .apply(color: Colors.black)),
                                Spacer(),
                                /*   RichText(
                                  text: TextSpan(
                                      text: model.userId.toString(),
                                      style: TextStyles.textStyleSemiBold
                                          .apply(color: Colors.black),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: " ${model.message}",
                                          style: TextStyles.textStyleRegular
                                              .apply(fontSizeFactor: 0.8),
                                        ),
                                      ]),
                                ), */
                                model.status.toLowerCase().trim() == "c"
                                    ? Icon(
                                        Icons.add,
                                        size: 15,
                                        color: Colors.black,
                                      )
                                    : Icon(
                                        Icons.remove,
                                        size: 15,
                                        color: CustomColor.colorTextDebit,
                                      ),
                                Text(
                                  "${model.amount}",
                                  overflow: TextOverflow.ellipsis,
                                  style: model.status.toLowerCase().trim() ==
                                          "c"
                                      ? TextStyles.textStyleSemiBold
                                          .apply(color: Colors.black)
                                      : TextStyles.textStyleSemiBold.apply(
                                          color: CustomColor.colorTextDebit),
                                ),
                                Text(" TOS",
                                    overflow: TextOverflow.ellipsis,
                                    style: model.status.toLowerCase().trim() ==
                                            "c"
                                        ? TextStyles.textStyleSemiBold
                                            .apply(color: Colors.black)
                                        : TextStyles.textStyleSemiBold.apply(
                                            color: CustomColor.colorTextDebit)),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("$dateFormatted",
                                    style: TextStyles.textStyleRegular.apply(
                                      fontSizeFactor: 0.9,
                                    )),
                                SizedBox(width: 4),
                                Icon(Icons.circle, size: 5),
                                SizedBox(width: 4),
                                Text("$timeFormatted",
                                    style: TextStyles.textStyleRegular.apply(
                                      fontSizeFactor: 0.9,
                                    )),
                                Spacer(),
                                Text("${model.paymentStatus.tr.trim()}",
                                    style: TextStyles.textStyleRegular.apply(
                                        fontSizeFactor: 0.9,
                                        color: Colors.black))
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(height: 8);
            },
          )
        : isLoading
            ? Offstage()
            : Center(
                child: Text(
                  AppString.noHistory.tr,
                  style: TextStyles.textStyleBold.apply(color: Colors.black),
                ),
              );
  }

  _fetchWalletHistoryDetails() async {
    setState(() {
      isLoading = true;
    });
    var parsed = await service.getWalletHistoryDetails();

    if (parsed != null) {
      setState(() {
        isLoading = false;
        transctionList.clear();
      });
      transctionList.addAll(WalletHistoryModel.fromJson(parsed).transctionList);
    }
  }

  _getPref() {
    setState(() {
      language = HiveStore().get(Keys.language);
    });
  }
}
