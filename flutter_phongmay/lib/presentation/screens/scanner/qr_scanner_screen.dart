import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isScanned = false; 
  bool _isTorchOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét QR Máy Tính'),
        backgroundColor: const Color(0xFF1D357A), 
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
              try {
                await cameraController.toggleTorch();
                setState(() => _isTorchOn = !_isTorchOn);
              } catch (_) {}
            },
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          List<Barcode> barcodes = [];
          try {
            final dynamic c = capture;
            if (c is Barcode) {
              barcodes = [c];
            } else {
              final dynamic cap = c;
              if (cap != null) {
                if (cap.barcodes != null) {
                  final dynamic list = cap.barcodes;
                  if (list is Iterable) {
                    barcodes = List<Barcode>.from(list.cast<Barcode>());
                  }
                } else if (cap.rawValue != null) {
                  barcodes = [cap as Barcode];
                }
              }
            }
          } catch (_) {}

          if (!_isScanned && barcodes.isNotEmpty) {
            _isScanned = true;
            final String qrCodeData = barcodes.first.rawValue ?? '';
            cameraController.stop();
            Navigator.pop(context, qrCodeData);
          }
        },
      ),
    );
  }
}