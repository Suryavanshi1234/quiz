import 'package:flutter/material.dart';

class ErrorMessageDialog extends StatelessWidget {
  final String? errorMessage;

  const ErrorMessageDialog({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shadowColor: Colors.transparent,
      content: Text(
        errorMessage!,
        style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
      ),
    );
  }
}
