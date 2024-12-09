import 'package:flutter/material.dart';
import 'package:gighire/esewa_function/esewa.dart';

class EsewaScreen extends StatelessWidget {
  const EsewaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Essewa Payment'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text(
            'Pay with esewa',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ElevatedButton(
            child: Text('pay with esewa'),
            onPressed: () {
              Esewa esewa = Esewa();
              esewa.pay();
            },
          )
        ],
      ),
    );
  }
}
