import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

/* 
  S E T U P   I S A R

*/

  // INITIALIZING - DATABASE
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([
      HabitSchema,
      AppSettingsSchema,
    ], directory: dir.path);
  }

  // save first date of app startup (for heatmap)
  static Future<void> saveFirstLaunchDate() async {
    final existingSettings = isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // get first date of app startup (for heatmap)
  static Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

/*
 CRUD OPERATIONS
*/

  // List of habits
  final List<Habit> currentHabits = [];

  // CREATE
  Future<void> addHabit(String habitName) async {
    final newHabit = Habit()..name = habitName;

    await isar.writeTxn(() => isar.habits.put(newHabit));

    readHabits();
  }

  // READ
  Future<void> readHabits() async {
    List<Habit> habits = await isar.habits.where().findAll();

    currentHabits.clear();
    currentHabits.addAll(habits);
  }

  // UPDATE
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    final habit = await isar.habits.get(id);

    if (habit != null) {
      await isar.writeTxn(() async {
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          final today = DateTime.now();

          habit.completedDays.add(
            DateTime(today.year, today.month, today.day),
          );
        } else {
          habit.completedDays.removeWhere((date) =>
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day);
        }
        // save the updated habit
        await isar.habits.put(habit);
      });
    }
    readHabits();
  }

  // UPDATE- edit habit name
  Future<void> updateHabitName(int id, String newName) async {
    final habit = await isar.habits.get(id);

    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;
        isar.habits.put(habit);
      });
    }

    readHabits();
  }

  // DELETE
  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });
    readHabits();
  }
}
