import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/model/PaymentAccountModel.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/TextStyles.dart';

class MobileMoneyList extends StatefulWidget {
  const MobileMoneyList({
    Key? key,
    required this.model,
    required this.selected,
  }) : super(key: key);
  final List<MobileMoney> model;
  final MobileMoney selected;

  @override
  _MobileMoneyState createState() => _MobileMoneyState();
}

class _MobileMoneyState extends State<MobileMoneyList> {
  MobileMoney? selectedMobileAccountType = MobileMoney(
      id: 0,
      isMobileSelected: false,
      logoPath: '',
      parrentId: 0,
      paymentTypeDescription: '',
      paymentTypeName: '',
      status: 0);

  @override
  void initState() {
    widget.model.forEach((element) {
      if (element.id == widget.selected.id) {
        setState(() {
          element.isMobileSelected = true;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppString.mobileMoney.tr.toUpperCase()),
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: new Icon(
            Icons.arrow_back_ios,
            color: CustomColor.myCustomYellow,
          ),
          onPressed: () {
            if (selectedMobileAccountType!.isMobileSelected == true) {
              setState(() {
                selectedMobileAccountType!.isMobileSelected = false;
              });
              // for (var i = 0; i < widget.model.length; i++) {
              //   widget.model[i].isMobileSelected =
              //       _isSelected(selectedMobileAccountType!.isMobileSelected);
              // }
            }
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                if (selectedMobileAccountType!.isMobileSelected == false) {
                  showAlertDialog(context);
                } else
                  Navigator.pop(context, selectedMobileAccountType);
              },
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ))
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              AppString.selectMoney.tr,
              style: TextStyles.textStyleSemiBold
                  .apply(color: CustomColor.colorTextHint),
            ),
          ),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            itemCount: widget.model.length,
            itemBuilder: (BuildContext context, int ind) {
              var model = widget.model[ind];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    for (int i = 0; i < widget.model.length; i++) {
                      widget.model[i].isMobileSelected = false;
                    }
                    model.isMobileSelected = !model.isMobileSelected;
                    selectedMobileAccountType = model;
                  });
                  _isSelected(model.isMobileSelected);
                },
                child: ListTile(
                    leading: CachedNetworkImage(
                      width: 50,
                      height: 50,
                      imageUrl: model.logoPath,
                      imageBuilder: (context, imageProvider) => Container(
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
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    title: Text(
                      model.paymentTypeName.toString(),
                      style: TextStyles.textStyleRegular,
                    ),
                    trailing: (model.isMobileSelected)
                        ? Icon(
                            Icons.check_circle_outline_outlined,
                            color: Colors.green,
                          )
                        : Offstage()),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider(
                indent: 20,
                endIndent: 20,
                color: CustomColor.colorDividerPayment,
              );
            },
          ),
        ],
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text(
        AppString.ok.tr,
        style: TextStyle(
            fontWeight: FontWeight.bold, color: CustomColor.myCustomYellow),
      ),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
    Widget cancelButton = TextButton(
      child: Text(
        AppString.cancel.tr,
        style: TextStyle(fontWeight: FontWeight.bold, color: CustomColor.white),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: CustomColor.lightblack,
      title: Text(
        AppString.notSelectedMobileMoney.tr,
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _isSelected(bool isSelected) {
    return isSelected;
  }
}
