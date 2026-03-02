import 'package:flutter/material.dart';

class ShareButton extends StatelessWidget {
  final VoidCallback onShare;

  const ShareButton({super.key, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onShare,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(Icons.share_outlined, size: 20, color: Color(0xFF1A1A2E)),
      ),
    );
  }
}