import 'package:flutter/material.dart';
import 'package:taskify/core/constants/app_colors.dart';
import 'package:taskify/presentation/screens/home/home_screen.dart';
import 'package:taskify/presentation/screens/tasks/task_screen.dart';
import 'package:taskify/presentation/screens/add_task/add_task_screen.dart';
import 'package:taskify/presentation/screens/profile/profile_screen.dart';
import 'package:taskify/presentation/widgets/custom_bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _addTaskKey = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const TaskScreen(),
      AddTaskScreen(key: ValueKey(_addTaskKey)),
      const ProfileScreen(),
    ];
  }

  void _onTabChanged(int index) {
    if (index == 2) {
      _addTaskKey++;
      setState(() {
        _screens[2] = AddTaskScreen(key: ValueKey(_addTaskKey));
        _currentIndex = index;
      });
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppColors.backgroundGradient,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}
