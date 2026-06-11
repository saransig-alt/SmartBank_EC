import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../presentation/providers/bank_provider.dart';
import '../../domain/entities/transaction_entity.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bankProvider = Provider.of<BankProvider>(context);
    final transactions = bankProvider.transactions;
    final usuario = bankProvider.currentUser;

    // Separar por tipo
    final bonuses = transactions.where((t) => t.tipo == 'Bono de Bienvenida').toList();
    final sent = transactions.where((t) => t.tipo == 'Enviada').toList();
    final received = transactions.where((t) => t.tipo == 'Recibida').toList();

    return Builder(
      builder: (context) {
        final textPrimary = AppColors.text(context);
        final textSecondary = AppColors.textSub(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Historial de Transacciones',
              style: TextStyle(color: textPrimary),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: usuario == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                )
              : transactions.isEmpty
                  ? Center(
                      child: Text(
                        'No hay transacciones registradas',
                        style: TextStyle(color: textSecondary),
                      ),
                    )
                  : DefaultTabController(
                      length: 4,
                      child: Column(
                        children: [
                          // Pestañas de filtro
                          TabBar(
                            isScrollable: true,
                            indicatorColor: AppColors.accent,
                            labelColor: AppColors.accent,
                            unselectedLabelColor: textSecondary,
                            tabs: const [
                              Tab(text: 'Todas'),
                              Tab(text: 'Depósitos'),
                              Tab(text: 'Enviadas'),
                              Tab(text: 'Recibidas'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildTransactionList(
                                    context,
                                    transactions,
                                    usuario.numeroCuenta,
                                ),
                                _buildTransactionList(
                                    context,
                                    bonuses,
                                    usuario.numeroCuenta,
                                ),
                                _buildTransactionList(
                                    context,
                                    sent,
                                    usuario.numeroCuenta,
                                ),
                                _buildTransactionList(
                                    context,
                                    received,
                                    usuario.numeroCuenta,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    List<TransactionEntity> transactions,
    String miCuenta,
  ) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          'No hay transacciones en esta categoría',
          style: TextStyle(color: AppColors.textSub(context)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final txn = transactions[index];
        return _TransactionCard(transaccion: txn, miCuenta: miCuenta);
      },
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionEntity transaccion;
  final String miCuenta;

  const _TransactionCard({
    required this.transaccion,
    required this.miCuenta,
  });

  IconData _getIcon() {
    switch (transaccion.tipo) {
      case 'Bono de Bienvenida':
        return Icons.card_giftcard;
      case 'Enviada':
        return Icons.arrow_upward;
      case 'Recibida':
        return Icons.arrow_downward;
      default:
        return Icons.swap_horiz;
    }
  }

  Color _getColor() {
    switch (transaccion.tipo) {
      case 'Bono de Bienvenida':
        return AppColors.accent;
      case 'Enviada':
        return AppColors.error;
      case 'Recibida':
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnviada = transaccion.tipo == 'Enviada';
    final montoStr =
        '${isEnviada ? '-' : '+'}\$${transaccion.monto.toStringAsFixed(2)} USD';

    final textPrimary = AppColors.text(context);
    final textSecondary = AppColors.textSub(context);

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icono del tipo
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getColor().withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getIcon(), color: _getColor(), size: 24),
            ),
            const SizedBox(width: 16),

            // Información central
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaccion.tipo,
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${transaccion.fecha} - ${transaccion.hora}',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaccion.tipo == 'Bono de Bienvenida'
                        ? 'De: ${transaccion.cuentaOrigen}'
                        : '${transaccion.cuentaOrigen} → ${transaccion.cuentaDestino}',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            // Monto
            Text(
              montoStr,
              style: TextStyle(
                color: _getColor(),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}