class UserDetailsModel {
  UserDetailsModel({
    required this.status,
    required this.msg,
    required this.userList,
  });

  late final String status;
  late final String msg;
  late final List<UserList> userList;

  UserDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'] == null ? json['error'] : json['msg'];
    userList = json['user_list'] == null
        ? <UserList>[]
        : List.from(json['user_list'])
            .map((e) => UserList.fromJson(e))
            .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['msg'] = msg;
    _data['user_list'] = userList.map((e) => e.toJson()).toList();
    return _data;
  }
}

class UserList {
  UserList({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.country,
    required this.email,
    required this.emailVerifiedAt,
    required this.userType,
    this.paymentAccountId,
    this.paymentAccountAddress,
    this.selected = false,
    required this.userStatus,
    required this.walletId,
    required this.blockchain,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  late bool selected;
  late final int id;
  late final String firstName;
  late final String lastName;
  late final String city;
  late final String country;
  late final String email;
  late final String emailVerifiedAt;
  late final int userType;
  late final Null paymentAccountId;
  late final Null paymentAccountAddress;
  late final int userStatus;
  late final String walletId;
  late final String blockchain;
  late final String createdAt;
  late final String updatedAt;
  late final Null deletedAt;

  UserList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'] == null ? "" : json['first_name'];
    selected = false;
    lastName = json['last_name'] == null ? "" : json['last_name'];
    city = json['city'] == null ? "" : json['city'];
    country = json['country'] == null ? "" : json['country'];
    email = json['email'] == null ? "" : json['email'];
    emailVerifiedAt =
        json['email_verified_at'] == null ? "" : json['email_verified_at'];
    userType = json['user_type'] == null ? "" : json['user_type'];
    paymentAccountId = null;
    paymentAccountAddress = null;
    userStatus = json['user_status'] == null ? "" : json['user_status'];
    walletId = json['wallet_id'] == null ? "" : json['wallet_id'];
    blockchain = json['blockchain'] == null ? "" : json['blockchain'];
    createdAt = json['created_at'] == null ? "" : json['created_at'];
    updatedAt = json['updated_at'] == null ? "" : json['updated_at'];
    deletedAt = null;
  }

  UserList.empty() {
    id = 0;
    firstName = 'first_name';
    selected = false;
    lastName = 'last_name';
    city = 'city';
    country = 'country';
    email = 'email';
    emailVerifiedAt = 'email_verified_at';
    userType = 0;
    paymentAccountId = null;
    paymentAccountAddress = null;
    userStatus = 0;
    walletId = 'wallet_id';
    blockchain = 'blockchain';
    createdAt = 'created_at';
    updatedAt = 'updated_at';
    deletedAt = null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['first_name'] = firstName;
    _data['last_name'] = lastName;
    _data['city'] = city;
    _data['country'] = country;
    _data['email'] = email;
    _data['email_verified_at'] = emailVerifiedAt;
    _data['user_type'] = userType;
    _data['payment_account_id'] = paymentAccountId;
    _data['payment_account_address'] = paymentAccountAddress;
    _data['user_status'] = userStatus;
    _data['wallet_id'] = walletId;
    _data['blockchain'] = blockchain;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    _data['deleted_at'] = deletedAt;
    return _data;
  }
}
