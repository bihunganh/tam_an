import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class InsightCard extends StatelessWidget {
  final List<String> insights;
  const InsightCard({Key? key, required this.insights}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 24),
              SizedBox(width: 10),
              Text('Góc nhìn Tâm An (AI)', style: TextStyle(color: Colors.amberAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          ...insights.map((text) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ", style: TextStyle(color: AppColors.primaryBlue, fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(child: Text(text.replaceAll('**', ''), style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
