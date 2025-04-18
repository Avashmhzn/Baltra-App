import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class NormalTextField extends StatelessWidget {
  NormalTextField({
    super.key,
    this.controller,
    required this.type,
    this.readonly,
    this.initial,
    required this.hint,
    required this.title,
    this.inputFormatters,
    this.validator, // Added validator parameter
    this.onTap, // Added onTap parameter
    this.onChanged, // Added onChanged parameter
  });

  final String title;
  final String hint;
  final TextInputType type;
  TextEditingController? controller;
  bool? readonly;
  String? initial;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator; // Validator function
  final VoidCallback? onTap; // onTap callback
  final ValueChanged<String>? onChanged; // onChanged callback

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 5),
            child: Text(title),
          ),
          TextFormField(
            initialValue: initial,
            readOnly: readonly ?? false,
            controller: controller,
            keyboardType: type,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: hint,
              hintStyle:
              const TextStyle(fontSize: 12, color: Color(0xff828282)),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Theme.of(context).primaryColor)),
            ),
            validator: validator ?? (value) {
              if (value == null || value.isEmpty) {
                return '$title is required';
              }
              return null;
            }, // Use provided validator or default
            onTap: onTap, // Pass onTap to TextFormField
            onChanged: onChanged, // Pass onChanged to TextFormField
          ),
        ],
      ),
    );
  }
}

class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.title,
    required this.hint,
    required this.controller,
  });

  final String title;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 5),
            child: Text(title),
          ),
          TextFormField(
            readOnly: true,
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: hint,
              hintStyle:
              const TextStyle(fontSize: 12, color: Color(0xff828282)),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Theme.of(context).primaryColor)),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );

              if (pickedDate != null) {
                String formattedDate =
                DateFormat('yyyy-MM-dd').format(pickedDate);
                controller.text = formattedDate;
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$title is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}