import 'package:flutter/material.dart';

class CreateAuctionInfoBox extends StatelessWidget {
  const CreateAuctionInfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF2563EB),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF334155),
                  height: 1.5,
                ),
                children: [
                  TextSpan(text: 'Phiên đấu giá sẽ được chuyển sang trạng thái '),
                  TextSpan(
                    text: 'Sắp diễn ra',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                  ),
                  TextSpan(
                    text: ' sau khi tạo. Bạn có thể thay đổi thiết lập trước khi phiên chính thức bắt đầu.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
