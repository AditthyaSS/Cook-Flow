# CookFlow Backend API

Production-grade recipe extraction API powered by Google Gemini AI.

## Features

- 🤖 AI-powered recipe extraction using Gemini 1.5 Flash
- ✅ Input validation and JSON schema verification
- 🔄 Automatic retry logic with timeout handling
- 🛡️ Robust error handling and logging
- 🌐 CORS enabled for mobile/web clients

## Setup

### Prerequisites

- Node.js 16+ and npm
- Google Gemini API key ([Get one here](https://makersuite.google.com/app/apikey))

### Installation

```bash
cd backend
npm install
```

### Configuration

1. Copy the example environment file:
```bash
cp .env.example .env
```

2. Edit `.env` and add your Gemini API key:
```
GEMINI_API_KEY=your_actual_api_key_here
PORT=3000
```

### Running the Server

**Development mode (with auto-reload):**
```bash
npm run dev
```

**Production mode:**
```bash
npm start
```

The server will start on `http://localhost:3000`

## API Documentation

### Extract Recipe

Extract structured recipe data from raw text.

**Endpoint:** `POST /extract-recipe`

**Request Body:**
```json
{
  "raw_text": "Chocolate Chip Cookies\n\nIngredients:\n- 2 cups all-purpose flour\n- 1 cup butter, softened\n- 1 cup sugar\n- 2 eggs\n- 1 tsp vanilla\n- 1 cup chocolate chips\n\nDirections:\n1. Preheat oven to 350°F\n2. Mix butter and sugar until fluffy\n3. Beat in eggs and vanilla\n4. Stir in flour\n5. Fold in chocolate chips\n6. Bake for 12 minutes"
}
```

**Validation Rules:**
- `raw_text` must be a string
- Minimum length: 50 characters

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "title": "Chocolate Chip Cookies",
    "servings": "24 cookies",
    "ingredients": [
      { "quantity": "2 cups", "item": "all-purpose flour" },
      { "quantity": "1 cup", "item": "butter, softened" },
      { "quantity": "1 cup", "item": "sugar" },
      { "quantity": "2", "item": "eggs" },
      { "quantity": "1 tsp", "item": "vanilla" },
      { "quantity": "1 cup", "item": "chocolate chips" }
    ],
    "steps": [
      "Preheat oven to 350°F",
      "Mix butter and sugar until fluffy",
      "Beat in eggs and vanilla",
      "Stir in flour",
      "Fold in chocolate chips",
      "Bake for 12 minutes"
    ]
  }
}
```

**Error Response (400/500):**
```json
{
  "success": false,
  "error": "Error description"
}
```

### Health Check

**Endpoint:** `GET /health`

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2026-01-30T16:10:25.000Z",
  "service": "CookFlow API"
}
```

## Testing

### Using cURL

```bash
curl -X POST http://localhost:3000/extract-recipe \
  -H "Content-Type: application/json" \
  -d '{
    "raw_text": "Pasta Carbonara: Cook 400g spaghetti. Fry 200g bacon. Mix 4 eggs with parmesan. Combine all and serve hot."
  }'
```

### Using Postman

1. Create a new POST request
2. URL: `http://localhost:3000/extract-recipe`
3. Headers: `Content-Type: application/json`
4. Body (raw JSON):
```json
{
  "raw_text": "Your recipe text here (minimum 50 characters)..."
}
```

## Architecture

```
backend/
├── server.js                 # Express app initialization
├── routes/
│   └── extract.js           # Recipe extraction endpoint
├── services/
│   └── geminiService.js     # Gemini AI integration
├── utils/
│   └── jsonValidator.js     # Recipe JSON schema validator
├── .env.example             # Environment template
├── package.json             # Dependencies
└── README.md               # This file
```

## Error Handling

The API handles various error scenarios:

- **Input validation errors** (400): Invalid or missing `raw_text`
- **Gemini API errors** (500): API key issues, timeout, rate limits
- **JSON parsing errors** (500): Malformed AI response
- **Schema validation errors** (500): Invalid recipe structure

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `GEMINI_API_KEY` | Yes | Google Gemini API key |
| `PORT` | No | Server port (default: 3000) |

## License

MIT
