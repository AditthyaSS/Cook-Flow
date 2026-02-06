import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookflow_app/services/auth_service.dart';
import 'package:cookflow_app/services/database_service.dart';

/// Firestore sync service for cloud recipe storage
/// Syncs local SQLite data with Firebase Firestore for cross-device access
class FirestoreService {
  static final FirestoreService instance = FirestoreService._init();
  FirestoreService._init();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user-specific collection reference
  CollectionReference? _getUserCollection(String collectionName) {
    final userId = AuthService.instance.currentUser?.uid;
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId).collection(collectionName);
  }

  // ========== RECIPE SYNC ==========

  /// Sync a recipe to Firestore
  Future<void> syncRecipe(Recipe recipe) async {
    final collection = _getUserCollection('recipes');
    if (collection == null) return;

    final docId = recipe.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    await collection.doc(docId).set({
      'title': recipe.title,
      'servings': recipe.servings,
      'ingredients': recipe.toMap()['ingredients'],
      'steps': recipe.toMap()['steps'],
      'createdDate': recipe.createdDate.toIso8601String(),
      'isFavorite': recipe.isFavorite,
      'prepTimeMinutes': recipe.prepTimeMinutes,
      'cookTimeMinutes': recipe.cookTimeMinutes,
      'difficulty': recipe.difficulty,
      'cuisine': recipe.cuisine,
      'tags': recipe.tags,
      'notes': recipe.notes,
      'localId': recipe.id,
      'syncedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Pull all recipes from Firestore to local database
  Future<void> pullRecipes() async {
    final collection = _getUserCollection('recipes');
    if (collection == null) return;

    final snapshot = await collection.get();
    
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Check if recipe already exists locally
      final localId = data['localId'] as int?;
      bool recipeExists = false;
      
      if (localId != null) {
        final existing = await DatabaseService.instance.getRecipeById(localId);
        recipeExists = existing != null;
      }
      
      // Only create if doesn't exist
      if (!recipeExists) {
        final recipe = Recipe(
          title: data['title'] as String,
          servings: data['servings'] as String,
          ingredients: Recipe._decodeIngredients(data['ingredients'] as String),
          steps: Recipe._decodeSteps(data['steps'] as String),
          createdDate: DateTime.parse(data['createdDate'] as String),
          isFavorite: data['isFavorite'] == 1 || data['isFavorite'] == true,
          prepTimeMinutes: data['prepTimeMinutes'] as int?,
          cookTimeMinutes: data['cookTimeMinutes'] as int?,
          difficulty: data['difficulty'] as String?,
          cuisine: data['cuisine'] as String?,
          tags: data['tags'] != null ? Recipe._decodeTags(data['tags'] as String) : null,
          notes: data['notes'] as String?,
        );
        
        await DatabaseService.instance.createRecipe(recipe);
      }
    }
  }

  /// Delete recipe from Firestore
  Future<void> deleteRecipeFromFirestore(int recipeId) async {
    final collection = _getUserCollection('recipes');
    if (collection == null) return;

    // Find and delete by localId
    final snapshot = await collection.where('localId', isEqualTo: recipeId).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // ========== PANTRY SYNC ==========

  /// Sync pantry item to Firestore
  Future<void> syncPantryItem(PantryItem item) async {
    final collection = _getUserCollection('pantry');
    if (collection == null) return;

    final docId = item.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    await collection.doc(docId).set({
      'name': item.name,
      'quantity': item.quantity,
      'category': item.category,
      'expiryDate': item.expiryDate?.toIso8601String(),
      'addedDate': item.addedDate.toIso8601String(),
      'localId': item.id,
      'syncedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Pull all pantry items from Firestore
  Future<void> pullPantryItems() async {
    final collection = _getUserCollection('pantry');
    if (collection == null) return;

    final snapshot = await collection.get();
    
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Check if item already exists locally
      final localId = data['localId'] as int?;
      bool itemExists = false;
      
      if (localId != null) {
        final items = await DatabaseService.instance.getAllPantryItems();
        itemExists = items.any((item) => item.id == localId);
      }
      
      // Only create if doesn't exist
      if (!itemExists) {
        final item = PantryItem(
          name: data['name'] as String,
          quantity: data['quantity'] as String,
          category: data['category'] as String?,
          expiryDate: data['expiryDate'] != null 
              ? DateTime.parse(data['expiryDate'] as String)
              : null,
          addedDate: DateTime.parse(data['addedDate'] as String),
        );
        
        await DatabaseService.instance.createPantryItem(item);
      }
    }
  }

  /// Sync all local data to Firestore (called after sign-in)
  Future<void> syncAllToCloud() async {
    // Sync recipes
    final recipes = await DatabaseService.instance.getAllRecipes();
    for (final recipe in recipes) {
      await syncRecipe(recipe);
    }
    
    // Sync pantry
    final pantryItems = await DatabaseService.instance.getAllPantryItems();
    for (final item in pantryItems) {
      await syncPantryItem(item);
    }
  }

  /// Pull all data from Firestore to local (called after sign-in)
  Future<void> pullAllFromCloud() async {
    await pullRecipes();
    await pullPantryItems();
  }
}
