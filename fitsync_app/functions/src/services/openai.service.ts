import OpenAI from 'openai';
import * as functions from 'firebase-functions';

const openai = new OpenAI({
    apiKey: functions.config().openai.key,
});

export interface MealPlanRequest {
    goal: string;
    targetCalories: number;
    targetProtein: number;
    targetCarbs: number;
    targetFat: number;
    dietType: string;
    activityLevel: string;
    adjustmentReason?: string;
}

export interface WorkoutPlanRequest {
    goal: string;
    experienceLevel: string;
    equipment: string;
    weeklyAvailability: number;
    adjustmentReason?: string;
}

export interface AICoachRequest {
    userData: any;
    weightTrend: any;
    calorieAdherence: any;
    workoutAdherence: any;
    todayCalories: number;
    todayMacros: any;
}

export class OpenAIService {
    async generateMealPlan(request: MealPlanRequest): Promise<any> {
        const systemPrompt = `You are an expert nutritionist specializing in personalized meal planning. Generate scientifically-backed, practical meal plans that align with user goals.`;

        const userPrompt = `Generate a highly personalized 7-day meal plan as JSON.
- Goal: ${request.goal}
- Daily calories: ${request.targetCalories} kcal
- Macros: Protein ${request.targetProtein}g, Carbs ${request.targetCarbs}g, Fat ${request.targetFat}g
- Diet Preference: ${request.dietType}
- Activity Level: ${request.activityLevel}

Format the response as a valid JSON object with days of the week as keys (monday, tuesday, etc.). 
Include a "meta" key with:
- adjustment_explanation (String - A brief, supportive explanation of what changed in the plan to help the user recover their targets, or a general welcome if it's a new plan).

Each day should contain "breakfast", "lunch", and "dinner" objects with:
- name (String)
- calories (int)
- protein (int)
- carbs (int)
- fat (int)
- ingredients (Array of Strings)
- portion_guidance (String - scientific or practical advice on serving size)
- substitutions (Array of Strings - simple alternatives for common ingredients)

${request.adjustmentReason ? `IMPORTANT: The user has missed their recent targets because: ${request.adjustmentReason}. Adjust this new plan to be easier to follow or to compensate for these misses without being too restrictive.` : ''}

Strictly return ONLY the JSON object.`;

        const response = await openai.chat.completions.create({
            model: 'gpt-4',
            messages: [
                { role: 'system', content: systemPrompt },
                { role: 'user', content: userPrompt },
            ],
            response_format: { type: 'json_object' },
            temperature: 0.7,
        });

        return JSON.parse(response.choices[0].message.content || '{}');
    }

    async swapMeal(currentMeal: any, dietType: string): Promise<any> {
        const systemPrompt = `You are a nutrition expert. Generate alternative meals that match exact macro targets.`;

        const userPrompt = `The user wants to swap a meal in their meal plan.
Current Meal: ${currentMeal.name}
Target Macros: ${currentMeal.calories} kcal, ${currentMeal.protein}g protein, ${currentMeal.carbs}g carbs, ${currentMeal.fat}g fat.
Diet Preference: ${dietType}

Generate ONE alternative meal that matches these macros as closely as possible (+/- 5%).
Return valid JSON with keys:
- name (String)
- calories (int)
- protein (int)
- carbs (int)
- fat (int)
- ingredients (Array of Strings)
- portion_guidance (String)
- substitutions (Array of Strings)

Strictly return ONLY the JSON object.`;

        const response = await openai.chat.completions.create({
            model: 'gpt-4',
            messages: [
                { role: 'system', content: systemPrompt },
                { role: 'user', content: userPrompt },
            ],
            response_format: { type: 'json_object' },
            temperature: 0.8,
        });

        return JSON.parse(response.choices[0].message.content || '{}');
    }

    async generateWorkoutPlan(request: WorkoutPlanRequest): Promise<any> {
        const systemPrompt = `You are a certified fitness trainer specializing in evidence-based programming.`;

        const userPrompt = `Generate a personalized workout plan as JSON for the following profile:
- Goal: ${request.goal}
- Experience Level: ${request.experienceLevel}
- Equipment: ${request.equipment}
- Weekly Availability: ${request.weeklyAvailability} days

Structure the JSON with days of the week as keys. Days can be workouts or "REST".
Include a "meta" key with:
- weekly_split (String - e.g., "Upper/Lower Split")
- progression_guidance (String - Scientific advice on how to improve over time)
- adaptation_note (String - Brief note on why this plan was adjusted, if applicable)

Each workout day object should have:
- name (String - Workout name)
- exercises (Array of objects):
  - name (String)
  - sets (int)
  - reps (String)
  - rest (int - seconds)
  - notes (String - form tips)

${request.adjustmentReason ? `IMPORTANT: The user has recent adherence issues: ${request.adjustmentReason}. Adjust the plan to be more accessible or recover performance.` : ''}

Strictly return ONLY the JSON object.`;

        const response = await openai.chat.completions.create({
            model: 'gpt-4',
            messages: [
                { role: 'system', content: systemPrompt },
                { role: 'user', content: userPrompt },
            ],
            response_format: { type: 'json_object' },
            temperature: 0.7,
        });

        return JSON.parse(response.choices[0].message.content || '{}');
    }

    async swapExercise(currentExercise: any, equipment: string, goal: string): Promise<any> {
        const systemPrompt = `You are a fitness expert. Generate alternative exercises that target the same muscle groups.`;

        const userPrompt = `The user wants to swap an exercise in their workout plan.
Current Exercise: ${currentExercise.name}
Volume: ${currentExercise.sets} sets x ${currentExercise.reps} reps
User Equipment: ${equipment}
Goal: ${goal}

Generate ONE alternative exercise that works the same muscle group and fits their equipment.
Return valid JSON with keys:
- name (String)
- sets (int)
- reps (String)
- rest (int)
- notes (String tip)

Strictly return ONLY the JSON object.`;

        const response = await openai.chat.completions.create({
            model: 'gpt-4',
            messages: [
                { role: 'system', content: systemPrompt },
                { role: 'user', content: userPrompt },
            ],
            response_format: { type: 'json_object' },
            temperature: 0.8,
        });

        return JSON.parse(response.choices[0].message.content || '{}');
    }

    async generateAICoachInsight(request: AICoachRequest, isPremium: boolean): Promise<string> {
        if (!isPremium) {
            return `Stay consistent with your ${request.calorieAdherence.adherencePercent > 80 ? 'excellent logging' : 'daily logs'} to see results. Upgrade to Premium for deep analysis.`;
        }

        const systemPrompt = `You are an AI fitness coach providing scientific, evidence-based insights on progress.`;

        const userPrompt = `Analyze this user's progress:
- Goal: ${request.userData.goal}
- Weight Trend (7 days): ${request.weightTrend.trend} (${request.weightTrend.change}kg)
- Calorie Adherence: ${request.calorieAdherence.adherencePercent}%
- Workout Adherence: ${request.workoutAdherence.adherencePercent}%
- Today's Progress: ${request.todayCalories} kcal, ${request.todayMacros.protein}g protein

Provide a structured insight with:
### 🧠 Reasoning
[Explain their current phase and adherence]

### 💡 Daily Insight
[Correlate nutrition and training - explain synergy, mitigation, or areas to improve]

### 🎯 Actionable Tip
[One specific, scientific tip for today]

Keep it concise but scientifically sound.`;

        const response = await openai.chat.completions.create({
            model: 'gpt-4',
            messages: [
                { role: 'system', content: systemPrompt },
                { role: 'user', content: userPrompt },
            ],
            temperature: 0.7,
            max_tokens: 500,
        });

        return response.choices[0].message.content || '';
    }

    async generatePlateauAnalysis(userData: any, weightLogs: any[], dailyLogs: any[], workoutLogs: any[]): Promise<string> {
        const systemPrompt = `You are an expert metabolic scientist analyzing weight loss plateaus.`;

        const userPrompt = `Analyze this plateau for ${userData.goal}:
- 14-day weight change: ${weightLogs[weightLogs.length - 1]?.weight - weightLogs[0]?.weight}kg
- Nutrition adherence (avg last 7 days): [calculate from dailyLogs]
- Workout adherence (last 7 days): ${workoutLogs.length} workouts

Provide:
### 🔍 Plateau Diagnosis
[Explain the likely cause: metabolic adaptation, water retention, inconsistent logging, etc.]

### 🚀 Next Steps
1. [Specific action]
2. [Specific action]
3. [Specific action]

Be scientific but encouraging.`;

        const response = await openai.chat.completions.create({
            model: 'gpt-4',
            messages: [
                { role: 'system', content: systemPrompt },
                { role: 'user', content: userPrompt },
            ],
            temperature: 0.7,
            max_tokens: 600,
        });

        return response.choices[0].message.content || '';
    }
}

export const openAIService = new OpenAIService();
