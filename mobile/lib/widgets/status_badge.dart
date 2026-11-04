import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;

    switch (status.toLowerCase()) {
      case 'verified':
        bg = const Color(0xFFDCFCE7);
        text = AppColors.success;
        label = 'Terverifikasi';
        break;
      case 'rejected':
        bg = const Color(0xFFFEE2E2);
        text = AppColors.error;
        label = 'Ditolak';
        break;
      case 'completed':
        bg = const Color(0xFFE0E7FF);
        text = const Color(0xFF4338CA);
        label = 'Selesai';
        break;
      case 'pending':
      default:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
        label = 'Menunggu';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

