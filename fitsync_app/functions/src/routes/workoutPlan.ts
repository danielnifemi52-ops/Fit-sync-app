import { Router, Request, Response } from 'express';
import * as admin from 'firebase-admin';
import { openAIService } from '../services/openai.service';

export const workoutPlanRoutes = Router();

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

// Generate workout plan (Premium only)
workoutPlanRoutes.post('/generate', authenticate, async (req: Request, res: Response) => {
    try {
        const userId = (req as any).user.uid;
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        const userData = userDoc.data();

        if (!userData?.isPremium) {
            return res.status(403).json({
                error: 'Premium subscription required to unlock full personalized workout programs.'
            });
        }

        const { adjustmentReason } = req.body;

        const plan = await openAIService.generateWorkoutPlan({
            goal: userData.profile.goal,
            experienceLevel: userData.profile.experienceLevel || 'intermediate',
            equipment: userData.profile.equipment || 'gym',
            weeklyAvailability: userData.profile.weeklyAvailability || 4,
            adjustmentReason,
        });

        // Save to Firestore
        const planDoc = await admin.firestore()
            .collection('users').doc(userId)
            .collection('workoutPlans').add({
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                plan,
            });

        res.json({ success: true, planId: planDoc.id, plan });
    } catch (error: any) {
        console.error('Error generating workout plan:', error);
        res.status(500).json({ error: error.message });
    }
});

// Swap an exercise (Premium only)
workoutPlanRoutes.post('/swap-exercise', authenticate, async (req: Request, res: Response) => {
    try {
        const userId = (req as any).user.uid;
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        const userData = userDoc.data();

        if (!userData?.isPremium) {
            return res.status(403).json({
                error: 'Premium subscription required for exercise swapping.'
            });
        }

        const { planId, day, currentExercise } = req.body;

        const newExercise = await openAIService.swapExercise(
            currentExercise,
            userData.profile.equipment || 'gym',
            userData.profile.goal
        );

        // Update the plan in Firestore
        const planRef = admin.firestore()
            .collection('users').doc(userId)
            .collection('workoutPlans').doc(planId);

        const planDoc = await planRef.get();
        const planData = planDoc.data();

        if (planData && planData.plan[day]) {
            const exercises = planData.plan[day].exercises;
            const index = exercises.findIndex((e: any) => e.name === currentExercise.name);

            if (index !== -1) {
                exercises[index] = newExercise;
                planData.plan.meta.adaptation_note =
                    `Swapped ${currentExercise.name} for ${newExercise.name} as requested.`;

                await planRef.update({ plan: planData.plan });
            }
        }

        res.json({ success: true, newExercise });
    } catch (error: any) {
        console.error('Error swapping exercise:', error);
        res.status(500).json({ error: error.message });
    }
});

// Get current workout plan
workoutPlanRoutes.get('/current', authenticate, async (req: Request, res: Response) => {
    try {
        const userId = (req as any).user.uid;

        const plansSnapshot = await admin.firestore()
            .collection('users').doc(userId)
            .collection('workoutPlans')
            .orderBy('createdAt', 'desc')
            .limit(1)
            .get();

        if (plansSnapshot.empty) {
            return res.json({ plan: null });
        }

        const planDoc = plansSnapshot.docs[0];
        res.json({ planId: planDoc.id, ...planDoc.data() });
    } catch (error: any) {
        console.error('Error fetching workout plan:', error);
        res.status(500).json({ error: error.message });
    }
});
