import 'package:flutter/material.dart';

/// Placeholder home screen for the foundation phase.
class ExchangeRatesPage extends StatelessWidget {
  const ExchangeRatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Tracker'),
      ),
      body: const Center(
        child: Text('Foundation — exchange rates'),
      ),
    );
  }
}
