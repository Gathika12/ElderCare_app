import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanPage extends StatefulWidget {
  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  String? scannedData;
  bool isNavigating = false; // To prevent multiple navigations
  MobileScannerController _cameraController =
      MobileScannerController(); // Controller for scanner

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.restart_alt),
            onPressed: () {
              setState(() {
                scannedData = null; // Reset scanned data
              });
              _cameraController.start(); // Restart the camera
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: scannedData == null
                ? MobileScanner(
                    controller: _cameraController,
                    onDetect: (BarcodeCapture capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null && !isNavigating) {
                          final String code = barcode.rawValue!;
                          setState(() {
                            scannedData = code;
                          });
                          _cameraController
                              .stop(); // Turn off the camera after scan
                          break;
                        }
                      }
                    },
                  )
                : Center(
                    child: Icon(Icons.qr_code, size: 100, color: Colors.teal),
                  ),
          ),
          Expanded(
            flex: 2,
            child: scannedData == null
                ? _buildInfoPlaceholder()
                : _buildScannedDataCard(scannedData!),
          ),
        ],
      ),
    );
  }

  // Widget for placeholder text
  Widget _buildInfoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.qr_code_scanner, size: 100, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          'Scan a QR code to get data',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ],
    );
  }

  // Widget to display scanned data beautifully with scroll support
  Widget _buildScannedDataCard(String data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Scrollbar(
        thickness: 6.0,
        radius: Radius.circular(8),
        child: SingleChildScrollView(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scanned Data:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      data,
                      style: TextStyle(fontSize: 16, fontFamily: 'Monospace'),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        print('Data confirmed: $data');
                        // Add further actions here
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Confirm & Proceed',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
