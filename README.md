# 🍳 CookFlow

**Production-grade recipe extraction mobile app MVP for Creator Hackathon**

Transform saved recipes into real cooking action with AI-powered extraction, structured data, and beautiful mobile UI.

---

## 🎯 Overview

CookFlow converts recipe links or text into structured, actionable cooking workflows:

**Recipe Text → Structured JSON → Beautiful Display → Future: Grocery Lists & Affiliate Links**

This is an **execution-focused cooking app**, not a browsing app. Turn saved recipes into real cooking action.

---

## ✨ Features (Phase 1 - Current)

- 🤖 **AI-Powered Extraction** - Google Gemini 1.5 Flash for intelligent recipe parsing
- 📋 **Structured Output** - Title, servings, ingredients with quantities, step-by-step instructions
- 🎨 **Beautiful UI** - Warm, food-inspired Material 3 design with rounded corners and generous spacing
- 📱 **Mobile First** - Flutter app optimized for iOS and Android
- ⚡ **Fast & Reliable** - 30s timeout, retry logic, robust error handling
- ✅ **Production Ready** - Clean architecture, defensive coding, comprehensive validation

---

## 💰 Monetization Strategy

### Engine 1: Subscription (Future - RevenueCat)
- Premium planning features
- Pantry tracking
- Unlimited imports
- Smart meal plans

### Engine 2: Affiliate (Future)
- Grocery purchase redirects
- Owner-managed affiliate tags
- Seamless checkout integration

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| **Mobile** | Flutter (Dart) |
| **Backend** | Node.js + Express |
| **AI** | Google Gemini 1.5 Flash API (free tier) |
| **Payments** | RevenueCat (Phase 3) |

---

## 📁 Project Structure

```
cookflow/
├── backend/                    # Node.js API Server
│   ├── server.js              # Express app
│   ├── routes/
│   │   └── extract.js         # /extract-recipe endpoint
│   ├── services/
│   │   └── geminiService.js   # Gemini AI integration
│   ├── utils/
│   │   └── jsonValidator.js   # JSON schema validator
│   ├── package.json
│   ├── .env.example
│   └── README.md
│
└── cookflow_app/              # Flutter Mobile App
    ├── lib/
    │   ├── main.dart          # App entry
    │   ├── theme.dart         # Custom Material 3 theme
    │   ├── screens/
    │   │   └── recipe_screen.dart
    │   ├── services/
    │   │   └── api_service.dart
    │   └── widgets/
    │       ├── recipe_card.dart
    │       └── json_viewer.dart
    ├── pubspec.yaml
    └── README.md
```

---

## 🚀 Quick Start

### Prerequisites

- **Node.js** 16+ and npm
- **Flutter** SDK 3.0+
- **Google Gemini API Key** ([Get one here](https://makersuite.google.com/app/apikey))

### 1. Backend Setup

```bash
cd cookflow/backend
npm install

# Configure environment
cp .env.example .env
# Edit .env and add: GEMINI_API_KEY=your_key_here

# Start server
npm start
```

Server runs on `http://localhost:3000`

### 2. Flutter App Setup

```bash
cd cookflow/cookflow_app
flutter pub get

# Configure backend URL in lib/services/api_service.dart
# For Android Emulator: http://10.0.2.2:3000
# For iOS Simulator: http://localhost:3000

# Run app
flutter run
```

---

## 📸 UI Design Philosophy

### Color Palette
- **Primary**: Warm Orange `#FF6B35`
- **Accent**: Fresh Green `#4CAF50`
- **Background**: Soft Off-White `#FAFAFA`
- **Cards**: Pure White `#FFFFFF` with subtle shadows

### Design Principles
✅ Modern minimal aesthetic  
✅ Warm food-inspired colors  
✅ Soft rounded corners (16-20px radius)  
✅ Generous spacing and padding  
✅ Card-based layout with elevation  
✅ Smooth loading and error states  
✅ Strong typography hierarchy  
✅ NO default ugly widgets  
✅ NO debug-looking UI  

**This is production-grade, not a template demo.**

---

## 🎯 API Documentation

### Extract Recipe Endpoint

**POST** `/extract-recipe`

**Request:**
```json
{
  "raw_text": "Recipe text (minimum 50 characters)..."
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "title": "Chocolate Chip Cookies",
    "servings": "24 cookies",
    "ingredients": [
      { "quantity": "2 cups", "item": "all-purpose flour" },
      { "quantity": "1 cup", "item": "butter, softened" }
    ],
    "steps": [
      "Preheat oven to 350°F",
      "Mix butter and sugar until fluffy"
    ]
  }
}
```

---

## 📋 Phase Roadmap

### ✅ Phase 1 (Current - MVP)
- [x] Gemini extraction backend
- [x] Flutter app shell
- [x] Extraction UI
- [x] Structured JSON display
- [x] Beautiful, polished design

### 🔜 Phase 2 (Next)
- [ ] Grocery list generator
- [ ] Affiliate purchase links
- [ ] Pantry tracking system

### 🚀 Phase 3 (Future)
- [ ] RevenueCat subscriptions
- [ ] Meal planning features
- [ ] Premium tier unlocks
- [ ] Smart recommendations

---

## 🧪 Testing

### Backend Test
```bash
curl -X POST http://localhost:3000/extract-recipe \
  -H "Content-Type: application/json" \
  -d '{
    "raw_text": "Chocolate Chip Cookies: Mix 2 cups flour, 1 cup butter, 1 cup sugar, 2 eggs. Add 1 cup chocolate chips. Bake at 350F for 12 minutes until golden."
  }'
```

### Mobile App Test
1. Launch app on emulator/device
2. Paste the example recipe above
3. Tap "Extract Recipe"
4. Verify beautiful card display
5. Check JSON viewer for structured data

---

## 🎨 UI/UX Quality Checklist

- ✅ Warm, food-inspired color palette
- ✅ Rounded corners (16-20px)
- ✅ Generous spacing (16-32px padding)
- ✅ Card-based layout with shadows
- ✅ Smooth loading spinner
- ✅ Disabled button during request
- ✅ Styled error snackbar
- ✅ Empty state messaging
- ✅ Keyboard-safe scrolling
- ✅ Responsive spacing
- ✅ Clean sans-serif typography
- ✅ Strong visual hierarchy

**Result: Production-grade aesthetic that wows users.**

---

## 🔧 Architecture Highlights

### Backend
- Express REST API with CORS
- Gemini AI service with precise prompting
- JSON schema validation
- 30-second timeout with retry
- Structured error responses

### Frontend
- Clean widget architecture
- Separation of concerns (screens/widgets/services)
- Type-safe API models
- Reusable theme system
- Defensive error handling

---

## 📝 Environment Variables

### Backend `.env`
```bash
GEMINI_API_KEY=your_gemini_api_key
PORT=3000
```

---

## 🐛 Troubleshooting

### Backend Issues
- **"GEMINI_API_KEY is not configured"**: Add API key to `.env`
- **"Request timeout"**: Check Gemini API status, retry

### Flutter Issues
- **"Failed to connect"**: Check backend URL in `api_service.dart`
- **Android emulator**: Use `10.0.2.2:3000` not `localhost:3000`
- **Build errors**: Run `flutter clean && flutter pub get`

---

## 📄 License

MIT

---

## 🏆 Built For

**Creator Hackathon** - Production-grade mobile app MVP

**Goal**: Real, monetizable application with beautiful UX, not a template demo.

---

**Built with ❤️ and AI**
