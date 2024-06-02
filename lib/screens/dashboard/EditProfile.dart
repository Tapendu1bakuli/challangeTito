import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:titosapp/apiService/AuthServices.dart';
import 'package:titosapp/model/UserModel.dart';
import 'package:titosapp/util/AppString.dart';
import 'package:titosapp/util/CustomColor.dart';
import 'package:titosapp/util/localStorage.dart';
import 'package:titosapp/widgets/DefaultEditText.dart';
import 'package:titosapp/widgets/Loader.dart';

import '../../util/LocalNotification.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  EditProfileScreenState createState() => new EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController fNameController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  AuthService service = new AuthService();
  bool isLoading = false;
  var localStorage = new LocalHiveStorage();
  String? email, firstName, lastName, city, country;

  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CustomColor.customGrey,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            AppString.edit_Profile.tr,
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
        body: ListView(
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        AppString.first_name.tr,
                        style: TextStyle(
                            letterSpacing: 0,
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: DefaultEditText(
                        keyboardType: TextInputType.text,
                        textController: fNameController,
                        hintText: AppString.first_name.tr,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        AppString.last_name.tr,
                        style: TextStyle(
                            letterSpacing: 0,
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: DefaultEditText(
                        keyboardType: TextInputType.text,
                        textController: lNameController,
                        hintText: AppString.last_name.tr,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        AppString.cite_of_residence.tr,
                        style: TextStyle(
                            letterSpacing: 0,
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: DefaultEditText(
                        keyboardType: TextInputType.text,
                        textController: cityController,
                        hintText: AppString.cite_of_residence.tr,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        AppString.country.tr,
                        style: TextStyle(
                            letterSpacing: 0,
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: DefaultEditText(
                        keyboardType: TextInputType.text,
                        textController: countryController,
                        hintText: AppString.country.tr,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        AppString.email.tr,
                        style: TextStyle(
                            letterSpacing: 0,
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: DefaultEditText(
                        keyboardType: TextInputType.text,
                        readOnly: true,
                        textController: emailController,
                        hintText: AppString.cite_of_residence.tr,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: ButtonTheme(
                        child: TextButton(
                          onPressed: () async {
                            var result = await service.editProfile(
                                fNameController.text,
                                lNameController.text,
                                cityController.text,
                                countryController.text,
                                emailController.text);

                            if (result["status"] == "success") {
                              UserModel updatedDetails = new UserModel(
                                  email: emailController.text,
                                  firstName: fNameController.text,
                                  lastName: lNameController.text,
                                  city: cityController.text,
                                  country: countryController.text);
                              NotificationsBloc.instance
                                  .newNotification(LocalNotification("new"));
                              localStorage.updateUserDetails(updatedDetails);
                              snackBar(AppString.userDetailsSuccess);
                            } else {
                              snackBar(result["error"]);
                            }
                          },
                          child: Center(
                              child: Text(
                            AppString.update.tr.toUpperCase(),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          )),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: CustomColor.myCustomYellowDark,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  child: Loader(),
                  visible: isLoading,
                )
              ],
            )
          ],
        ));
  }

  goAuth() {
    Navigator.pushNamedAndRemoveUntil(
        context, '/Login', (Route<dynamic> route) => false);
  }

  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!.tr),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void getUserDetails() async {
    email = await localStorage.getValue("email");
    firstName = await localStorage.getValue("first_name");
    lastName = await localStorage.getValue("last_name");
    city = await localStorage.getValue("city");
    country = await localStorage.getValue("country");

    fNameController.text = firstName!;
    emailController.text = email!;
    lNameController.text = lastName!;
    cityController.text = city!;
    countryController.text = country!;
  }
}
