import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';

class ViewResultsScreen extends StatelessWidget {
  const ViewResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final usersWithResults = provider.users.where((u) => u.results.isNotEmpty).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Imtihon Natijalari'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: usersWithResults.isEmpty
          ? const Center(child: Text('Hozircha natijalar yo\'q', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: usersWithResults.length,
              itemBuilder: (context, index) {
                final user = usersWithResults[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '${user.firstName} ${user.lastName} (ID: ${user.loginId})',
                        style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...user.results.map((result) {
                      return Card(
                        color: const Color(0xFF1F1F1F),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          iconColor: Colors.teal,
                          collapsedIconColor: Colors.grey,
                          title: Text(result.examTitle, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'Sana: ${result.date.day}.${result.date.month}.${result.date.year} | Test: ${result.testScore.toStringAsFixed(1)}%',
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                          trailing: _buildScoreBadge(result.totalScore, result.isPublished),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow('Test Natijasi:', '${result.testScore.toStringAsFixed(1)}%'),
                                  const SizedBox(height: 10),
                                  const Text('O\'QUVCHI YOZGAN ESSE:', style: TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white10),
                                    ),
                                    child: Text(
                                      result.essayContent.isEmpty ? "Esse yozilmagan" : result.essayContent,
                                      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  if (!result.isPublished) ...[
                                    const Text('ESSE BAHOLASH (0-100):', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 10),
                                    _buildRatingBar(context, provider, user.id, result.examId),
                                  ] else ...[
                                    _buildInfoRow('Esse Balli:', '${result.essayScore?.toStringAsFixed(1) ?? "0.0"}'),
                                    const SizedBox(height: 5),
                                    _buildInfoRow('UMUMIY BALL:', '${result.totalScore.toStringAsFixed(1)}%', isTotal: true),
                                  ],
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                    const Divider(color: Colors.white10),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: isTotal ? 14 : 12, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: isTotal ? Colors.teal : Colors.white, fontSize: isTotal ? 16 : 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildScoreBadge(double score, bool isPublished) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPublished 
            ? (score >= 60 ? Colors.green.withAlpha(50) : Colors.red.withAlpha(50))
            : Colors.orange.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isPublished ? '${score.toStringAsFixed(1)}%' : 'KUTILMOQDA',
        style: TextStyle(
          color: isPublished ? (score >= 60 ? Colors.green : Colors.red) : Colors.orange,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRatingBar(BuildContext context, AdminProvider provider, String userId, String examId) {
    final controller = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Ball kiriting...',
              hintStyle: TextStyle(color: Colors.white24, fontSize: 12),
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            final score = double.tryParse(controller.text);
            if (score != null && score >= 0 && score <= 100) {
              provider.gradeAndPublishEssay(userId, examId, score);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('0 va 100 oralig\'ida ball kiriting!')));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          child: const Text('TASDIQLASH', style: TextStyle(fontSize: 12)),
        )
      ],
    );
  }
}
