class PayoutMethod {
  final String type;
  final String image;
  final List<String> inputDetailsFromUser; //how many detials to get from user
  final List<bool> inputDetailsIsNumber;

  PayoutMethod({
    required this.inputDetailsFromUser,
    required this.inputDetailsIsNumber,
    required this.image,
    required this.type,
  });
}
