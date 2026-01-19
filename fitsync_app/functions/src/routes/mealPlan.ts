import { Router, Request, Response } from 'express';
import * as admin from 'firebase-admin';
import { openAIService } from '../services/openai.service';

export const mealPlanRoutes = Router();

// Middleware to verify Firebase Auth token
async function authenticate(req: Request, res: Response, next: any) {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Unauthorized' });
    }

    try {
        const token = authHeader.split('Bearer ')[1];
        const decodedToken = await admin.auth().verifyIdToken(token);
        (req as any).user = decodedToken;
        next();
    } catch (error) {
        return res.status(401).json({ error: 'Invalid token' });
    }
}

// Generate meal plan (Premium only)
mealPlanRoutes.post('/generate', authenticate, async (req: Request, res: Response) => {
    try {
        const userId = (req as any).user.uid;
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        const userData = userDoc.data();

        if (!userData?.isPremium) {
            return res.status(403).json({
                error: 'Premium subscription required to unlock full 7-day meal plans.'
            });
        }

        const { adjustmentReason } = req.body;

        const plan = await openAIService.generateMealPlan({
            goal: userData.profile.goal,
            targetCalories: userData.profile.targetCalories,
            targetProtein: userData.profile.targetProtein,
            targetCarbs: userData.profile.targetCarbs,
            targetFat: userData.profile.targetFat,
            dietType: userData.profile.dietType,
            activityLevel: userData.profile.activityLevel,
            adjustmentReason,
        });

        // Save to Firestore
        const planDoc = await admin.firestore()
            .collection('users').doc(userId)
            .collection('mealPlans').add({
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                plan,
            });

        res.json({ success: true, planId: planDoc.id, plan });
    } catch (error: any) {
        console.error('Error generating meal plan:', error);
        res.status(500).json({ error: error.message });
    }
});

// Swap a meal (Premium only)
mealPlanRoutes.post('/swap-meal', authenticate, async (req: Request, res: Response) => {
    try {
        const userId = (req as any).user.uid;
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        const userData = userDoc.data();

        if (!userData?.isPremium) {
            return res.status(403).json({
                error: 'Premium subscription required for meal swapping.'
            });
        }

        const { planId, day, mealType, currentMeal } = req.body;

        const newMeal = await openAIService.swapMeal(currentMeal, userData.profile.dietType);

        // Update the plan in Firestore
        const planRef = admin.firestore()
            .collection('users').doc(userId)
            .collection('mealPlans').doc(planId);

        const planDoc = await planRef.get();
        const planData = planDoc.data();

        if (planData) {
            planData.plan[day][mealType] = newMeal;
            planData.plan.meta.adjustment_explanation =
                `Swapped ${currentMeal.name} for ${newMeal.name} as requested.`;

            await planRef.update({ plan: planData.plan });
        }

        res.json({ success: true, newMeal });
    } catch (error: any) {
        console.error('Error swapping meal:', error);
        res.status(500).json({ error: error.message });
    }
});

// Get current meal plan
mealPlanRoutes.get('/current', authenticate, async (req: Request, res: Response) => {
    try {
        const userId = (req as any).user.uid;

        const plansSnapshot = await admin.firestore()
            .collection('users').doc(userId)
            .collection('mealPlans')
            .orderBy('createdAt', 'desc')
            .limit(1)
            .get();

        if (plansSnapshot.empty) {
            return res.json({ plan: null });
        }

        const planDoc = plansSnapshot.docs[0];
        res.json({ planId: planDoc.id, ...planDoc.data() });
    } catch (error: any) {
        console.error('Error fetching meal plan:', error);
        res.status(500).json({ error: error.message });
    }
});
