import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController textController = TextEditingController();

  void createNewHabit() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                decoration: const InputDecoration(
                  hintText: 'Enter habit name',
                ),
                controller: textController,
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    String newHabitName = textController.text;

                    context.read<HabitDatabase>().addHabit(newHabitName);

                    Navigator.pop(context);

                    textController.clear();
                  },
                  child: const Text('Save'),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);

                    textController.clear();
                  },
                  child: const Text('Cancel'),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: MyDrawer(),
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
