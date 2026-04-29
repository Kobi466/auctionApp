import 'package:flutter/material.dart';

class CreateAuctionTimeForm extends StatefulWidget {
  const CreateAuctionTimeForm({super.key});

  @override
  State<CreateAuctionTimeForm> createState() => _CreateAuctionTimeFormState();
}

class _CreateAuctionTimeFormState extends State<CreateAuctionTimeForm> {
  // Khởi tạo thời gian mặc định
  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));
  DateTime _endTime = DateTime.now().add(const Duration(days: 1));

  // Hàm chọn ngày và giờ
  Future<void> _selectDateTime(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startTime : _endTime,
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStartDate ? _startTime : _endTime),
      );

      if (pickedTime != null) {
        setState(() {
          final newDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStartDate) {
            _startTime = newDateTime;
          } else {
            _endTime = newDateTime;
          }
        });
      }
    }
  }

  // Hàm format hiển thị: MM/DD/YYYY, HH:MM AM/PM
  String _formatDateTime(DateTime dt) {
    final String month = dt.month.toString().padLeft(2, '0');
    final String day = dt.day.toString().padLeft(2, '0');
    final String year = dt.year.toString();
    final String hour = (dt.hour % 12 == 0 ? 12 : dt.hour % 12).toString().padLeft(2, '0');
    final String minute = dt.minute.toString().padLeft(2, '0');
    final String amPm = dt.hour >= 12 ? 'PM' : 'AM';

    return '$month/$day/$year, $hour:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'THỜI GIAN',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildTimeTile(
                icon: Icons.calendar_today_outlined,
                iconColor: const Color(0xFF2563EB),
                label: 'THỜI GIAN BẮT ĐẦU',
                value: _formatDateTime(_startTime),
                onTap: () => _selectDateTime(context, true),
              ),
              const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFE2E8F0)),
              _buildTimeTile(
                icon: Icons.history_rounded,
                iconColor: const Color(0xFFDB2777),
                label: 'THỜI GIAN KẾT THÚC',
                value: _formatDateTime(_endTime),
                onTap: () => _selectDateTime(context, false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_month_outlined, size: 20, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }
}