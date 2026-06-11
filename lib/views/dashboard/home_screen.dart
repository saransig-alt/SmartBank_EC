import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../presentation/providers/bank_provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/theme_provider.dart'; // <- Importación agregada

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showWelcomeBonus = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showWelcomeBonus) {
        _mostrarBonoModal();
        _showWelcomeBonus = false;
      }
    });
  }

  void _mostrarBonoModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final textPrimary = AppColors.text(context);
        final textSecondary = AppColors.textSub(context);

        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.card_giftcard, color: AppColors.accent, size: 28),
              const SizedBox(width: 10),
              Text('¡Felicidades!', style: TextStyle(color: textPrimary)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Has ganado un Bono de Bienvenida de \$200.00 USD por registrarte en SmartBank EC.',
                style: TextStyle(color: textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                'Tu saldo inicial de pruebas académicas de \$1,000.00 USD ya se encuentra disponible e incluye esta recompensa.',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Ver mi Saldo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bankProvider = Provider.of<BankProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final usuario = bankProvider.currentUser;
    final transactions = bankProvider.transactions;

    final textPrimary = AppColors.text(context);
    final textSecondary = AppColors.textSub(context);

    // Últimas 3 transacciones para el resumen
    final recentTransactions = transactions.length > 3
        ? transactions.sublist(transactions.length - 3)
        : transactions;

    // Totales del resumen
    final totalSent = transactions
        .where((t) => t.tipo == 'Enviada')
        .fold<double>(0, (sum, t) => sum + t.monto);
    final totalReceived = transactions
        .where((t) => t.tipo == 'Recibida')
        .fold<double>(0, (sum, t) => sum + t.monto);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SmartBank EC',
          style: TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // ¡Aquí quedó tu botón del Modo Oscuro/Claro integrado!
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                tooltip: 'Cambiar tema',
                onPressed: () {
                  themeProvider.toggleTheme();
                },
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.accent,
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Mi Perfil',
            icon: const Icon(Icons.person, color: AppColors.accent),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () async {
              await authProvider.cerrarSesion();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: usuario == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : RefreshIndicator(
              color: AppColors.accent,
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Saludo
                    Text(
                      'Bienvenido, ${usuario.nombres} ${usuario.apellidos}',
                      style: TextStyle(color: textSecondary, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cuenta: ${usuario.numeroCuenta}',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tarjeta de Saldo
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.surface,
                            AppColors.surface.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SALDO TOTAL DISPONIBLE',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '\$${usuario.saldo.toStringAsFixed(2)} USD',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: textSecondary,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Actualizado en tiempo real',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Resumen rápido de movimientos
                    Row(
                      children: [
                        _ResumenCard(
                          icon: Icons.arrow_upward,
                          label: 'Enviado',
                          monto: totalSent,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 12),
                        _ResumenCard(
                          icon: Icons.arrow_downward,
                          label: 'Recibido',
                          monto: totalReceived,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 12),
                        _ResumenCard(
                          icon: Icons.card_giftcard,
                          label: 'Depósitos',
                          monto: transactions
                              .where((t) => t.tipo == 'Bono de Bienvenida')
                              .fold<double>(0, (sum, t) => sum + t.monto),
                          color: Colors.amber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Movimientos recientes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Movimientos Recientes',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/history');
                          },
                          child: const Text(
                            'Ver todo',
                            style: TextStyle(color: AppColors.accent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (recentTransactions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'No hay movimientos recientes',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textSecondary),
                        ),
                      )
                    else
                      ...recentTransactions.reversed.map((txn) {
                        final isEnviada = txn.tipo == 'Enviada';
                        final color = isEnviada
                            ? AppColors.error
                            : txn.tipo == 'Bono de Bienvenida'
                            ? Colors.amber
                            : AppColors.accent;
                        final icon = txn.tipo == 'Bono de Bienvenida'
                            ? Icons.card_giftcard
                            : isEnviada
                            ? Icons.arrow_upward
                            : Icons.arrow_downward;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(icon, color: color, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      txn.tipo,
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${txn.fecha} - ${txn.hora}',
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isEnviada ? '-' : '+'}\$${txn.monto.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 24),

                    // Accesos Rápidos
                    Text(
                      'Accesos Rápidos',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _QuickActionButton(
                          icon: Icons.send,
                          label: 'Transferir',
                          color: AppColors.accent,
                          onTap: () =>
                              Navigator.of(context).pushNamed('/transfer'),
                        ),
                        const SizedBox(width: 12),
                        _QuickActionButton(
                          icon: Icons.camera_alt,
                          label: 'Escanear QR',
                          color: AppColors.accent,
                          onTap: () => Navigator.of(context).pushNamed('/scan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double monto;
  final Color color;

  const _ResumenCard({
    required this.icon,
    required this.label,
    required this.monto,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              '\$${monto.toStringAsFixed(0)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: AppColors.textSub(context), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.textSub(context).withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: AppColors.text(context), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
