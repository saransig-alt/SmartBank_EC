import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/bank_provider.dart';
import '../../presentation/widgets/common/snackbar_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _procesarRegistro() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final bank = Provider.of<BankProvider>(context, listen: false);

    final error = await auth.registrarUsuario(
      nombres: _nombresController.text.trim(),
      apellidos: _apellidosController.text.trim(),
      correo: _correoController.text.trim(),
      telefono: _telefonoController.text.trim(),
      contrasena: _contrasenaController.text.trim(),
      bankProvider: bank,
    );

    if (!mounted) return;
    if (error != null) {
      SnackbarHelper.showError(context, error);
      return;
    }

    SnackbarHelper.showSuccess(context, '¡Cuenta creada! Recibirás un bono de bienvenida.');
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final textColor = AppColors.text(context);
    final subColor = AppColors.textSub(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: auth.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Crea tu cuenta',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Completa los datos para registrarte',
                      style: TextStyle(color: subColor),
                    ),
                    const SizedBox(height: 28),

                    // Nombres
                    TextFormField(
                      controller: _nombresController,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        labelText: 'Nombres',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                      validator: (v) => Validators.notEmpty(v, 'sus nombres'),
                    ),
                    const SizedBox(height: 14),

                    // Apellidos
                    TextFormField(
                      controller: _apellidosController,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        labelText: 'Apellidos',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                      validator: (v) => Validators.notEmpty(v, 'sus apellidos'),
                    ),
                    const SizedBox(height: 14),

                    // Correo
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
                    const SizedBox(height: 14),

                    // Teléfono
                    TextFormField(
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) => Validators.notEmpty(v, 'su número de teléfono'),
                    ),
                    const SizedBox(height: 14),

                    // Contraseña
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
                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: _procesarRegistro,
                      child: const Text('Crear Cuenta'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('¿Ya tienes cuenta?', style: TextStyle(color: subColor)),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Inicia sesión'),
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