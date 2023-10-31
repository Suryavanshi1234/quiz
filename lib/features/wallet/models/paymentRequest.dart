class PaymentRequest {
  PaymentRequest({
    required this.id,
    required this.userId,
    required this.uid,
    required this.paymentType,
    required this.paymentAddress,
    required this.paymentAmount,
    required this.coinUsed,
    required this.details,
    required this.status,
    required this.date,
  });

  late final String id;
  late final String userId;
  late final String uid;
  late final String paymentType;
  late final String paymentAddress;
  late final String paymentAmount;
  late final String coinUsed;
  late final String details;
  late final String status;
  late final String date;

  PaymentRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    userId = json['user_id'] ?? "";
    uid = json['uid'] ?? "";
    paymentType = json['payment_type'] ?? "";
    paymentAddress = json['payment_address'] ?? "";
    paymentAmount = json['payment_amount'] ?? "";
    coinUsed = json['coin_used'] ?? "";
    details = json['details'] ?? "";
    status = json['status'] ?? "";
    date = json['date'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['uid'] = uid;
    data['payment_type'] = paymentType;
    data['payment_address'] = paymentAddress;
    data['payment_amount'] = paymentAmount;
    data['coin_used'] = coinUsed;
    data['details'] = details;
    data['status'] = status;
    data['date'] = date;
    return data;
  }
}
