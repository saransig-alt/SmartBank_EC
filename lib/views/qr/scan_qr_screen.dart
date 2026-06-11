import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../presentation/providers/bank_provider.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController _controller = MobileScannerController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, String>? _parsePayload(String raw) {
    // Esperamos formato: SMARTBANK_EC|uid|numeroCuenta
    final parts = raw.split('|');
    if (parts.length != 3) return null;
    if (parts[0] != 'SMARTBANK_EC') return null;

    return {
      'uid': parts[1],
      'numeroCuenta': parts[2],
    };
  }

  Future<void> _handleBarcode(String raw) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final bankProvider = Provider.of<BankProvider>(context, listen: false);
    final usuarioOrigen = bankProvider.currentUser;

    final parsed = _parsePayload(raw);
    if (parsed == null) {
      _isProcessing = false;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR inválido para SmartBank EC'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final cuentaDestino = parsed['numeroCuenta']!;

    if (usuarioOrigen != null && cuentaDestino.trim() == usuarioOrigen.numeroCuenta.trim()) {
      _isProcessing = false;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes transferirte a tu propia cuenta'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushNamed('/transfer', arguments: cuentaDestino);

    _isProcessing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: (capture) async {
                final raw = capture.barcodes.firstOrNull?.rawValue;
                if (raw == null) return;
                await _handleBarcode(raw);
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Text(
              'Escanea el código QR de la cuenta destino. Se completará automáticamente el número de cuenta.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          )
        ],
      ),
    );
  }
}

