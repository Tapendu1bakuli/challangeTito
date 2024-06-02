class WalletHistoryModel {
  WalletHistoryModel({
    this.status = "",
    this.msg = "",
    required this.transctionList,
  });

  late final String status;
  late final String msg;
  late final List<TransctionList> transctionList;

  WalletHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    transctionList = List.from(json['transction_list'])
        .map((e) => TransctionList.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['msg'] = msg;
    _data['transction_list'] = transctionList.map((e) => e.toJson()).toList();
    return _data;
  }
}

class TransctionList {
  TransctionList({
    required this.transactionId,
    required this.id,
    required this.amount,
    required this.userId,
    required this.status,
    required this.paymentStatus,
    required this.message,
    required this.createdAt,
    this.updatedAt,
  });

  late final String transactionId;
  late final int id;
  late final int amount;
  late final int userId;
  late final String status;
  late final String paymentStatus;
  late final String message;
  late final String createdAt;
  late final String? updatedAt;

  TransctionList.fromJson(Map<String, dynamic> json) {
    id = json['id'] == null ? 0 : json['id'];
    transactionId =
        json['server_transction'] == null ? "" : json['server_transction'];
    amount = json['amount'];
    userId = json['user_id'];
    status = json['status'];
    paymentStatus = json['payment_status'].toString().trim();
    message = json['message'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['server_transction'] = transactionId;
    _data['amount'] = amount;
    _data['user_id'] = userId;
    _data['status'] = status;
    _data['payment_status'] = paymentStatus;
    _data['message'] = message;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    return _data;
  }
}
