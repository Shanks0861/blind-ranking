import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Category>> fetchMainCategories() async {
    final snap = await _db.collection('categories').where('parent_id', isNull: true).orderBy('name').get();
    return snap.docs.map((d) => Category.fromMap(d.id, d.data())).toList();
  }

  Future<List<SubCategory>> fetchSubCategories(String categoryId) async {
    final snap = await _db.collection('categories').where('parent_id', isEqualTo: categoryId).orderBy('name').get();
    return snap.docs.map((d) => SubCategory.fromMap(d.id, d.data())).toList();
  }

  Future<List<GameItem>> fetchItems({required String categoryId, String? subCategoryId}) async {
    if (subCategoryId != null) {
      final children = await fetchSubCategories(subCategoryId);
      if (children.isNotEmpty) {
        final all = <GameItem>[];
        for (final child in children) {
          all.addAll(await _fetchItemsForSub(categoryId: categoryId, subCategoryId: child.id));
        }
        all.addAll(await _fetchItemsForSub(categoryId: categoryId, subCategoryId: subCategoryId));
        final seen = <String>{};
        return all.where((i) => seen.add(i.id)).toList();
      }
      return _fetchItemsForSub(categoryId: categoryId, subCategoryId: subCategoryId);
    }
    final snap = await _db.collection('items').where('category_id', isEqualTo: categoryId).orderBy('name').get();
    return snap.docs.map((d) => GameItem.fromMap(d.id, d.data())).toList();
  }

  Future<List<GameItem>> _fetchItemsForSub({required String categoryId, required String subCategoryId}) async {
    final snap = await _db.collection('items').where('category_id', isEqualTo: categoryId).where('sub_category_id', isEqualTo: subCategoryId).orderBy('name').get();
    return snap.docs.map((d) => GameItem.fromMap(d.id, d.data())).toList();
  }

  Future<GameItem?> fetchItemById(String id) async {
    final doc = await _db.collection('items').doc(id).get();
    if (!doc.exists) return null;
    return GameItem.fromMap(doc.id, doc.data()!);
  }

  Future<List<GameItem>> fetchItemsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final chunks = <List<String>>[];
    for (var i = 0; i < ids.length; i += 30) chunks.add(ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30));
    final all = <GameItem>[];
    for (final chunk in chunks) {
      final snap = await _db.collection('items').where(FieldPath.documentId, whereIn: chunk).get();
      all.addAll(snap.docs.map((d) => GameItem.fromMap(d.id, d.data())));
    }
    return all;
  }

  Future<Category> createCustomCategory({required String name, required String userId, String? parentId}) async {
    final ref = await _db.collection('categories').add({'name': name, 'parent_id': parentId, 'created_by': userId});
    return Category(id: ref.id, name: name, parentId: parentId, createdBy: userId);
  }

  Future<GameItem> addCustomItem({required String name, required String categoryId, String? subCategoryId, String? imageUrl}) async {
    final ref = await _db.collection('items').add({'name': name, 'category_id': categoryId, 'sub_category_id': subCategoryId, 'image_url': imageUrl});
    return GameItem(id: ref.id, name: name, categoryId: categoryId, subCategoryId: subCategoryId, imageUrl: imageUrl);
  }

  Future<List<Category>> fetchUserCategories(String userId) async {
    final snap = await _db.collection('categories').where('created_by', isEqualTo: userId).orderBy('name').get();
    return snap.docs.map((d) => Category.fromMap(d.id, d.data())).toList();
  }

  Future<void> deleteCustomCategory(String categoryId) async {
    final items = await _db.collection('items').where('category_id', isEqualTo: categoryId).get();
    final batch = _db.batch();
    for (final doc in items.docs) batch.delete(doc.reference);
    batch.delete(_db.collection('categories').doc(categoryId));
    await batch.commit();
  }

  Future<void> deleteCustomItem(String itemId) async => await _db.collection('items').doc(itemId).delete();
}
