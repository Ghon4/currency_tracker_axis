import 'package:flutter/material.dart';

/// Placeholder detail screen for the foundation phase.
class CurrencyDetailPage extends StatelessWidget {
  const CurrencyDetailPage({
    super.key,
    required this.code,
  });

  /// ISO currency code from the route (`USD`, `EUR`, …).
  final String code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(code.toUpperCase()),
      ),
      body: Center(
        child: Text('Detail ${code.toUpperCase()}'),
      ),
    );
  }
}
