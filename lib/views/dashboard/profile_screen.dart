import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../presentation/providers/bank_provider.dart';
import '_profile_body.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<BankProvider>(
        builder: (context, bankProvider, child) {
          final usuario = bankProvider.currentUser;

          if (usuario == null) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          return ProfileBody(usuario: usuario);
        },
      ),
    );
  }
}
