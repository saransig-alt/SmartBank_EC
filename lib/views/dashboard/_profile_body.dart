import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:characters/characters.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/user_entity.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/bank_provider.dart';

class ProfileBody extends StatefulWidget {
  final UserEntity usuario;

  const ProfileBody({
    Key? key,
    required this.usuario,
  }) : super(key: key);

  @override
  State<ProfileBody> createState() => ProfileBodyState();
}

class ProfileBodyState extends State<ProfileBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nombresController;
  late TextEditingController _apellidosController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    _nombresController =
        TextEditingController(text: widget.usuario.nombres);
    _apellidosController =
        TextEditingController(text: widget.usuario.apellidos);
    _correoController =
        TextEditingController(text: widget.usuario.correo);
    _telefonoController =
        TextEditingController(text: widget.usuario.telefono);
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  String _initials(String nombres, String apellidos) {
    final first = nombres.trim().isNotEmpty
        ? nombres.trim().characters.first
        : '';

    final second = apellidos.trim().isNotEmpty
        ? apellidos.trim().characters.first
        : '';

    final initials = (first + second).toUpperCase();

    return initials.isEmpty ? '?' : initials;
  }

  static String buildQrPayload({
    required String uid,
    required String numeroCuenta,
  }) {
    return 'SMARTBANK_EC|$uid|$numeroCuenta';
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final error = await authProvider.updateProfile(
      nombres: _nombresController.text.trim(),
      apellidos: _apellidosController.text.trim(),
      correo: _correoController.text.trim(),
      telefono: _telefonoController.text.trim(),
      photoUrl: widget.usuario.photoUrl,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(error),
        ),
      );
      return;
    }

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil actualizado correctamente'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bankProvider = context.watch<BankProvider>();

    final currentUser =
        bankProvider.currentUser ?? widget.usuario;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.surface,
                backgroundImage: currentUser.photoUrl != null &&
                        currentUser.photoUrl!.isNotEmpty
                    ? NetworkImage(currentUser.photoUrl!)
                    : null,
                child: currentUser.photoUrl == null ||
                        currentUser.photoUrl!.isEmpty
                    ? Text(
                        _initials(
                          currentUser.nombres,
                          currentUser.apellidos,
                        ),
                        style: TextStyle(
                          color: AppColors.text(context),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Datos del usuario',
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (!_isEditing) ...[
            _InfoRow(
              label: 'Nombre',
              value:
                  '${currentUser.nombres} ${currentUser.apellidos}',
            ),

            _InfoRow(
              label: 'Cuenta',
              value: currentUser.numeroCuenta,
            ),

            _InfoRow(
              label: 'Correo',
              value: currentUser.correo,
            ),

            _InfoRow(
              label: 'Teléfono',
              value: currentUser.telefono,
            ),

            _InfoRow(
              label: 'Saldo disponible',
              value:
                  '\$${currentUser.saldo.toStringAsFixed(2)} USD',
              monospace: true,
            ),

            const SizedBox(height: 14),

            OutlinedButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;

                  _nombresController.text =
                      currentUser.nombres;

                  _apellidosController.text =
                      currentUser.apellidos;

                  _correoController.text =
                      currentUser.correo;

                  _telefonoController.text =
                      currentUser.telefono;
                });
              },
              child: const Text(
                'Editar datos personales',
              ),
            ),
          ] else ...[
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Editar datos',
                    style: TextStyle(
                      color: AppColors.text(context),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _nombresController,
                    decoration: const InputDecoration(
                      labelText: 'Nombres',
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Nombres requeridos';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _apellidosController,
                    decoration: const InputDecoration(
                      labelText: 'Apellidos',
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Apellidos requeridos';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _correoController,
                    keyboardType:
                        TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                    ),
                    validator: (value) {
                      if (value == null ||
                          !value.contains('@')) {
                        return 'Correo inválido';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _telefonoController,
                    keyboardType:
                        TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().length < 7) {
                        return 'Teléfono inválido';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                            });
                          },
                          child: const Text('Cancelar'),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onSave,
                          child: const Text('Guardar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          Text(
            'Tu código QR',
            style: TextStyle(
              color: AppColors.text(context),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color:
                      AppColors.accent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: QrImageView(
                data: buildQrPayload(
                  uid: currentUser.uid,
                  numeroCuenta:
                      currentUser.numeroCuenta,
                ),
                version: QrVersions.auto,
                size: 220,
                backgroundColor:
                    AppColors.bg(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;

  const _InfoRow({
    required this.label,
    required this.value,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSub(context),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: TextStyle(
              color: AppColors.text(context),
              fontSize: 14,
              fontFamily:
                  monospace ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }
}