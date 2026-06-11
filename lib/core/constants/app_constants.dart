class AppConstants {
  AppConstants._();

  static const String usersCollection = 'usuarios';
  static const String transactionsCollection = 'transacciones';

  static const double initialBalance = 1000.0;
  static const double welcomeBonus = 1000.0;
  static const double minimumTransfer = 0.01;

  static const String accountPrefix = 'CTA-';
  static const int maxAccountAttempts = 10;

  static const String qrPayloadPrefix = 'SMARTBANK_EC';

  static const int minPasswordLength = 8;
}