import 'package:flutter/material.dart';

/// Widget hiển thị một câu hỏi FAQ có thể mở rộng/gấp
class FAQItem extends StatefulWidget {
  final String question; // Câu hỏi
  final String answer; // Câu trả lời

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        // ExpansionTile: tile có thể mở rộng/gấp lại
        title: Text(
          widget.question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.answer,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
