import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../presentation/providers/bank_provider.dart';
import '../../presentation/widgets/common/snackbar_helper.dart';

class TransferScreen extends StatefulWidget {
  /// Cuenta destino recibida desde el escáner QR (opcional).
  final String? cuentaEscaneada;

  const TransferScreen({super.key, this.cuentaEscaneada});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cuentaDestinoController = TextEditingController();
  final _montoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.cuentaEscaneada != null && widget.cuentaEscaneada!.isNotEmpty) {
      _cuentaDestinoController.text = widget.cuentaEscaneada!;
    }
  }

  @override
  void dispose() {
    _cuentaDestinoController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _ejecutarTransferencia() async {
    if (!_formKey.currentState!.validate()) return;

    final bankProvider = Provider.of<BankProvider>(context, listen: false);
    final monto = double.parse(_montoController.text.trim());
    final cuentaDestino = _cuentaDestinoController.text.trim();

    final error = await bankProvider.transferMoney(
      cuentaDestino: cuentaDestino,
      monto: monto,
    );

    if (!mounted) return;

    if (error != null) {
      SnackbarHelper.showError(context, error);
      return;
    }

    SnackbarHelper.showSuccess(context, 'Transferencia realizada con éxito');

    _cuentaDestinoController.clear();
    _montoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bankProvider = Provider.of<BankProvider>(context);
    final usuarioOrigen = bankProvider.currentUser;

    final textPrimary = AppColors.text(context);
    final textSecondary = AppColors.textSub(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transferir Dinero',
          style: TextStyle(color: textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: bankProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Campo: Cuenta destino
                    TextFormField(
                      controller: _cuentaDestinoController,
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Número de Cuenta Destino',
                        labelStyle: TextStyle(color: textSecondary),
                      ),
                      validator: (value) => Validators.destinationAccount(
                        value,
                        currentAccount: usuarioOrigen?.numeroCuenta,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo: Monto
                    TextFormField(
                      controller: _montoController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Monto a Transferir (USD)',
                        labelStyle: TextStyle(color: textSecondary),
                      ),
                      validator: (value) {
                        final base = Validators.amount(
                          value,
                          maxAmount: usuarioOrigen?.saldo,
                        );
                        if (base != null) return base;

                        final parsed = double.tryParse(value?.trim() ?? '');
                        if (parsed == null) return 'Monto inválido';
                        if (parsed <= 0) return 'El monto debe ser mayor a cero';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Botón: Confirmar transferencia
                    ElevatedButton(
                      onPressed: _ejecutarTransferencia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Confirmar Transferencia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}