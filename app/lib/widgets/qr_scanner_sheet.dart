import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../theme/app_theme.dart';

class QrScannerSheet extends StatefulWidget {
  const QrScannerSheet({super.key, required this.onScanned});

  final ValueChanged<String> onScanned;

  @override
  State<QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<QrScannerSheet> {
  final _controller = MobileScannerController();
  bool _scanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && RegExp(r'^\d{8}$').hasMatch(value)) {
        _scanned = true;
        _controller.stop();
        Navigator.of(context).pop();
        widget.onScanned(value);
        return;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Escanea el QR del paciente',
              style: AppText.label.copyWith(fontSize: 16),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: _onDetect,
                    ),
                    _ScanOverlay(),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'El código QR se encuentra en el perfil del paciente',
              textAlign: TextAlign.center,
              style: AppText.subtitle.copyWith(color: AppColors.hint, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.purple, width: 3),
      ),
    );
  }
}
