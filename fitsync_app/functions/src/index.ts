import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import express from 'express';
import cors from 'cors';

// Initialize Firebase Admin
admin.initializeApp();

// Create Express app
const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// Import routes
import { mealPlanRoutes } from './routes/mealPlan';
import { workoutPlanRoutes } from './routes/workoutPlan';
import { aiCoachRoutes } from './routes/aiCoach';
import { progressRoutes } from './routes/progress';
import { userRoutes } from './routes/user';

// Register routes
app.use('/meal-plan', mealPlanRoutes);
app.use('/workout-plan', workoutPlanRoutes);
app.use('/ai-coach', aiCoachRoutes);
app.use('/progress', progressRoutes);
app.use('/user', userRoutes);

// Export the Express app as a Cloud Function
export const api = functions.https.onRequest(app);
