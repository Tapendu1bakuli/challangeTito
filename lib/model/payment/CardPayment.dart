class CardPaymentModel {
  CardPaymentModel({
    required this.status,
    required this.data,
    required this.msg,
  });

  late final String status;
  late final Data data;
  late final String msg;

  CardPaymentModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = Data.fromJson(json['data']);
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['data'] = data.toJson();
    _data['msg'] = msg;
    return _data;
  }
}

class Data {
  Data({
    required this.additionalData,
    required this.pspReference,
    required this.resultCode,
    required this.amount,
    required this.merchantReference,
  });

  late final AdditionalData additionalData;
  late final String pspReference;
  late final String resultCode;
  late final Amount amount;
  late final String merchantReference;

  Data.fromJson(Map<String, dynamic> json) {
    additionalData = AdditionalData.fromJson(json['additionalData']);
    pspReference = json['pspReference'];
    resultCode = json['resultCode'];
    amount = Amount.fromJson(json['amount']);
    merchantReference = json['merchantReference'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['additionalData'] = additionalData.toJson();
    _data['pspReference'] = pspReference;
    _data['resultCode'] = resultCode;
    _data['amount'] = amount.toJson();
    _data['merchantReference'] = merchantReference;
    return _data;
  }
}

class AdditionalData {
  AdditionalData({
    required this.scaExemptionRequested,
  });

  late final String scaExemptionRequested;

  AdditionalData.fromJson(Map<String, dynamic> json) {
    scaExemptionRequested = json['scaExemptionRequested'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['scaExemptionRequested'] = scaExemptionRequested;
    return _data;
  }
}

class Amount {
  Amount({
    required this.currency,
    required this.value,
  });

  late final String currency;
  late final int value;

  Amount.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['currency'] = currency;
    _data['value'] = value;
    return _data;
  }
}
