class Category {
  final String id;
  final String name;
  final String? parentId;
  final String? createdBy;

  const Category({required this.id, required this.name, this.parentId, this.createdBy});
  bool get isCustom => createdBy != null;

  factory Category.fromMap(String id, Map<String, dynamic> map) {
    return Category(id: id, name: map['name'] as String, parentId: map['parent_id'] as String?, createdBy: map['created_by'] as String?);
  }

  Map<String, dynamic> toMap() => {'name': name, 'parent_id': parentId, 'created_by': createdBy};
}

class SubCategory {
  final String id;
  final String name;
  final String parentId;

  const SubCategory({required this.id, required this.name, required this.parentId});

  factory SubCategory.fromMap(String id, Map<String, dynamic> map) {
    return SubCategory(id: id, name: map['name'] as String, parentId: map['parent_id'] as String);
  }
}

class GameItem {
  final String id;
  final String name;
  final String? imageUrl;
  final String categoryId;
  final String? subCategoryId;

  const GameItem({required this.id, required this.name, this.imageUrl, required this.categoryId, this.subCategoryId});

  factory GameItem.fromMap(String id, Map<String, dynamic> map) {
    return GameItem(id: id, name: map['name'] as String, imageUrl: map['image_url'] as String?, categoryId: map['category_id'] as String, subCategoryId: map['sub_category_id'] as String?);
  }

  Map<String, dynamic> toMap() => {'name': name, 'image_url': imageUrl, 'category_id': categoryId, 'sub_category_id': subCategoryId};
}
