import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';

class CategoryService {
  final SupabaseClient _client = Supabase.instance.client;

  // Nur echte Hauptkategorien (parent_id IS NULL)
  Future<List<Category>> fetchMainCategories() async {
    final data = await _client
        .from('categories')
        .select()
        .isFilter('parent_id', null)
        .order('name');
    return (data as List)
        .map((e) => Category.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // Unterkategorien einer Kategorie (egal welche Ebene)
  Future<List<SubCategory>> fetchSubCategories(String categoryId) async {
    final data = await _client
        .from('categories')
        .select()
        .eq('parent_id', categoryId)
        .order('name');
    return (data as List)
        .map((e) => SubCategory.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // Items laden — unterstützt jetzt auch Unter-Unterkategorien:
  // Wenn subCategoryId gesetzt ist, werden Items dieser Sub geladen.
  // Falls die Sub selbst noch Kinder hat, werden deren Items auch inkludiert.
  Future<List<GameItem>> fetchItems({
    required String categoryId,
    String? subCategoryId,
  }) async {
    if (subCategoryId != null) {
      // Prüfen ob diese Sub noch Kinder hat
      final children = await fetchSubCategories(subCategoryId);
      if (children.isNotEmpty) {
        // Items aller Kinder sammeln
        final allItems = <GameItem>[];
        for (final child in children) {
          final childItems = await _fetchItemsForSub(
              categoryId: categoryId, subCategoryId: child.id);
          allItems.addAll(childItems);
        }
        // Auch direkte Items dieser Sub
        final direct = await _fetchItemsForSub(
            categoryId: categoryId, subCategoryId: subCategoryId);
        allItems.addAll(direct);
        // Deduplizieren
        final seen = <String>{};
        return allItems.where((i) => seen.add(i.id)).toList();
      }
      return _fetchItemsForSub(
          categoryId: categoryId, subCategoryId: subCategoryId);
    }
    // Keine Sub → alle Items der Hauptkategorie
    final data = await _client
        .from('items')
        .select()
        .eq('category_id', categoryId)
        .order('name');
    return (data as List)
        .map((e) => GameItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<GameItem>> _fetchItemsForSub({
    required String categoryId,
    required String subCategoryId,
  }) async {
    final data = await _client
        .from('items')
        .select()
        .eq('category_id', categoryId)
        .eq('sub_category_id', subCategoryId)
        .order('name');
    return (data as List)
        .map((e) => GameItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<GameItem?> fetchItemById(String id) async {
    final data =
        await _client.from('items').select().eq('id', id).maybeSingle();
    return data != null ? GameItem.fromMap(data) : null;
  }

  Future<List<GameItem>> fetchItemsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final data = await _client.from('items').select().inFilter('id', ids);
    return (data as List)
        .map((e) => GameItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<Category> createCustomCategory({
    required String name,
    required String userId,
    String? parentId,
  }) async {
    final data = await _client
        .from('categories')
        .insert({
          'name': name,
          'parent_id': parentId,
          'created_by': userId,
        })
        .select()
        .single();
    return Category.fromMap(data);
  }

  Future<GameItem> addCustomItem({
    required String name,
    required String categoryId,
    String? subCategoryId,
    String? imageUrl,
  }) async {
    final data = await _client
        .from('items')
        .insert({
          'name': name,
          'category_id': categoryId,
          'sub_category_id': subCategoryId,
          'image_url': imageUrl,
        })
        .select()
        .single();
    return GameItem.fromMap(data);
  }

  Future<List<Category>> fetchUserCategories(String userId) async {
    final data = await _client
        .from('categories')
        .select()
        .eq('created_by', userId)
        .order('name');
    return (data as List)
        .map((e) => Category.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteCustomCategory(String categoryId) async {
    await _client.from('items').delete().eq('category_id', categoryId);
    await _client.from('categories').delete().eq('id', categoryId);
  }

  Future<void> deleteCustomItem(String itemId) async {
    await _client.from('items').delete().eq('id', itemId);
  }
}
