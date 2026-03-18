class Category {
  final String id;
  final String name;
  final String? parentId; // null = Hauptkategorie
  final String? createdBy; // null = system
  final List<SubCategory> subCategories;

  const Category({
    required this.id,
    required this.name,
    this.parentId,
    this.createdBy,
    this.subCategories = const [],
  });

  bool get isCustom => createdBy != null;

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      parentId: map['parent_id'] as String?,
      createdBy: map['created_by'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'created_by': createdBy,
    };
  }
}

class SubCategory {
  final String id;
  final String name;
  final String categoryId;

  const SubCategory({
    required this.id,
    required this.name,
    required this.categoryId,
  });

  factory SubCategory.fromMap(Map<String, dynamic> map) {
    return SubCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      categoryId: map['category_id'] as String,
    );
  }
}

class GameItem {
  final String id;
  final String name;
  final String? imageUrl;
  final String categoryId;
  final String? subCategoryId;

  const GameItem({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.categoryId,
    this.subCategoryId,
  });

  factory GameItem.fromMap(Map<String, dynamic> map) {
    return GameItem(
      id: map['id'] as String,
      name: map['name'] as String,
      imageUrl: map['image_url'] as String?,
      categoryId: map['category_id'] as String,
      subCategoryId: map['sub_category_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
    };
  }
}
