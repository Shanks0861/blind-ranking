import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Category>> fetchMainCategories() async {
    final snap = await _db
        .collection('categories')
        .where('parent_id', isNull: true)
        .orderBy('name')
        .get();
    return snap.docs.map((d) => Category.fromMap(d.id, d.data())).toList();
  }

  Future<List<SubCategory>> fetchSubCategories(String categoryId) async {
    final snap = await _db
        .collection('categories')
        .where('parent_id', isEqualTo: categoryId)
        .orderBy('name')
        .get();
    return snap.docs
        .map((d) => SubCategory.fromMap(d.id, d.data()))
        .toList();
  }

  Future<List<GameItem>> fetchItems({
    required String categoryId,
    String? subCategoryId,
  }) async {
    if (subCategoryId != null) {
      // Prüfe ob subCategoryId selbst Kinder hat (Level 2)
      final children = await fetchSubCategories(subCategoryId);

      if (children.isNotEmpty) {
        // subCategoryId ist z.B. "Pokémon" → hat Kinder wie "Generation 1"
        // Items können unter subCategoryId ODER categoryId gespeichert sein
        final all = <GameItem>[];
        for (final child in children) {
          // Versuche Items mit category_id = subCategoryId (z.B. Pokémon-ID)
          final items1 = await _fetchItemsForSub(
              categoryId: subCategoryId, subCategoryId: child.id);
          all.addAll(items1);
          // Auch mit category_id = categoryId (z.B. Anime-ID)
          final items2 = await _fetchItemsForSub(
              categoryId: categoryId, subCategoryId: child.id);
          all.addAll(items2);
        }
        // Deduplizieren
        final seen = <String>{};
        return all.where((i) => seen.add(i.id)).toList();
      }

      // Level 1 gewählt (z.B. "Alle Starter") — versuche beide category_ids
      final results = <GameItem>[];

      // 1. category_id = subCategoryId parent (z.B. Pokémon-ID), sub = subCategoryId
      final parent = await _getCategoryParentId(subCategoryId);
      if (parent != null) {
        final items = await _fetchItemsForSub(
            categoryId: parent, subCategoryId: subCategoryId);
        results.addAll(items);
      }

      // 2. category_id = categoryId (z.B. Anime-ID), sub = subCategoryId
      final items2 = await _fetchItemsForSub(
          categoryId: categoryId, subCategoryId: subCategoryId);
      results.addAll(items2);

      // 3. category_id = subCategoryId selbst (direkte Items)
      final items3 = await _fetchItemsDirect(categoryId: subCategoryId);
      results.addAll(items3);

      final seen = <String>{};
      return results.where((i) => seen.add(i.id)).toList();
    }

    // Keine Sub → alle Items der Hauptkategorie
    final snap = await _db
        .collection('items')
        .where('category_id', isEqualTo: categoryId)
        .orderBy('name')
        .get();
    return snap.docs.map((d) => GameItem.fromMap(d.id, d.data())).toList();
  }

  Future<String?> _getCategoryParentId(String categoryId) async {
    try {
      final doc = await _db.collection('categories').doc(categoryId).get();
      if (doc.exists) return doc.data()?['parent_id'] as String?;
    } catch (_) {}
    return null;
  }

  Future<List<GameItem>> _fetchItemsForSub({
    required String categoryId,
    required String subCategoryId,
  }) async {
    try {
      final snap = await _db
          .collection('items')
          .where('category_id', isEqualTo: categoryId)
          .where('sub_category_id', isEqualTo: subCategoryId)
          .orderBy('name')
          .get();
      return snap.docs.map((d) => GameItem.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<GameItem>> _fetchItemsDirect({required String categoryId}) async {
    try {
      final snap = await _db
          .collection('items')
          .where('category_id', isEqualTo: categoryId)
          .orderBy('name')
          .get();
      return snap.docs.map((d) => GameItem.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return [];
    }
  }

  Future<GameItem?> fetchItemById(String id) async {
    final doc = await _db.collection('items').doc(id).get();
    if (!doc.exists) return null;
    return GameItem.fromMap(doc.id, doc.data()!);
  }

  Future<List<GameItem>> fetchItemsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final chunks = <List<String>>[];
    for (var i = 0; i < ids.length; i += 30) {
      chunks.add(ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30));
    }
    final all = <GameItem>[];
    for (final chunk in chunks) {
      final snap = await _db
          .collection('items')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      all.addAll(snap.docs.map((d) => GameItem.fromMap(d.id, d.data())));
    }
    return all;
  }

  Future<Category> createCustomCategory({
    required String name,
    required String userId,
    String? parentId,
  }) async {
    final ref = await _db.collection('categories').add({
      'name': name,
      'parent_id': parentId,
      'created_by': userId,
    });
    return Category(
        id: ref.id, name: name, parentId: parentId, createdBy: userId);
  }

  Future<GameItem> addCustomItem({
    required String name,
    required String categoryId,
    String? subCategoryId,
    String? imageUrl,
  }) async {
    final ref = await _db.collection('items').add({
      'name': name,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'image_url': imageUrl,
    });
    return GameItem(
        id: ref.id,
        name: name,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        imageUrl: imageUrl);
  }

  Future<List<Category>> fetchUserCategories(String userId) async {
    final snap = await _db
        .collection('categories')
        .where('created_by', isEqualTo: userId)
        .orderBy('name')
        .get();
    return snap.docs.map((d) => Category.fromMap(d.id, d.data())).toList();
  }

  Future<void> deleteCustomCategory(String categoryId) async {
    final items = await _db
        .collection('items')
        .where('category_id', isEqualTo: categoryId)
        .get();
    final batch = _db.batch();
    for (final doc in items.docs) batch.delete(doc.reference);
    batch.delete(_db.collection('categories').doc(categoryId));
    await batch.commit();
  }

  Future<void> deleteCustomItem(String itemId) async =>
      await _db.collection('items').doc(itemId).delete();
}