import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class WinnerDetailAddressCard extends StatelessWidget {
  const WinnerDetailAddressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'ĐỊA CHỈ GIAO HÀNG',
                style: TextStyle(
                  color: const Color(0xFF1E293B).withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.only(left: 28),
            child: Text(
              'Số 123, Đường Láng, Quận Đống Đa, TP. Hà Nội',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
