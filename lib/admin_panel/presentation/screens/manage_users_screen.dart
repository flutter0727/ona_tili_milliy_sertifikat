import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Foydalanuvchilar'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: ListView.builder(
        itemCount: provider.users.length,
        itemBuilder: (context, index) {
          final user = provider.users[index];
          return Card(
            color: const Color(0xFF1F1F1F),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal,
                child: Text(user.firstName[0], style: const TextStyle(color: Colors.white)),
              ),
              title: Text('${user.firstName} ${user.lastName}', style: const TextStyle(color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.phoneNumber, style: const TextStyle(color: Colors.grey)),
                  Text('Login ID: ${user.loginId}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy, color: Colors.teal, size: 20),
                onPressed: () {
                  // ID nusxalash funksiyasi
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _showAddUserDialog(context),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text('Yangi foydalanuvchi', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _firstNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Ism', labelStyle: TextStyle(color: Colors.teal)),
              ),
              TextField(
                controller: _lastNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Familiya', labelStyle: TextStyle(color: Colors.teal)),
              ),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Telefon raqam', labelStyle: TextStyle(color: Colors.teal)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          ElevatedButton(
            onPressed: () {
              if (_firstNameController.text.isNotEmpty && _lastNameController.text.isNotEmpty) {
                context.read<AdminProvider>().addUser(
                  _firstNameController.text,
                  _lastNameController.text,
                  _phoneController.text,
                );
                _firstNameController.clear();
                _lastNameController.clear();
                _phoneController.clear();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('QO\'SHISH', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
