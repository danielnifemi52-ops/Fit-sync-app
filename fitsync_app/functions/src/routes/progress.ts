import { Router, Request, Response } from 'express';
import * as admin from 'firebase-admin';

export const progressRoutes = Router();

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

// Log weight
progressRoutes.post('/log-weight', authenticate, async (req: Request, res: Response) => {
    try {
        const userId = (req as any).user.uid;
        const { weight, date } = req.body;

        await admin.firestore()
            .collection('users').doc(userId)
            .collection('weightLogs').add({
                weight,
                date: admin.firestore.Timestamp.fromDate(new Date(date)),
            });

        res.json({ success: true });
    } catch (error: any) {
        console.error('Error logging weight:', error);
        res.status(500).json({ error: error.message });
    }
});

// Log calories
progressRoutes.post('/log-calories', authenticate, async (req: Request, res: Response) => {
    try {
        const userId = (req as any).user.uid;
        const { totalCalories, protein, carbs, fat, meals, date } = req.body;

        await admin.firestore()
            .collection('users').doc(userId)
            .collection('calorieLogs').add({
                totalCalories,
                protein,
                carbs,
                fat,
                meals,
                date: admin.firestore.Timestamp.fromDate(new Date(date)),
            });

        res.json({ success: true });
    } catch (error: any) {
        console.error('Error logging calories:', error);
        res.status(500).json({ error: error.message });
    }
});

// Log workout completion
progressRoutes.post('/log-workout', authenticate, async (req: Request, res: Response) => {
    try {
        const userId = (req as any).user.uid;
        const { day, workoutName, date } = req.body;

        await admin.firestore()
            .collection('users').doc(userId)
            .collection('workoutLogs').add({
                day,
                workoutName,
                completed: true,
                date: admin.firestore.Timestamp.fromDate(new Date(date)),
            });

        res.json({ success: true });
    } catch (error: any) {
        console.error('Error logging workout:', error);
        res.status(500).json({ error: error.message });
    }
});

// Get analytics data
progressRoutes.get('/analytics', authenticate, async (req: Request, res: Response) => {
    try {
        const userId = (req as any).user.uid;

        // Fetch last 30 days of data
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        const [weightLogs, calorieLogs, workoutLogs] = await Promise.all([
            admin.firestore()
                .collection('users').doc(userId)
                .collection('weightLogs')
                .where('date', '>=', admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
                .orderBy('date', 'asc')
                .get(),
            admin.firestore()
                .collection('users').doc(userId)
                .collection('calorieLogs')
                .where('date', '>=', admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
                .orderBy('date', 'asc')
                .get(),
            admin.firestore()
                .collection('users').doc(userId)
                .collection('workoutLogs')
                .where('date', '>=', admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
                .orderBy('date', 'asc')
                .get(),
        ]);

        res.json({
            weightLogs: weightLogs.docs.map(doc => ({ id: doc.id, ...doc.data() })),
            calorieLogs: calorieLogs.docs.map(doc => ({ id: doc.id, ...doc.data() })),
            workoutLogs: workoutLogs.docs.map(doc => ({ id: doc.id, ...doc.data() })),
        });
    } catch (error: any) {
        console.error('Error fetching analytics:', error);
        res.status(500).json({ error: error.message });
    }
});
