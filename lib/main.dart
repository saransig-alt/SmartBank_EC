import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/constants/app_colors.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/bank_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'core/constants/app_theme.dart';
import 'views/auth/login.screen.dart';
import 'views/auth/register.screen.dart';
import 'views/auth/reset_password.screen.dart';
import 'views/dashboard/home_screen.dart';
import 'views/dashboard/profile_screen.dart';
import 'views/qr/scan_qr_screen.dart';
import 'views/dashboard/history_screen.dart';
import 'views/transactions/transfer_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await di.initDependencies();
    runApp(const MyApp());
  } catch (e, stackTrace) {
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Startup Error:\n$e\n\n$stackTrace',
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<BankProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ThemeProvider>()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'SmartBank EC',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return _buildPageRoute(const AuthGate(), settings);
                case '/login':
                  return _buildPageRoute(const LoginScreen(), settings);
                case '/register':
                  return _buildPageRoute(const RegisterScreen(), settings);
                case '/reset':
                  return _buildPageRoute(const ResetPasswordScreen(), settings);
                case '/home':
                  return _buildPageRoute(const HomeScreen(), settings);
                case '/profile':
                  return _buildPageRoute(const ProfileScreen(), settings);
                case '/scan':
                  return _buildPageRoute(const ScanQrScreen(), settings);
                case '/history':
                  return _buildPageRoute(const HistoryScreen(), settings);
                case '/transfer':
                  final cuentaEscaneada = settings.arguments as String?;
                  return _buildPageRoute(
                    TransferScreen(cuentaEscaneada: cuentaEscaneada),
                    settings,
                  );
                default:
                  return _buildPageRoute(const AuthGate(), settings);
              }
            },
          );
        },
      ),
    );
  }

  PageRouteBuilder _buildPageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bankProvider = Provider.of<BankProvider>(context, listen: false);

    authProvider.loadCurrentUser(bankProvider: bankProvider).then((_) {
      if (!mounted) return;

      // ✅ CORRECCIÓN AQUÍ: Forzamos a que la navegación ocurra
      // inmediatamente después de que concluya el renderizado del frame actual.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final loggedIn = authProvider.isLoggedIn;
          Navigator.of(
            context,
          ).pushReplacementNamed(loggedIn ? '/home' : '/login');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColors.brandPrimary), //
      ),
    );
  }
}
