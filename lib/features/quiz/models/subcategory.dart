class Subcategory {
  const Subcategory({
    required this.isPlayed,
    this.id,
    this.image,
    this.languageId,
    this.mainCatId,
    this.maxLevel,
    this.noOfQue,
    this.rowOrder,
    this.status,
    this.subcategoryName,
  });

  final String? id;
  final String? image;
  final String? languageId;
  final String? mainCatId;
  final String? maxLevel;
  final String? noOfQue;
  final String? rowOrder;
  final String? status;
  final String? subcategoryName;
  final bool isPlayed;

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json["id"],
      image: json['image'],
      isPlayed: json['is_play'] == null ? true : json['is_play'] == "1",
      languageId: json["language_id"],
      mainCatId: json["maincat_id"],
      maxLevel: json["maxlevel"],
      noOfQue: json["no_of_que"],
      rowOrder: json["row_order"],
      status: json["status"],
      subcategoryName: json["subcategory_name"],
    );
  }
}
