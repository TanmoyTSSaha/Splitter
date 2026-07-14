import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';

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
    category = json[SupabaseColumns.category];
    productName = json[SupabaseColumns.productName];
    createdAt = json[SupabaseColumns.createdAt] != null
        ? DateTime.tryParse(json[SupabaseColumns.createdAt])
        : null;
    categoryLogo = json[SupabaseColumns.categoryLogo] ?? StringDefaults.empty;
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = <String, dynamic>{};

    data[SupabaseColumns.category] = category;
    data[SupabaseColumns.productName] = productName;
    data[SupabaseColumns.createdAt] = createdAt;
    data[SupabaseColumns.categoryLogo] = categoryLogo;

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
    category = data[SupabaseColumns.category];
    categoryLogo = data[SupabaseColumns.categoryLogo] ?? StringDefaults.empty;
  }

  Map<String, dynamic> toJSON() => {
        SupabaseColumns.category: category,
        SupabaseColumns.categoryLogo: categoryLogo,
      };
}
