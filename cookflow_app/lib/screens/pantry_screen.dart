import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../widgets/pantry_item_card.dart';
import '../theme.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final _dbService = DatabaseService.instance;
  List<PantryItem> _allItems = [];
  List<PantryItem> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPantryItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPantryItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _dbService.getAllPantryItems();
      setState(() {
        _allItems = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load pantry items: $e');
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems
            .where((item) =>
                item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _showAddEditDialog({PantryItem? item}) async {
    final nameController = TextEditingController(text: item?.name ?? '');
    final quantityController =
        TextEditingController(text: item?.quantity ?? '');
    final categoryController =
        TextEditingController(text: item?.category ?? '');
    DateTime? selectedDate = item?.expiryDate;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Add Pantry Item' : 'Edit Pantry Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name *',
                  hintText: 'e.g., Milk',
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity *',
                  hintText: 'e.g., 1 gallon',
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'e.g., Dairy',
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              StatefulBuilder(
                builder: (context, setDialogState) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Expiry Date (Optional)'),
                  subtitle: Text(
                    selectedDate == null
                        ? 'No expiry date set'
                        : '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setDialogState(() => selectedDate = null);
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setDialogState(() => selectedDate = date);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty ||
                  quantityController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Name and quantity are required'),
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text(item == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final newItem = PantryItem(
        id: item?.id,
        name: nameController.text.trim(),
        quantity: quantityController.text.trim(),
        category: categoryController.text.trim().isEmpty
            ? null
            : categoryController.text.trim(),
        expiryDate: selectedDate,
      );

      try {
        if (item == null) {
          await _dbService.createPantryItem(newItem);
        } else {
          await _dbService.updatePantryItem(newItem);
        }
        _loadPantryItems();
      } catch (e) {
        _showError('Failed to save item: $e');
      }
    }
  }

  Future<void> _deleteItem(PantryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Remove "${item.name}" from pantry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbService.deletePantryItem(item.id!);
        _loadPantryItems();
      } catch (e) {
        _showError('Failed to delete item: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expiringItems =
        _allItems.where((item) => item.isExpiringSoon).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pantry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPantryItems,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: TextField(
              controller: _searchController,
              onChanged: _filterItems,
              decoration: InputDecoration(
                hintText: 'Search pantry items...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterItems('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Expiring Soon Warning
          if (expiringItems.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Text(
                      '${expiringItems.length} item(s) expiring soon!',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Items List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: AppTheme.textLight,
                            ),
                            const SizedBox(height: AppTheme.spacingM),
                            Text(
                              _allItems.isEmpty
                                  ? 'No items in pantry'
                                  : 'No items match your search',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: AppTheme.textMedium),
                            ),
                            const SizedBox(height: AppTheme.spacingS),
                            if (_allItems.isEmpty)
                              Text(
                                'Tap + to add your first item',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          return PantryItemCard(
                            item: _filteredItems[index],
                            onEdit: () =>
                                _showAddEditDialog(item: _filteredItems[index]),
                            onDelete: () => _deleteItem(_filteredItems[index]),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
