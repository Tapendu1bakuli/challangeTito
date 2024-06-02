class PaymentAccountModel {
  PaymentAccountModel({
    required this.status,
    required this.paymentAccountTypes,
    required this.message,
  });

  late final String status;
  late final List<PaymentAccountTypes> paymentAccountTypes;
  late final String message;

  PaymentAccountModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    paymentAccountTypes = List.from(json['paymentAccountTypes'])
        .map((e) => PaymentAccountTypes.fromJson(e))
        .toList();
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['paymentAccountTypes'] =
        paymentAccountTypes.map((e) => e.toJson()).toList();
    _data['message'] = message;
    return _data;
  }
}

class PaymentAccountTypes {
  PaymentAccountTypes(
      {required this.id,
      required this.paymentTypeName,
      required this.paymentTypeDescription,
      required this.logoPath,
      required this.status,
      required this.parrentId,
      required this.mobileMoney,
      required this.isSelected});

  late final int id;
  late final String paymentTypeName;
  late final String paymentTypeDescription;
  late final String logoPath;
  late final int status;
  late final int parrentId;
  late final List<MobileMoney> mobileMoney;
  bool? isSelected;

  PaymentAccountTypes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    paymentTypeName = json['payment_type_name'];
    paymentTypeDescription = json['payment_type_description'];
    logoPath = json['logo_path'];
    status = json['status'];
    parrentId = json['parrent_id'];
    mobileMoney = List.from(json['mobile_money'])
        .map((e) => MobileMoney.fromJson(e))
        .toList();
    isSelected = false;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['payment_type_name'] = paymentTypeName;
    _data['payment_type_description'] = paymentTypeDescription;
    _data['logo_path'] = logoPath;
    _data['status'] = status;
    _data['parrent_id'] = parrentId;
    _data['mobile_money'] = mobileMoney.map((e) => e.toJson()).toList();
    return _data;
  }
}

class MobileMoney {
  MobileMoney({
    required this.id,
    required this.paymentTypeName,
    required this.paymentTypeDescription,
    required this.logoPath,
    required this.status,
    required this.parrentId,
    this.isMobileSelected = false,
  });

  late final int id;
  late final String paymentTypeName;
  late final String paymentTypeDescription;
  late final String logoPath;
  late final int status;
  late final int parrentId;
  late bool isMobileSelected;

  MobileMoney.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    paymentTypeName = json['payment_type_name'];
    paymentTypeDescription = json['payment_type_description'];
    logoPath = json['logo_path'];
    status = json['status'];
    parrentId = json['parrent_id'];
    isMobileSelected = false;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['payment_type_name'] = paymentTypeName;
    _data['payment_type_description'] = paymentTypeDescription;
    _data['logo_path'] = logoPath;
    _data['status'] = status;
    _data['parrent_id'] = parrentId;
    return _data;
  }
}
