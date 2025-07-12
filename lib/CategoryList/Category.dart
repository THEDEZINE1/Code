

class SubSubCategory {
  final String catID;
  final String name;
  final String icon;

  SubSubCategory({required this.catID, required this.name, required this.icon});

  factory SubSubCategory.fromJson(Map<String, dynamic> json) {
    return SubSubCategory(
      catID: json['catID'],
      name: json['name'],
      icon: json['icon'],
    );
  }
}

class SubCategory {
  final String catID;
  final String name;
  final String icon;
  final bool hasSubSubCategory;
  final List<SubSubCategory> subSubCategories;

  SubCategory({
    required this.catID,
    required this.name,
    required this.icon,
    required this.hasSubSubCategory,
    required this.subSubCategories,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      catID: json['catID'],
      name: json['name'],
      icon: json['icon'],
      hasSubSubCategory: json['subsubcat'] == "Yes",
      subSubCategories: (json['subsubcat_list'] as List)
          .map((i) => SubSubCategory.fromJson(i))
          .toList(),
    );
  }
}

class Category {
  final String catID;
  final String name;
  final String icon;
  final bool hasSubCategory;
  final List<SubCategory> subCategories;

  Category({
    required this.catID,
    required this.name,
    required this.icon,
    required this.hasSubCategory,
    required this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      catID: json['catID'],
      name: json['name'],
      icon: json['icon'],
      hasSubCategory: json['subcat'] == "Yes",
      subCategories: (json['subcat_list'] as List)
          .map((i) => SubCategory.fromJson(i))
          .toList(),
    );
  }
}
