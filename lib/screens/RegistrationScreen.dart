import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/Store/HiveStore.dart';
import 'package:titosapp/apiService/AuthServices.dart';
import 'package:titosapp/languages/LocalizationService.dart';
import 'package:titosapp/model/UserModel.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/widgets/DefaultEditText.dart';
import 'package:titosapp/widgets/Loader.dart';
import 'package:titosapp/widgets/Terms&Condition.dart';
import 'package:url_launcher/url_launcher.dart';

import 'OTPScreen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  RegistrationScreenState createState() => new RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController fNameController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String countryCode = "";

  AuthService service = new AuthService();
  bool isLoading = false;
  HiveStore? prefs;
  String language = "";

  @override
  void initState() {
    _getPref();
    super.initState();
  }

  showPicker() {
    return showCountryPicker(
        context: context,
        countryListTheme: CountryListThemeData(
          flagSize: 25,
          backgroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
          //Optional. Sets the border radius for the bottomsheet.
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          //Optional. Styles the search field.
          inputDecoration: InputDecoration(
            labelText: AppString.search.tr,
            hintText: AppString.type_search.tr,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: CustomColor.myCustomYellow,
              ),
            ),
          ),
        ),
        onSelect: (Country country) {
          countryController.text = country.name;
          if (countryController.text.isNotEmpty) {
            setState(() {
              countryCode = country.countryCode;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            backgroundColor: CustomColor.myCustomYellow,
            bottomNavigationBar: SafeArea(
              child: Container(
                child: GestureDetector(
                  onTap: () {
                    // showPicker();
                    Navigator.pop(context);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        AppString.signIn.tr,
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: CustomColor.myCustomBlack,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(10, 20, 20, 10),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(10),
              child: ListView(
                physics: ClampingScrollPhysics(),
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      AppString.registration.tr,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    ),
                  ),
                  Container(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: DefaultEditText(
                      textController: fNameController,
                      hintText: AppString.first_name.tr,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: DefaultEditText(
                      textController: lNameController,
                      hintText: AppString.last_name.tr,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: DefaultEditText(
                      textController: cityController,
                      hintText: AppString.cite_of_residence.tr,
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        onTap: () {
                          showPicker();
                        },
                        readOnly: true,
                        controller: countryController,
                        decoration: InputDecoration(
                          hintText: AppString.country.tr,
                          fillColor: Colors.white,
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
                      )),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: DefaultEditText(
                      keyboardType: TextInputType.emailAddress,
                      textController: emailController,
                      hintText: AppString.email.tr,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: DefaultEditText(
                      obscureText: true,
                      textController: passwordController,
                      hintText: AppString.password.tr,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                    child: language == "한국어"
                        ? TermsAndConditionKorean()
                        : TermsAndCondition(),
                  ),
                  Align(
                    child: GestureDetector(
                      onTap: () {
                        validate();
                      },
                      child: Container(
                        color: Colors.black,
                        child: Text(
                          AppString.register.tr.toUpperCase(),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      ),
                    ),
                    alignment: Alignment.center,
                  ),
                ],
              ),
            )),
        Visibility(
          child: Loader(
            text: "",
          ),
          visible: isLoading,
        )
      ],
    );
  }

  void registerUser() async {
    HiveStore prefs = await HiveStore.getInstance();
    Locale? locale = LocalizationService()
        .getLocaleFromLanguages(prefs.getString('indexLang').toString());
    UserModel user = new UserModel(
        firstName: fNameController.text,
        lastName: lNameController.text,
        city: cityController.text,
        country: countryController.text,
        email: emailController.text,
        password: passwordController.text,
        lang: locale?.countryCode.toString().toLowerCase(),
        localZone:
            "${locale?.languageCode.toString().toLowerCase()}_${locale?.countryCode.toString().toUpperCase()}",
        countryCode: countryCode);

    UserModel result = await service.registerUser(user);

    setState(() {
      isLoading = false;
    });

    if (result.status == "success") {
      snackBar(result.msg);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              email: user.email,
              otp: result.otp,
            ),
          ));
    } else {
      if (result.msg.isEmpty)
        snackBar(AppString.somethingWrong);
      else
        snackBar(result.msg);
    }
  }

  showAlertDialog(BuildContext context, String msg) {
    // set up the button
    Widget okButton = TextButton(
      child: Text(
        AppString.ok.tr,
        style: TextStyle(
            fontWeight: FontWeight.bold, color: CustomColor.myCustomYellow),
      ),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: CustomColor.lightblack,
      title: Text(
        msg,
        style: TextStyle(color: Colors.white),
      ),
      actions: [
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

  snackBar(String? message) {
    return Fluttertoast.showToast(
        msg: message!.tr,
        backgroundColor: Colors.black,
        textColor: Colors.white);
  }

  validate() {
    if (fNameController.text.isEmpty ||
        lNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        countryController.text.isEmpty) {
      snackBar(AppString.all_Fields_Required);
    } else if (passwordController.text.length < 6) {
      snackBar(AppString.password_Length_msg);
    } else if (!isEmail(emailController.text)) {
      snackBar(AppString.emailInvalid);
    } else {
      setState(() {
        isLoading = true;
      });
      registerUser();
    }
  }

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  _getPref() {
    setState(() {
      language = HiveStore().get(Keys.language);
    });
  }
}

class TermsAndConditionKorean extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
          text: "등록하시면 ",
          style: TextStyle(
            fontFamily: "Calibre",
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(
              text: "이용 약관 ",
              style: TextStyle(
                fontFamily: "Calibre",
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              recognizer: new TapGestureRecognizer()
                ..onTap = () {
                  launch('https://mytitos.com/terms');
                },
            ),
            TextSpan(
              text: "및 ",
              style: TextStyle(
                fontFamily: "Calibre",
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: "개인정보 보호정책에 ",
              style: TextStyle(
                fontFamily: "Calibre",
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              recognizer: new TapGestureRecognizer()
                ..onTap = () {
                  launch('https://mytitos.com/privacy_policy');
                },
            ),
            TextSpan(
              text: "동의하게 됩니다",
              style: TextStyle(
                fontFamily: "Calibre",
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ]),
    );
  }
}
