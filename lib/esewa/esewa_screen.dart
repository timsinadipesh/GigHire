// import 'package:flutter/material.dart';
// import 'package:gighire/esewa/esewa_function/esewa.dart';

// class EsewaScreen extends StatelessWidget {
//   const EsewaScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Esewa Payment'),
//         backgroundColor: Colors.black87,
//         foregroundColor: Colors.green,
//         elevation: 0,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(24.0),
//         children: [
//           Text(
//             'Pay with esewa',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//           ElevatedButton(
//             child: Text('pay with esewa'),
//             onPressed: () {
//               Esewa esewa = Esewa();
//               esewa.pay();
//             },
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:gighire/esewa/esewa_function/esewa.dart';

class EsewaScreen extends StatelessWidget {
  const EsewaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Esewa Payment'),
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.green,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(
              'Pay with esewa',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                  ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('pay with esewa'),
              onPressed: () {
                Esewa esewa = Esewa();
                esewa.pay();
              },
            ),
          ],
        ),
      ),
    );
  }
}
