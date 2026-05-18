import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';
import '../../utils/app_theme.dart';

class CustomCategoryScreen extends StatefulWidget {
  final AppUser currentUser;
  const CustomCategoryScreen({super.key, required this.currentUser});

  @override
  State<CustomCategoryScreen> createState() => _CustomCategoryScreenState();
}

class _CustomCategoryScreenState extends State<CustomCategoryScreen> {
  final _categoryService = CategoryService();
  List<Category> _myCategories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cats = await _categoryService.fetchUserCategories(widget.currentUser.id);
    setState(() { _myCategories = cats; _loading = false; });
  }

  Future<void> _createCategory() async {
    final name = await _showNameDialog('Neue Kategorie', 'Kategoriename');
    if (name == null || name.isEmpty) return;
    setState(() => _loading = true);
    await _categoryService.createCustomCategory(name: name, userId: widget.currentUser.id);
    await _load();
  }

  Future<void> _deleteCategory(Category cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Löschen?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Kategorie "${cat.name}" und alle Items darin werden gelöscht.', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Löschen', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _loading = true);
      await _categoryService.deleteCustomCategory(cat.id);
      await _load();
    }
  }

  Future<String?> _showNameDialog(String title, String hint) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Erstellen', style: TextStyle(color: AppColors.primary))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eigene Kategorien'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _createCategory),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _myCategories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.category_outlined, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      const Text('Keine eigenen Kategorien', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _createCategory,
                        icon: const Icon(Icons.add),
                        label: const Text('Kategorie erstellen'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _myCategories.length,
                  itemBuilder: (_, i) {
                    final cat = _myCategories[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.category, color: AppColors.primary, size: 22),
                        ),
                        title: Text(cat.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Eigene Kategorie', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteCategory(cat),
                        ),
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => CategoryItemsScreen(category: cat, currentUser: widget.currentUser),
                        )).then((_) => _load()),
                      ),
                    );
                  },
                ),
    );
  }
}

class CategoryItemsScreen extends StatefulWidget {
  final Category category;
  final AppUser currentUser;
  const CategoryItemsScreen({super.key, required this.category, required this.currentUser});

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  final _categoryService = CategoryService();
  List<GameItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _categoryService.fetchItems(categoryId: widget.category.id);
    setState(() { _items = items; _loading = false; });
  }

  Future<void> _addItem() async {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Neues Item', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, autofocus: true, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(hintText: 'Name')),
            const SizedBox(height: 12),
            TextField(controller: urlCtrl, style: const TextStyle(color: AppColors.textPrimary), decoration: const InputDecoration(hintText: 'Bild-URL (optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              await _categoryService.addCustomItem(
                name: nameCtrl.text.trim(),
                categoryId: widget.category.id,
                imageUrl: urlCtrl.text.trim().isEmpty ? null : urlCtrl.text.trim(),
              );
              if (mounted) Navigator.pop(context);
              await _load();
            },
            child: const Text('Hinzufügen', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(GameItem item) async {
    await _categoryService.deleteCustomItem(item.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _addItem)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.list_alt_outlined, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      const Text('Noch keine Items', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(onPressed: _addItem, icon: const Icon(Icons.add), label: const Text('Item hinzufügen')),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final item = _items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: ListTile(
                        leading: item.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(item.imageUrl!, width: 42, height: 42, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: AppColors.textSecondary)),
                              )
                            : const Icon(Icons.image_outlined, color: AppColors.textSecondary),
                        title: Text(item.name, style: const TextStyle(color: AppColors.textPrimary)),
                        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _deleteItem(item)),
                      ),
                    );
                  },
                ),
    );
  }
}
