import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../../domain/entities/user_entity.dart';

class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({super.key});

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final _titleController = TextEditingController();
  final _durationController = TextEditingController(text: '90');
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> _selectedUserIds = [];

  // Yangi user qo'shish uchun controllerlar
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Yangi Imtihon'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('IMTIHON MA\'LUMOTLARI'),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Imtihon nomi'),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sana', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    subtitle: Text('${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}', 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.calendar_today, color: Colors.teal, size: 20),
                    onTap: _pickDate,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Vaqt', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    subtitle: Text(_selectedTime.format(context), 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.access_time, color: Colors.teal, size: 20),
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Davomiyligi (daqiqa)'),
            ),
            const SizedBox(height: 30),
            
            _buildSectionTitle('USERLARNI QO\'SHISH'),
            // Mavjud userlar ro'yxati (Multi-select)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: provider.users.isEmpty 
                ? const Center(child: Text('Hozircha userlar yo\'q', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: provider.users.length,
                    itemBuilder: (context, index) {
                      final user = provider.users[index];
                      bool isSelected = _selectedUserIds.contains(user.id);
                      return CheckboxListTile(
                        value: isSelected,
                        activeColor: Colors.teal,
                        checkColor: Colors.white,
                        title: Text('${user.firstName} ${user.lastName}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                        subtitle: Text('ID: ${user.loginId}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        onChanged: (val) {
                          setState(() {
                            if (val!) _selectedUserIds.add(user.id);
                            else _selectedUserIds.remove(user.id);
                          });
                        },
                      );
                    },
                  ),
            ),
            const SizedBox(height: 15),
            Center(
              child: TextButton.icon(
                onPressed: () => _showQuickAddUser(context),
                icon: const Icon(Icons.person_add_alt_1, color: Colors.teal),
                label: const Text('YANGI USER QO\'SHISH', style: TextStyle(color: Colors.teal)),
              ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _saveExam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('IMTIHONNI YARATISH', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickAddUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text('Yangi User', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _firstNameController, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Ism')),
            const SizedBox(height: 10),
            TextField(controller: _lastNameController, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Familiya')),
            const SizedBox(height: 10),
            TextField(controller: _phoneController, keyboardType: TextInputType.phone, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Telefon')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          ElevatedButton(
            onPressed: () {
              context.read<AdminProvider>().addUser(
                _firstNameController.text, 
                _lastNameController.text, 
                _phoneController.text
              );
              _firstNameController.clear();
              _lastNameController.clear();
              _phoneController.clear();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('QO\'SHISH'),
          )
        ],
      ),
    );
  }

  void _saveExam() {
    if (_titleController.text.isEmpty || _selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ma\'lumotlarni to\'ldiring!')));
      return;
    }
    final startTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
    context.read<AdminProvider>().createExam(
      title: _titleController.text,
      startTime: startTime,
      duration: int.parse(_durationController.text),
      selectedUserIds: _selectedUserIds,
    );
    Navigator.pop(context);
  }

  // Yordamchi metodlar
  void _pickDate() async {
    final date = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2030));
    if (date != null) setState(() => _selectedDate = date);
  }

  void _pickTime() async {
    final time = await showTimePicker(context: context, initialTime: _selectedTime);
    if (time != null) setState(() => _selectedTime = time);
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label, labelStyle: const TextStyle(color: Colors.teal, fontSize: 14),
    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
  );

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 15),
    child: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
  );
}
