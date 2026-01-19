import { Router, Request, Response } from 'express';
import * as admin from 'firebase-admin';
import { openAIService } from '../services/openai.service';

export const aiCoachRoutes = Router();

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

// Generate AI Coach insight
aiCoachRoutes.post('/insight', authenticate, async (req: Request, res: Response) => {
    try {
        const userId = (req as any).user.uid;
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        const userData = userDoc.data();

        const { weightTrend, calorieAdherence, workoutAdherence, todayCalories, todayMacros } = req.body;

        const insight = await openAIService.generateAICoachInsight(
            {
                userData: userData?.profile,
                weightTrend,
                calorieAdherence,
                workoutAdherence,
                todayCalories,
                todayMacros,
            },
            userData?.isPremium || false
        );

        res.json({ insight });
    } catch (error: any) {
        console.error('Error generating AI insight:', error);
        res.status(500).json({ error: error.message });
    }
});

// Plateau analysis (Premium only)
aiCoachRoutes.post('/plateau-analysis', authenticate, async (req: Request, res: Response) => {
    try {
        const userId = (req as any).user.uid;
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        const userData = userDoc.data();

        if (!userData?.isPremium) {
            return res.status(403).json({
                error: 'Plateau diagnostics are available for Premium members only.'
            });
        }

        // Fetch user logs
        const weightLogsSnapshot = await admin.firestore()
            .collection('users').doc(userId)
            .collection('weightLogs')
            .orderBy('date', 'desc')
            .limit(14)
            .get();

        const calorieLogsSnapshot = await admin.firestore()
            .collection('users').doc(userId)
            .collection('calorieLogs')
            .orderBy('date', 'desc')
            .limit(7)
            .get();

        const workoutLogsSnapshot = await admin.firestore()
            .collection('users').doc(userId)
            .collection('workoutLogs')
            .orderBy('date', 'desc')
            .limit(7)
            .get();

        const weightLogs = weightLogsSnapshot.docs.map(doc => doc.data());
        const dailyLogs = calorieLogsSnapshot.docs.map(doc => doc.data());
        const workoutLogs = workoutLogsSnapshot.docs.map(doc => doc.data());

        const analysis = await openAIService.generatePlateauAnalysis(
            userData.profile,
            weightLogs,
            dailyLogs,
            workoutLogs
        );

        res.json({ analysis });
    } catch (error: any) {
        console.error('Error generating plateau analysis:', error);
        res.status(500).json({ error: error.message });
    }
});
