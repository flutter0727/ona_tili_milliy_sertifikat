import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'manage_questions_screen.dart';
import 'exam_settings_screen.dart';
import 'manage_users_screen.dart';
import 'view_results_screen.dart';
import 'live_monitoring_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String selectedSection = 'Users';
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _showExitDialog() {
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text('Tizimdan chiqish', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ilovani yopish uchun parolni kiriting:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Parol',
                hintStyle: TextStyle(color: Colors.white24),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BEKOR QILISH'),
          ),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text == 'password') {
                exit(0); // Ilovani butunlay yopish
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xato parol!'), backgroundColor: Colors.red),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('CHIQISH', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        // Ctrl + Shift + W kombinatsiyasini tekshirish
        final bool isControlPressed = HardwareKeyboard.instance.isControlPressed;
        final bool isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
        
        if (isControlPressed && isShiftPressed && event.logicalKey == LogicalKeyboardKey.keyW) {
          if (event is KeyDownEvent) {
            _showExitDialog();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Row(
          children: [
            // Chap tomondagi Sidebar
            Container(
              width: 250,
              color: const Color(0xFF1F1F1F),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'ADMIN PANEL',
                      style: TextStyle(color: Colors.teal, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(color: Colors.white10),
                  _buildSidebarItem('Users', Icons.people),
                  _buildSidebarItem('Exams', Icons.assignment),
                  _buildSidebarItem('Monitoring', Icons.monitor_heart, isLive: true),
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 20, bottom: 10),
                    child: Text('SAVOLLAR', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                  _buildSidebarItem('Fonetika', Icons.graphic_eq),
                  _buildSidebarItem('Morfologiya', Icons.account_tree),
                  _buildSidebarItem('Sintaksis', Icons.mediation),
                  _buildSidebarItem('Leksikologiya', Icons.translate),
                  _buildSidebarItem('Adabiyot', Icons.menu_book),
                  _buildSidebarItem('Imlo qoidalari', Icons.spellcheck),
                  const Spacer(),
                  _buildSidebarItem('Natijalar', Icons.bar_chart),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // O'ng tomondagi Asosiy Oyna (Content)
            Expanded(
              child: Container(
                color: const Color(0xFF121212),
                child: _buildMainContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(String title, IconData icon, {bool isLive = false}) {
    bool isSelected = selectedSection == title;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.teal : (isLive ? Colors.green : Colors.grey), size: 20),
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          if (isLive) ...[
            const SizedBox(width: 8),
            const CircleAvatar(radius: 4, backgroundColor: Colors.green),
          ]
        ],
      ),
      selected: isSelected,
      onTap: () => setState(() => selectedSection = title),
    );
  }

  Widget _buildMainContent() {
    switch (selectedSection) {
      case 'Users':
        return const ManageUsersScreen();
      case 'Exams':
        return const ExamSettingsScreen();
      case 'Monitoring':
        return const LiveMonitoringScreen();
      case 'Fonetika':
      case 'Morfologiya':
      case 'Sintaksis':
      case 'Leksikologiya':
      case 'Adabiyot':
      case 'Imlo qoidalari':
        return ManageQuestionsScreen(category: selectedSection);
      case 'Natijalar':
        return const ViewResultsScreen();
      default:
        return const ManageUsersScreen();
    }
  }
}
