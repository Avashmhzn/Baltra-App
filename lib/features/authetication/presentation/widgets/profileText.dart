/*
import 'package:flutter/material.dart';

class ProfileTextField extends StatelessWidget {
  ProfileTextField({
    required this.initialValue,
    required this.title,
    this.readonly,

    super.key,
  });
  final String title;
  final String initialValue;
  bool? readonly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 15,
              color: Color(0xff4F4F4F),
              fontWeight: FontWeight.w500),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15, top: 10),
          height: 40,
          child: TextFormField(
            readOnly: readonly ?? false,
            cursorHeight: 20,
            cursorColor: Theme.of(context).primaryColor,
            initialValue: initialValue,
            decoration: InputDecoration(
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffd7d7d7)),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              contentPadding: const EdgeInsets.only(bottom: 8, left: 10),
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        )
      ],
    );
  }
}
*/

import 'package:flutter/material.dart';

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.title,
    this.readonly = false,
    this.controller,
    this.validator,
    this.onSaved,
    this.initialValue = '',
  });

  final String initialValue;
  final String title;
  final TextEditingController? controller;
  final bool readonly;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 15,
              color: Color(0xff4F4F4F),
              fontWeight: FontWeight.w500),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15, top: 10),
          height: 40,
          child: TextFormField(
            readOnly: readonly,
            controller: controller ?? TextEditingController(text: initialValue),
            cursorHeight: 20,
            cursorColor: Theme.of(context).primaryColor,
            decoration: InputDecoration(
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              contentPadding: const EdgeInsets.only(bottom: 8, left: 10),
            ),
            validator: validator,
            onSaved: onSaved,
          ),
        ),
        const SizedBox(
          height: 15,
        )
      ],
    );
  }
}

