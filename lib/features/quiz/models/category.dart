class Category {
  const Category({
    this.languageId,
    this.categoryName,
    this.image,
    this.rowOrder,
    this.noOf,
    this.noOfQues,
    this.maxLevel,
    required this.isPlayed,
    this.id,
  });

  final String? id;
  final String? languageId;
  final String? categoryName;
  final String? image;
  final String? rowOrder;
  final String? noOf;
  final String? noOfQues;
  final String? maxLevel;
  final bool isPlayed;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      isPlayed: json['is_play'] == null ? true : json['is_play'] == "1",
      id: json["id"],
      languageId: json["language_id"],
      categoryName: json["category_name"],
      image: json["image"],
      rowOrder: json["row_order"],
      noOf: json["no_of"],
      noOfQues: json["no_of_que"],
      maxLevel: json["maxlevel"],
    );
  }
}
