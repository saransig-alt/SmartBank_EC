import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../presentation/providers/bank_provider.dart';
import '../../presentation/providers/theme_provider.dart';
import '_profile_body.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios del tema
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: TextStyle(
            color: AppColors.text(context),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Cambiar tema',
            onPressed: () {
              themeProvider.toggleTheme();
            },
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
      body: Consumer<BankProvider>(
        builder: (context, bankProvider, child) {
          final usuario = bankProvider.currentUser;

          if (usuario == null) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
              ),
            );
          }

          return ProfileBody(
            usuario: usuario,
          );
        },
      ),
    );
  }
}