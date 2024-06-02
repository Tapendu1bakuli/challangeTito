class BuyTicketSendModel {
  BuyTicketSendModel({
    required this.eventManagementId,
    required this.ticketInfos,
  });

  late final int eventManagementId;
  late final List<TicketInfos> ticketInfos;

  BuyTicketSendModel.fromJson(Map<String, dynamic> json) {
    eventManagementId = json['event_management_id'];
    ticketInfos = List.from(json['ticket_infos'])
        .map((e) => TicketInfos.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['event_management_id'] = eventManagementId;
    _data['ticket_infos'] = ticketInfos.map((e) => e.toJson()).toList();
    return _data;
  }
}

class TicketInfos {
  TicketInfos({
    required this.seatCategoryId,
    required this.requestNoOfSeats,
    required this.tosAmount,
  });

  late final int seatCategoryId;
  late final int requestNoOfSeats;
  late final int tosAmount;

  TicketInfos.fromJson(Map<String, dynamic> json) {
    seatCategoryId = json['seat_category_id'];
    requestNoOfSeats = json['request_no_of_seats'];
    tosAmount = json['tos_amount'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['seat_category_id'] = seatCategoryId;
    _data['request_no_of_seats'] = requestNoOfSeats;
    _data['tos_amount'] = tosAmount;
    return _data;
  }
}
