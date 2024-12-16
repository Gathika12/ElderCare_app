import 'package:elder_care/screens/merchant/user_date.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanPage extends StatefulWidget {
  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  String? scannedData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: (BarcodeCapture capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    final String code = barcode.rawValue!;
                    setState(() {
                      scannedData = code;
                    });

                    // Parse the userId from scanned QR data and navigate
                    final userId = _extractUserId(code);
                    if (userId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDataPage(userId: userId),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid QR Code')),
                      );
                    }
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: scannedData == null
                  ? Text('Scan a code')
                  : Text('Scanned Data: $scannedData'),
            ),
          ),
        ],
      ),
    );
  }

  String? _extractUserId(String scannedData) {
    // Assume the QR data contains "userId: <value>"
    final RegExp regex = RegExp(r'userId:\s*(\d+)');
    final match = regex.firstMatch(scannedData);
    return match?.group(1); // Extract the userId
  }
}
