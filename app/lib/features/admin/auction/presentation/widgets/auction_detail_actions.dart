import 'package:flutter/material.dart';

class AuctionDetailActions extends StatelessWidget {
  final bool canCancel;
  final bool isCancelling;
  final VoidCallback? onCancel;

  const AuctionDetailActions({
    super.key,
    required this.canCancel,
    required this.isCancelling,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canCancel && !isCancelling ? onCancel : null,
            icon: Icon(
              canCancel ? Icons.cancel_outlined : Icons.lock_outline,
              size: 18,
            ),
            label: Text(isCancelling ? 'Dang huy...' : _label),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE2E8F0),
              disabledForegroundColor: const Color(0xFF94A3B8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  String get _label => canCancel ? 'Huy phien' : 'Khong the huy phien';
}
