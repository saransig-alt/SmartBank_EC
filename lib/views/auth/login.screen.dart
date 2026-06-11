import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/bank_provider.dart';
import '../../presentation/widgets/common/snackbar_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final bank = Provider.of<BankProvider>(context, listen: false);

    final error = await auth.iniciarSesion(
      correo: _correoController.text.trim(),
      contrasena: _contrasenaController.text.trim(),
      bankProvider: bank,
    );

    if (!mounted) return;
    if (error != null) {
      SnackbarHelper.showError(context, error);
      return;
    }
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    final textColor = AppColors.text(context);
    final subColor = AppColors.textSub(context);

    return Scaffold(
      body: SafeArea(
        child: auth.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 80,
                        errorBuilder: (context, error, stackTrace) => Container(

                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: AppColors.brand.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.account_balance, color: AppColors.brand, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Bienvenido',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Inicia sesión en tu cuenta SmartBank EC',
                      style: TextStyle(color: subColor, fontSize: 15),
                    ),
                    const SizedBox(height: 36),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email
                          TextFormField(
                            controller: _correoController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: textColor),
                            decoration: const InputDecoration(
                              labelText: 'Correo Electrónico',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) => Validators.email(v),
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _contrasenaController,
                            obscureText: _obscure,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) => Validators.password(v),
                          ),
                          const SizedBox(height: 8),

                          // Olvidé contraseña
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pushNamed('/reset'),
                              child: const Text('¿Olvidaste tu contraseña?'),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Botón principal
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _iniciarSesion,
                              child: const Text('Iniciar Sesión'),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Crear cuenta
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('¿No tienes cuenta?', style: TextStyle(color: subColor)),
                              TextButton(
                                onPressed: () => Navigator.of(context).pushNamed('/register'),
                                child: const Text('Regístrate'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
