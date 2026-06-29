import 'package:baltra/features/applicationCare/models/completedModel.dart';
import 'package:flutter/material.dart';

class CompletedComplaintCard extends StatelessWidget {
  final CompletedComplaint complaint;

  const CompletedComplaintCard({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffD7D7D7)),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              complaint.damagedImageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported_outlined,
                    color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Model Name:', value: complaint.modelName),
                const SizedBox(height: 4),
                _InfoRow(label: 'Model No:', value: complaint.modelNum),
                const SizedBox(height: 4),
                _InfoRow(
                  label: 'Job ID:',
                  value: complaint.jobNo,
                  valueColor: primaryColor,
                  valueFontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                _InfoRow(label: 'Sent for:', value: complaint.problemType),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      'Stage:  ',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xffE6F9F0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xff34C77B)),
                      ),
                      child: const Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff1A9E5A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _InfoRow(
                  label: 'Date:',
                  value: _formatDate(complaint.jobClosingDate),
                  valueFontWeight: FontWeight.w700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${weekdays[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

// ── Private helper widget (used only within this file) ──────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final FontWeight? valueFontWeight;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueFontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? Colors.black,
              fontWeight: valueFontWeight ?? FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
