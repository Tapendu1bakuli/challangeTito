class UserModel {
  int? id;
  String? firstName;
  String? lastName;
  String? city;
  String? lang;
  String? country;
  String? email;
  String? password;
  String msg = "";
  int otp = 0;
  String status = "";
  String? accessToken;
  int? paymentAccountId;
  String? paymentAccountAddress;
  String? countryCode;
  String? localZone;
  String? walletBalance;

  UserModel(
      {this.id,
      this.firstName,
      this.lastName,
      this.city,
      this.country,
      this.email,
      this.password,
      this.msg = "",
      this.otp = 0,
      this.status = "",
      this.accessToken,
      this.lang,
      this.localZone,
      this.walletBalance,
      this.countryCode});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    firstName = json['first_name'] ?? "";
    lastName = json['last_name'] ?? "";
    city = json['city'] ?? "";
    country = json['country'] ?? "";
    email = json['email'] ?? "";
    password = json['password'] ?? "";
    msg = json['message'] ?? "";
    walletBalance =
        json['wallet_balance'] == null ? "" : json['wallet_balance'].toString();
    accessToken = json['access_token'] ?? "";
    paymentAccountId = json['payment_account_id'] ?? 0;
    paymentAccountAddress = json['payment_account_address'] ?? "";
    lang = json['lenguage'] ?? "";
    countryCode = json['countryCode'] ?? "";
    localZone = json['local_zone'] ?? "";
  }

  UserModel.fromSignUpJson(Map<String, dynamic> json) {
    msg = json['message'] ?? "";
    otp = json['otp'] ?? 0;
    status = json['status'] ?? "";
  }
}
