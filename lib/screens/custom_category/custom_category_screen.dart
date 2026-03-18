import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';
import '../../services/purchase_service.dart';
import '../../utils/app_theme.dart';

class CustomCategoryScreen extends StatefulWidget {
  final AppUser currentUser;

  const CustomCategoryScreen({super.key, required this.currentUser});

  @override
  State<CustomCategoryScreen> createState() => _CustomCategoryScreenState();
}

class _CustomCategoryScreenState extends State<CustomCategoryScreen> {
  final _categoryService = CategoryService();
  final _purchaseService = PurchaseService();

  List<Category> _myCategories = [];
  bool _isPremium = false;
  bool _loading = true;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final premium = await _purchaseService.isPremium(widget.currentUser.id);
    final cats =
        await _categoryService.fetchUserCategories(widget.currentUser.id);
    setState(() {
      _isPremium = premium;
      _myCategories = cats;
      _loading = false;
    });
  }

  Future<void> _handlePurchase() async {
    setState(() => _purchasing = true);
    final result =
        await _purchaseService.purchasePremium(widget.currentUser.id);
    setState(() => _purchasing = false);

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() => _isPremium = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Premium freigeschaltet!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    } else if (result.isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Fehler beim Kauf')),
      );
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _purchasing = true);
    final result =
        await _purchaseService.restorePurchases(widget.currentUser.id);
    setState(() => _purchasing = false);

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() => _isPremium = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Kauf wiederhergestellt!'),
            backgroundColor: Color(0xFF2E7D32)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kein früherer Kauf gefunden')),
      );
    }
  }

  void _openCreateCategory() async {
    final result = await Navigator.push<Category>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateCategoryScreen(
          currentUser: widget.currentUser,
          categoryService: _categoryService,
        ),
      ),
    );
    if (result != null) {
      setState(() => _myCategories.insert(0, result));
    }
  }

  void _openManageCategory(Category cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManageCategoryScreen(
          category: cat,
          currentUser: widget.currentUser,
          categoryService: _categoryService,
        ),
      ),
    );
  }

  Future<void> _deleteCategory(Category cat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Kategorie löschen?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text('„${cat.name}" und alle Items werden gelöscht.',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _categoryService.deleteCustomCategory(cat.id);
    setState(() => _myCategories.removeWhere((c) => c.id == cat.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Eigene Kategorien'),
        actions: [
          if (_isPremium)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _openCreateCategory,
              tooltip: 'Neue Kategorie',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _isPremium
              ? _buildPremiumContent()
              : _buildPaywall(),
    );
  }

  Widget _buildPaywall() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Icon
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 44),
          ),
          const SizedBox(height: 24),
          const Text(
            'Eigene Kategorien',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Erstelle deine eigenen Kategorien und Items — für grenzenlose Spielideen.',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 15, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Feature Liste
          ..._features.map((f) => _featureRow(f.$1, f.$2)),
          const SizedBox(height: 32),
          // Kauf Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _purchasing ? null : _handlePurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _purchasing
                  ? const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)
                  : const Text(
                      'Jetzt freischalten – ${PurchaseService.priceLabel}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          // Einmalige Zahlung
          const Text(
            'Einmaliger Kauf · Kein Abo · Für immer',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          // Restore
          TextButton(
            onPressed: _purchasing ? null : _restorePurchases,
            child: const Text(
              'Kauf wiederherstellen',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Durch den Kauf stimmst du den App Store Nutzungsbedingungen zu.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static const _features = [
    (Icons.category_outlined, 'Eigene Kategorien erstellen'),
    (Icons.add_photo_alternate_outlined, 'Beliebige Items hinzufügen'),
    (Icons.image_outlined, 'Bilder per URL verknüpfen'),
    (Icons.save_outlined, 'Kategorien speichern & wiederverwenden'),
    (Icons.group_outlined, 'Mit Freunden in der Lobby nutzen'),
  ];

  Widget _featureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Text(text,
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildPremiumContent() {
    return Column(
      children: [
        // Premium Badge
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text('Premium aktiv',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ),
        // Kategorien Liste
        Expanded(
          child: _myCategories.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _myCategories.length,
                  itemBuilder: (_, i) => _buildCategoryTile(_myCategories[i]),
                ),
        ),
        // Neue Kategorie Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _openCreateCategory,
              icon: const Icon(Icons.add),
              label: const Text('Neue Kategorie erstellen'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined,
              size: 64, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text('Noch keine eigenen Kategorien',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Tippe auf „+" um loszulegen',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(Category cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.category_outlined,
              color: AppColors.primary, size: 22),
        ),
        title: Text(cat.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            )),
        subtitle: const Text('Tippe zum Verwalten',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: AppColors.textSecondary, size: 20),
              onPressed: () => _openManageCategory(cat),
            ),
            IconButton(
              icon:
                  const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => _deleteCategory(cat),
            ),
          ],
        ),
        onTap: () => _openManageCategory(cat),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Neue Kategorie erstellen
// ─────────────────────────────────────────────────────────────────────────────

class CreateCategoryScreen extends StatefulWidget {
  final AppUser currentUser;
  final CategoryService categoryService;

  const CreateCategoryScreen({
    super.key,
    required this.currentUser,
    required this.categoryService,
  });

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final _nameCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Bitte gib einen Namen ein');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final cat = await widget.categoryService.createCustomCategory(
        name: name,
        userId: widget.currentUser.id,
      );
      if (mounted) Navigator.pop(context, cat);
    } catch (e) {
      setState(() => _error = 'Fehler: ${e.toString()}');
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Neue Kategorie'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Speichern',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Kategoriename',
                hintText: 'z.B. „Unsere Lieblingsfilme"',
                prefixIcon: Icon(Icons.category_outlined,
                    color: AppColors.textSecondary),
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _save(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.textSecondary, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Nach dem Erstellen kannst du der Kategorie beliebig viele Items hinzufügen.',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kategorie verwalten (Items hinzufügen / löschen)
// ─────────────────────────────────────────────────────────────────────────────

class ManageCategoryScreen extends StatefulWidget {
  final Category category;
  final AppUser currentUser;
  final CategoryService categoryService;

  const ManageCategoryScreen({
    super.key,
    required this.category,
    required this.currentUser,
    required this.categoryService,
  });

  @override
  State<ManageCategoryScreen> createState() => _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends State<ManageCategoryScreen> {
  List<GameItem> _items = [];
  bool _loading = true;
  bool _adding = false;

  final _nameCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  String? _addError;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final items = await widget.categoryService.fetchItems(
      categoryId: widget.category.id,
    );
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _addItem() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _addError = 'Name ist pflicht');
      return;
    }
    setState(() {
      _adding = true;
      _addError = null;
    });
    try {
      final item = await widget.categoryService.addCustomItem(
        name: name,
        categoryId: widget.category.id,
        imageUrl:
            _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
      );
      _nameCtrl.clear();
      _imageCtrl.clear();
      setState(() => _items.insert(0, item));
    } catch (e) {
      setState(() => _addError = 'Fehler: ${e.toString()}');
    } finally {
      setState(() => _adding = false);
    }
  }

  Future<void> _deleteItem(GameItem item) async {
    await widget.categoryService.deleteCustomItem(item.id);
    setState(() => _items.removeWhere((i) => i.id == item.id));
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Neues Item',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  prefixIcon:
                      Icon(Icons.label_outline, color: AppColors.textSecondary),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _imageCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Bild-URL (optional)',
                  hintText: 'https://...',
                  prefixIcon: Icon(Icons.image_outlined,
                      color: AppColors.textSecondary),
                ),
                keyboardType: TextInputType.url,
              ),
              if (_addError != null) ...[
                const SizedBox(height: 8),
                Text(_addError!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _adding
                      ? null
                      : () async {
                          await _addItem();
                          if (mounted && _addError == null) Navigator.pop(ctx);
                        },
                  child: _adding
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text('Item hinzufügen',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.category.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_items.length} Items',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Item hinzufügen',
            style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      const Text('Noch keine Items',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 16)),
                      const SizedBox(height: 8),
                      const Text('Tippe auf „+ Item hinzufügen"',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: _items.length,
                  itemBuilder: (_, i) => _buildItemTile(_items[i]),
                ),
    );
  }

  Widget _buildItemTile(GameItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: item.imageUrl != null
              ? Image.network(
                  item.imageUrl!,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _itemPlaceholder(),
                )
              : _itemPlaceholder(),
        ),
        title: Text(item.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            )),
        subtitle: item.imageUrl != null
            ? Text(item.imageUrl!,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11),
                overflow: TextOverflow.ellipsis)
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          onPressed: () => _deleteItem(item),
        ),
      ),
    );
  }

  Widget _itemPlaceholder() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_outlined,
          color: AppColors.textSecondary, size: 20),
    );
  }
}
