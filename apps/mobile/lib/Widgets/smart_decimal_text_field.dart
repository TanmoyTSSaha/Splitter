import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splitr/Constants/app_formats.dart';

/// Decimal numeric field with focus cursor before `.` and auto-advance after typing `.`.
class SmartDecimalTextField extends StatefulWidget {
  final TextEditingController controller;
  final int maxDecimalPlaces;
  final TextStyle? style;
  final InputDecoration? decoration;
  final TextInputType keyboardType;

  const SmartDecimalTextField({
    super.key,
    required this.controller,
    this.maxDecimalPlaces = DefaultDecimalPlaces.amount,
    this.style,
    this.decoration,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
  });

  @override
  State<SmartDecimalTextField> createState() => _SmartDecimalTextFieldState();
}

class _SmartDecimalTextFieldState extends State<SmartDecimalTextField> {
  late final FocusNode _focusNode;
  late String _textSnapshot;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _textSnapshot = widget.controller.text;
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_focusNode.hasFocus || !mounted) return;
      _moveCursorBeforeDecimal();
    });
  }

  void _moveCursorBeforeDecimal() {
    final text = widget.controller.text;
    final dotIndex = text.indexOf('.');
    final offset = dotIndex >= 0 ? dotIndex : text.length;
    widget.controller.selection = TextSelection.collapsed(offset: offset);
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final previous = _textSnapshot;
    _textSnapshot = text;

    if (text.length != previous.length + 1) return;

    final dotIndex = text.indexOf('.');
    final previousDot = previous.indexOf('.');
    if (dotIndex < 0 || previousDot >= 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.controller.selection =
          TextSelection.collapsed(offset: dotIndex + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      style: widget.style,
      decoration: widget.decoration,
      inputFormatters: [
        _DecimalInputFormatter(maxDecimalPlaces: widget.maxDecimalPlaces),
      ],
    );
  }
}

class _DecimalInputFormatter extends TextInputFormatter {
  final int maxDecimalPlaces;

  _DecimalInputFormatter({required this.maxDecimalPlaces});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    if (!RegExp(InputPatterns.decimalInput).hasMatch(text)) {
      return oldValue;
    }

    final dotIndex = text.indexOf('.');
    if (dotIndex >= 0 && text.length - dotIndex - 1 > maxDecimalPlaces) {
      return oldValue;
    }

    return newValue;
  }
}
