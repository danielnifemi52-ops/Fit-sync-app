# Firebase Backend Setup & Deployment

## Prerequisites

1. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Login to Firebase:
```bash
firebase login
```

3. Create a Firebase project at https://console.firebase.google.com

## Configuration

1. Set your Firebase project ID:
```bash
firebase use --add
```

2. Set the OpenAI API key:
```bash
firebase functions:config:set openai.key="sk-YOUR_OPENAI_KEY"
```

3. Enable Firebase Auth and Firestore in the Firebase console.

## Install Dependencies

```bash
cd functions
npm install
```

## Local Development

Run the Firebase emulators:
```bash
cd functions
npm run serve
```

The API will be available at:
`http://localhost:5001/YOUR_PROJECT_ID/us-central1/api`

## Deployment

1. Build the TypeScript code:
```bash
cd functions
npm run build
```

2. Deploy to Firebase:
```bash
firebase deploy --only functions,firestore
```

## API Endpoints

Base URL: `https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/api`

### Authentication
All endpoints require a Firebase Auth token in the `Authorization` header:
```
Authorization: Bearer <FIREBASE_ID_TOKEN>
```

### Meal Plans
- `POST /meal-plan/generate` - Generate meal plan (Premium)
- `POST /meal-plan/swap-meal` - Swap meal (Premium)
- `GET /meal-plan/current` - Get current plan

### Workout Plans
- `POST /workout-plan/generate` - Generate workout (Premium)
- `POST /workout-plan/swap-exercise` - Swap exercise (Premium)
- `GET /workout-plan/current` - Get current plan

### AI Coach
- `POST /ai-coach/insight` - Get daily insight
- `POST /ai-coach/plateau-analysis` - Plateau analysis (Premium)

### Progress
- `POST /progress/log-weight` - Log weight
- `POST /progress/log-calories` - Log calories
- `POST /progress/log-workout` - Log workout
- `GET /progress/analytics` - Get analytics data

### User
- `GET /user/profile` - Get profile
- `PUT /user/profile` - Update profile
- `POST /user/upgrade-premium` - Upgrade to premium

## Testing

Test with curl or Postman:
```bash
curl -X POST https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/api/meal-plan/generate \
  -H "Authorization: Bearer <YOUR_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"adjustmentReason": "Test"}'
```
