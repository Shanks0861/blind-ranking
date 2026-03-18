import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';

class CategoryService {
  final SupabaseClient _client = Supabase.instance.client;

  // ── Kategorien laden ───────────────────────────────────────────────────────

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

  // ── Items laden ────────────────────────────────────────────────────────────

  Future<List<GameItem>> fetchItems({
    required String categoryId,
    String? subCategoryId,
  }) async {
    var query = _client.from('items').select().eq('category_id', categoryId);

    if (subCategoryId != null) {
      query = query.eq('sub_category_id', subCategoryId);
    }

    final data = await query.order('name');
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

  // ── Custom Kategorien ──────────────────────────────────────────────────────

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
