class AppStrings {
  AppStrings._();

  // App
  static const String appTitle = 'SmartBank EC';

  // Auth
  static const String welcomeBack = 'Bienvenido a SmartBank EC';
  static const String loginTitle = 'Iniciar Sesión';
  static const String registerTitle = 'Crear Cuenta';
  static const String resetPasswordTitle = 'Recuperar Contraseña';
  static const String emailLabel = 'Correo Electrónico';
  static const String passwordLabel = 'Contraseña';
  static const String namesLabel = 'Nombres';
  static const String lastNamesLabel = 'Apellidos';
  static const String phoneLabel = 'Teléfono';
  static const String forgotPassword = '¿Olvidaste tu contraseña?';
  static const String createAccount = 'Crear cuenta';
  static const String loginButton = 'Iniciar Sesión';
  static const String registerButton = 'Create Account';
  static const String sendEmailButton = 'Enviar correo';
  static const String accountCreated = '¡Cuenta creada con éxito! Saldo asignado.';
  static const String recoveryEmailSent = 'Correo de recuperación enviado.';
  static const String emailAlreadyInUse = 'Este correo ya está registrado.';
  static const String invalidEmail = 'Correo inválido.';
  static const String weakPassword = 'La contraseña es muy débil.';
  static const String invalidCredentials = 'Correo o contraseña incorrectos.';
  static const String userNotFound = 'No existe una cuenta con ese correo.';
  static const String profileNotFound = 'Perfil no encontrado. Registra una cuenta primero.';

  // Dashboard
  static const String welcomeUser = 'Bienvenido';
  static const String accountLabel = 'Cuenta';
  static const String totalBalance = 'SALDO TOTAL DISPONIBLE';
  static const String quickActions = 'Accesos Rápidos';
  static const String transferAction = 'Transferir';
  static const String myProfileAction = 'Mi Perfil';
  static const String scanQrAction = 'Escanear QR';
  static const String welcomeBonusTitle = '¡Felicidades!';
  static const String welcomeBonusMessage = 'Has ganado un Bono de Bienvenida de \$200.00 USD por registrarte en SmartBank EC.';
  static const String welcomeBonusDetail = 'Tu saldo inicial de pruebas académicas de \$1,000.00 USD ya se encuentra disponible e incluye esta recompensa.';
  static const String viewBalanceButton = 'Ver mi Saldo';

  // Transfer
  static const String transferTitle = 'Transferir Dinero';
  static const String destinationAccountLabel = 'Número de Cuenta Destino';
  static const String amountLabel = 'Monto a Transferir (USD)';
  static const String confirmTransfer = 'Confirmar Transferencia';
  static const String processingTransfer = 'Procesando transferencia segura... (Pendiente persistencia)';
  static const String selfTransferError = 'No puede transferirse dinero a su propia cuenta';
  static const String insufficientFunds = 'Fondos insuficientes. Saldo disponible:';
  static const String transferSuccess = 'Transferencia realizada con éxito';
  static const String accountNotFound = 'La cuenta destino no existe';

  // QR
  static const String scanQrTitle = 'Escanear QR';
  static const String scanQrHint = 'Escanea el código QR de la cuenta destino. Se completará automáticamente el número de cuenta.';
  static const String invalidQr = 'QR inválido para SmartBank EC';
  static const String selfQrError = 'No puedes transferirte a tu propia cuenta';
  static const String yourQrCode = 'Tu código QR';
  static const String qrDescription = 'Al escanear este QR, el destinatario se completará automáticamente.';

  // Profile
  static const String profileTitle = 'Mi Perfil';
  static const String userDataSection = 'Datos del usuario';
  static const String nameField = 'Nombre';
  static const String saldoField = 'Saldo disponible';
  static const String logout = 'Cerrar sesión';

  // History
  static const String historyTitle = 'Historial de Transacciones';
  static const String noTransactions = 'No hay transacciones registradas';
  static const String typeBonus = 'Bono de Bienvenida';
  static const String typeSent = 'Enviada';
  static const String typeReceived = 'Recibida';

  // Validation
  static const String requiredField = 'Este campo es requerido';
  static const String invalidEmailFormat = 'Formato de correo inválido';
  static const String minPassword = 'Mínimo 8 caracteres';
  static const String passwordRequirements = 'Debe incluir letras y números';
  static const String invalidAmount = 'El monto debe ser un número mayor a cero';
  static const String enterDestination = 'Ingrese la cuenta de destino';
}