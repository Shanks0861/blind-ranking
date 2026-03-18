class Category {
  final String id;
  final String name;
  final String? parentId;
  final String? createdBy;
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

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'parent_id': parentId,
        'created_by': createdBy,
      };

  Category copyWith({
    String? categoryId,
    String? subCategoryId,
    dynamic listSize,
    dynamic status,
    List<dynamic>? players,
  }) =>
      this;
}

class SubCategory {
  final String id;
  final String name;
  final String parentId; // ← heißt in der DB parent_id, nicht category_id

  const SubCategory({
    required this.id,
    required this.name,
    required this.parentId,
  });

  factory SubCategory.fromMap(Map<String, dynamic> map) {
    return SubCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      parentId: map['parent_id'] as String, // ← Fix: war 'category_id'
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

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'image_url': imageUrl,
        'category_id': categoryId,
        'sub_category_id': subCategoryId,
      };
}
