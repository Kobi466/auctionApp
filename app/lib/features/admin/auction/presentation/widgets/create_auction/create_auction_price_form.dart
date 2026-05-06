import 'package:flutter/material.dart';

class CreateAuctionPriceForm extends StatelessWidget {
  final TextEditingController? minimumBidController;
  final TextEditingController? depositAmountController;
  final bool lockMinimumBid;

  const CreateAuctionPriceForm({
    super.key,
    this.minimumBidController,
    this.depositAmountController,
    this.lockMinimumBid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'THIẾT LẬP GIÁ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField(
                label: 'Giá khởi điểm (VNĐ)',
                prefixIcon: Icons.payments_outlined,
                hintText: '150000000',
                controller: minimumBidController,
                readOnly: lockMinimumBid,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: 'Bước giá',
                      prefixIcon: Icons.trending_up_rounded,
                      hintText: '5000000',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      label: 'Tiền đặt cọc',
                      prefixIcon: Icons.account_balance_wallet_outlined,
                      hintText: '15000000',
                      controller: depositAmountController,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData prefixIcon,
    required String hintText,
    TextEditingController? controller,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              prefixIcon: Icon(
                prefixIcon,
                color: const Color(0xFF2563EB),
                size: 20,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
