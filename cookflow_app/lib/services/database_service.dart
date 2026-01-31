import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PantryItem {
  final int? id;
  final String name;
  final String quantity;
  final String? category;
  final DateTime? expiryDate;
  final DateTime addedDate;

  PantryItem({
    this.id,
    required this.name,
    required this.quantity,
    this.category,
    this.expiryDate,
    DateTime? addedDate,
  }) : addedDate = addedDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'expiryDate': expiryDate?.toIso8601String(),
      'addedDate': addedDate.toIso8601String(),
    };
  }

  factory PantryItem.fromMap(Map<String, dynamic> map) {
    return PantryItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      quantity: map['quantity'] as String,
      category: map['category'] as String?,
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'] as String)
          : null,
      addedDate: DateTime.parse(map['addedDate'] as String),
    );
  }

  /// Check if item is expiring soon (within 7 days)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry >= 0;
  }

  /// Check if item is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  /// Get days until expiry (negative if expired)
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }
}

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cookflow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pantry_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity TEXT NOT NULL,
        category TEXT,
        expiryDate TEXT,
        addedDate TEXT NOT NULL
      )
    ''');
  }

  /// Create a new pantry item
  Future<PantryItem> createPantryItem(PantryItem item) async {
    final db = await database;
    final id = await db.insert('pantry_items', item.toMap());
    return item.copyWith(id: id);
  }

  /// Get all pantry items
  Future<List<PantryItem>> getAllPantryItems() async {
    final db = await database;
    final result = await db.query(
      'pantry_items',
      orderBy: 'addedDate DESC',
    );
    return result.map((map) => PantryItem.fromMap(map)).toList();
  }

  /// Get pantry items by category
  Future<List<PantryItem>> getPantryItemsByCategory(String category) async {
    final db = await database;
    final result = await db.query(
      'pantry_items',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'addedDate DESC',
    );
    return result.map((map) => PantryItem.fromMap(map)).toList();
  }

  /// Get expiring items (within days)
  Future<List<PantryItem>> getExpiringItems({int days = 7}) async {
    final db = await database;
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    final result = await db.query(
      'pantry_items',
      where: 'expiryDate IS NOT NULL AND expiryDate <= ?',
      whereArgs: [futureDate.toIso8601String()],
      orderBy: 'expiryDate ASC',
    );
    return result.map((map) => PantryItem.fromMap(map)).toList();
  }

  /// Search pantry items by name
  Future<List<PantryItem>> searchPantryItems(String query) async {
    final db = await database;
    final result = await db.query(
      'pantry_items',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'addedDate DESC',
    );
    return result.map((map) => PantryItem.fromMap(map)).toList();
  }

  /// Update a pantry item
  Future<int> updatePantryItem(PantryItem item) async {
    final db = await database;
    return db.update(
      'pantry_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// Delete a pantry item
  Future<int> deletePantryItem(int id) async {
    final db = await database;
    return db.delete(
      'pantry_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all expired items
  Future<int> deleteExpiredItems() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return db.delete(
      'pantry_items',
      where: 'expiryDate IS NOT NULL AND expiryDate < ?',
      whereArgs: [now],
    );
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

// Extension to add copyWith method
extension PantryItemCopyWith on PantryItem {
  PantryItem copyWith({
    int? id,
    String? name,
    String? quantity,
    String? category,
    DateTime? expiryDate,
    DateTime? addedDate,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      addedDate: addedDate ?? this.addedDate,
    );
  }
}
