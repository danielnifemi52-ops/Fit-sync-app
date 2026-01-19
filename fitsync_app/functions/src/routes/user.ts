import { Router, Request, Response } from 'express';
import * as admin from 'firebase-admin';

export const userRoutes = Router();

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

// Get user profile
userRoutes.get('/profile', authenticate, async (req: Request, res: Response) => {
    try {
        const userId = (req as any).user.uid;
        const userDoc = await admin.firestore().collection('users').doc(userId).get();

        if (!userDoc.exists) {
            return res.status(404).json({ error: 'User not found' });
        }

        res.json(userDoc.data());
    } catch (error: any) {
        console.error('Error fetching profile:', error);
        res.status(500).json({ error: error.message });
    }
});

// Update user profile
userRoutes.put('/profile', authenticate, async (req: Request, res: Response) => {
    try {
        const userId = (req as any).user.uid;
        const updates = req.body;

        await admin.firestore()
            .collection('users')
            .doc(userId)
            .set(updates, { merge: true });

        res.json({ success: true });
    } catch (error: any) {
        console.error('Error updating profile:', error);
        res.status(500).json({ error: error.message });
    }
});

// Upgrade to premium (for demo purposes)
userRoutes.post('/upgrade-premium', authenticate, async (req: Request, res: Response) => {
    try {
        const userId = (req as any).user.uid;

        await admin.firestore()
            .collection('users')
            .doc(userId)
            .update({ isPremium: true });

        res.json({ success: true, message: 'Upgraded to Premium!' });
    } catch (error: any) {
        console.error('Error upgrading to premium:', error);
        res.status(500).json({ error: error.message });
    }
});
