# CookFlow Mobile App

Beautiful AI-powered recipe extraction mobile app built with Flutter.

## Features

- 🤖 **AI Recipe Extraction** - Paste any recipe text and get structured output
- 🎨 **Beautiful UI** - Warm, food-inspired Material 3 design
- 📱 **Mobile First** - Optimized for iOS and Android
- ⚡ **Real-time Processing** - Fast Gemini AI integration
- 🎯 **Production Ready** - Clean architecture and error handling

## Screenshots

> Add screenshots here after running the app

## Design Highlights

### Color Palette
- **Primary Orange**: `#FF6B35` - Warm and inviting
- **Accent Green**: `#4CAF50` - Fresh and natural
- **Background**: `#FAFAFA` - Soft off-white
- **Cards**: `#FFFFFF` - Clean white with subtle shadows

### UI Features
- ✅ Rounded corners (16px border radius)
- ✅ Generous spacing and padding
- ✅ Material 3 design system
- ✅ Smooth loading states
- ✅ Beautiful error handling
- ✅ Polished typography
- ✅ Responsive layouts

## Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- iOS Simulator / Android Emulator or physical device
- CookFlow backend running (see `../backend/README.md`)

## Installation

1. **Navigate to app directory:**
```bash
cd cookflow_app
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Configure backend URL:**

Edit `lib/services/api_service.dart` and set the correct backend URL:

- For Android Emulator: `http://10.0.2.2:3000`
- For iOS Simulator: `http://localhost:3000`
- For Physical Device: `http://YOUR_COMPUTER_IP:3000`

```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

4. **Run the app:**
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── theme.dart               # Custom Material 3 theme
├── screens/
│   └── recipe_screen.dart   # Main extraction screen
├── services/
│   └── api_service.dart     # HTTP client & API calls
└── widgets/
    ├── recipe_card.dart     # Beautiful recipe display
    └── json_viewer.dart     # Formatted JSON viewer
```

## Usage

1. **Launch the app** on your device/emulator
2. **Paste recipe text** into the input field (minimum 50 characters)
3. **Tap "Extract Recipe"** to process with AI
4. **View results** in beautifully formatted cards
5. **Check JSON** in the expandable viewer below

### Example Recipe Text

```
Chocolate Chip Cookies

Ingredients:
- 2 cups all-purpose flour
- 1 cup butter, softened
- 1 cup granulated sugar
- 2 large eggs
- 1 tsp vanilla extract
- 1 cup chocolate chips

Instructions:
1. Preheat oven to 350°F (175°C)
2. Mix butter and sugar until fluffy
3. Beat in eggs and vanilla
4. Stir in flour gradually
5. Fold in chocolate chips
6. Drop spoonfuls onto baking sheet
7. Bake for 10-12 minutes until golden
```

## Development

### Running in Debug Mode
```bash
flutter run
```

### Building for Release

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

### Running Tests
```bash
flutter test
```

## API Integration

The app communicates with the CookFlow backend API:

- **Endpoint**: `POST /extract-recipe`
- **Timeout**: 30 seconds
- **Error Handling**: Network errors, validation errors, and server errors

See `lib/services/api_service.dart` for implementation details.

## Customization

### Theme Colors

Edit `lib/theme.dart` to customize the color palette:

```dart
static const Color primaryOrange = Color(0xFFFF6B35);
static const Color accentGreen = Color(0xFF4CAF50);
```

### Spacing

Adjust spacing constants in `AppTheme`:

```dart
static const double spacingM = 16.0;
static const double spacingL = 24.0;
```

## Troubleshooting

### "Failed to connect to backend"
- Ensure backend server is running
- Check the `baseUrl` in `api_service.dart`
- For Android emulator, use `10.0.2.2` instead of `localhost`

### "Request timeout"
- Check your internet connection
- Verify backend is responding (test with cURL)
- Gemini API might be slow - retry

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

## Future Enhancements (Phase 2 & 3)

- 🛒 Grocery list generation
- 🔗 Affiliate purchase links
- 📦 Pantry tracking
- 📅 Meal planning
- 💳 RevenueCat subscriptions
- 🎯 Smart recommendations

## License

MIT

## Support

For issues and questions, please open an issue in the repository.

---

Built with ❤️ for the Creator Hackathon
