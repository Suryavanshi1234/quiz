class InAppProduct {
  final String id;
  final String title;
  final int coins;
  final String productId;
  final String image;
  final String desc;
  final bool isActive;

  InAppProduct({
    required this.id,
    required this.title,
    required this.coins,
    required this.productId,
    required this.image,
    required this.desc,
    required this.isActive,
  });

  factory InAppProduct.fromJson(Map<String, dynamic> json) => InAppProduct(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        coins: int.parse(json['coins'] ?? '0'),
        productId: json['product_id'] ?? '',
        image: json['image'] ?? '',
        desc: json['description'] ?? '',
        isActive: (json['status'] ?? '0') == '1',
      );

  @override
  String toString() => "\n{ "
      "id: $id, "
      "title : $title, "
      "coins : $coins, "
      "product_id : $productId, "
      "image : $image, "
      "desc : $desc, "
      "isActive : $isActive"
      " }";
}

// TODO : in future updates, in response only send active IAPs.
