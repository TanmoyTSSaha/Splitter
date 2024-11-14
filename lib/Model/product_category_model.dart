class MasterProductCategoryModel {
  String? category;
  String? productName;
  DateTime? createdAt;
  String? categoryLogo;

  MasterProductCategoryModel({
    this.category,
    this.productName,
    this.createdAt,
    this.categoryLogo,
  });

  MasterProductCategoryModel.fromJSON(Map<String, dynamic> json) {
    category = json["category"];
    productName = json["product_name"];
    createdAt = DateTime.parse(json["created_at"]);
    categoryLogo = json["category_logo"] ?? "";
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = <String, dynamic>{};

    data["category"] = category;
    data["product_name"] = productName;
    data["created_at"] = createdAt;
    data["category_logo"] = categoryLogo;

    return data;
  }
}

class CategoryOnlyModel {
  String? category;
  String? categoryLogo;

  CategoryOnlyModel({
    this.category,
    this.categoryLogo,
  });

  CategoryOnlyModel.fromJSON(Map<String, dynamic> data) {
    category = data["category"];
    categoryLogo = data["category_logo"] ?? "";
  }
}
