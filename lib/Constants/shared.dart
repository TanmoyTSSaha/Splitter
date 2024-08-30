import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';

class PrimaryTextFormField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String fieldName;
  final bool isObscure;
  final String? Function(String?)? validator;
  final Color labelColor;
  final TextStyle errorTextStyle;
  const PrimaryTextFormField({
    super.key,
    required this.textEditingController,
    required this.fieldName,
    required this.isObscure,
    required this.validator,
    this.labelColor = const Color(0xFF91919F),
    this.errorTextStyle = const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ),
  });

  @override
  State<PrimaryTextFormField> createState() => _PrimaryTextFormFieldState();
}

class _PrimaryTextFormFieldState extends State<PrimaryTextFormField> {
  bool isObscure = false;

  @override
  void initState() {
    super.initState();
    isObscure = widget.isObscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textEditingController,
      obscureText: isObscure,
      validator: widget.validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: neopopSecondaryGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(
            width: 1,
            color: neopopSecondaryGrey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(
            width: 1,
            color: neopopSecondaryGrey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(
            width: 1,
            color: neopopSecondaryGrey,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(
            width: 1,
            color: neopopSecondaryGrey,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(
            width: 1,
            color: neopopError,
          ),
        ),
        labelText: widget.fieldName,
        labelStyle: body2_text.copyWith(
          color: widget.labelColor,
        ),
        errorStyle: widget.errorTextStyle,
        suffixIcon: widget.isObscure
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isObscure = !isObscure;
                  });
                },
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: neopopOnBackground,
                  size: 24,
                ),
              )
            : const SizedBox(
                height: 0,
                width: 0,
              ),
      ),
    );
  }
}


class NeoPopCustomTextButton extends StatelessWidget {
  final String buttonName;
  final Color buttonTextColor;
  final Color buttonForegroundColor;
  final Function()? onPressed;
  const NeoPopCustomTextButton({
    required this.buttonName,
    required this.buttonTextColor,
    required this.buttonForegroundColor,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        foregroundColor: buttonForegroundColor,
      ),
      child: Text(
        buttonName,
        style: body2_text.copyWith(
          color: buttonTextColor,
        ),
      ),
    );
  }
}
