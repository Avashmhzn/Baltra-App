import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ignore: must_be_immutable
class ObsecureTextField extends StatefulWidget {
  ObsecureTextField(
      {super.key,
      this.controller,
      required this.type,
      this.validator,
      required this.title});
  final String title;
  final TextInputType type;
  TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  State<ObsecureTextField> createState() => _ObsecureTextFieldState();
}

class _ObsecureTextFieldState extends State<ObsecureTextField> {

  bool _isObscured = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 5),
            child: Text(widget.title),
          ),
          TextFormField(
            validator: widget.validator,
            controller: widget.controller,
            keyboardType: widget.type,
            obscureText: _isObscured,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                  icon: SvgPicture.asset(_isObscured ?'assets/icons/eye_show.svg': 'assets/icons/eye_hidden.svg' ), 
                  onPressed: () {
                    setState(() {
                    _isObscured =! _isObscured;
                    });
                  }),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).primaryColor)),
            ),
          ),
        ],
      ),
    );
  }
}
