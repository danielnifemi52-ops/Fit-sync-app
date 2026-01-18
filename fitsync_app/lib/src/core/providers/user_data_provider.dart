import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_data.dart';
import '../services/storage_service.dart';
import '../../features/nutrition/providers/nutrition_provider.dart'; // for storageServiceProvider

final userDataProvider = NotifierProvider<UserDataNotifier, UserData>(
  UserDataNotifier.new,
);

class UserDataNotifier extends Notifier<UserData> {
  late final StorageService _storage;

  @override
  UserData build() {
    _storage = ref.read(storageServiceProvider);
    _loadData();
    return UserData(); // Default initial state
  }

  Future<void> _loadData() async {
    final data = await _storage.loadUserData();
    if (data != null) {
      state = UserData.fromJson(data);
    }
  }

  Future<void> updateUserData(UserData newData) async {
    state = newData;
    await _storage.saveUserData(newData.toJson());
  }

  Future<void> updateWeight(double weight) async {
    // For MVP, weight logging just updates a "current weight" field in daily log or user data?
    // PRD says "Stores in dailyLog".
    // So this might belong in NutritionProvider or a separate DailyLogProvider.
    // But "Shows current weight on dashboard" implies it might be UserData too.
    // Let's assume we update the Daily Log elsewhere, but maybe we track "current weight" in UserData for fast access?
    // The PRD implementation snippet says: save userData, save dailyLog.
    // "Log Weight button... Store in dailyLog... Shows current weight on dashboard".

    // I will implement weight logging in the DailyLog (NutritionProvider/MealsNotifier extended?) or separate.
    // Let's keep UserData focused on Targets/Goals.
  }
}
