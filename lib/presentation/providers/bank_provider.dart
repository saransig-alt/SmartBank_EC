import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/di/injection_container.dart' as di;
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/bank/listen_user_data_usecase.dart';
import '../../domain/usecases/bank/get_transactions_usecase.dart';
import '../../domain/usecases/bank/transfer_money_usecase.dart';

class BankProvider extends ChangeNotifier {
  final ListenUserDataUseCase _listenUserDataUseCase = di.sl<ListenUserDataUseCase>();
  final GetTransactionsUseCase _getTransactionsUseCase = di.sl<GetTransactionsUseCase>();
  final TransferMoneyUseCase _transferMoneyUseCase = di.sl<TransferMoneyUseCase>();

  UserEntity? _currentUser;
  List<TransactionEntity> _transactions = [];
  bool _isLoading = false;
  StreamSubscription<UserEntity>? _userSubscription;
  StreamSubscription<List<TransactionEntity>>? _transactionsSubscription;

  UserEntity? get currentUser => _currentUser;
  List<TransactionEntity> get transactions => _transactions;
  bool get isLoading => _isLoading;


  void escucharUsuarioDatos(String uid) {
    _userSubscription?.cancel();
    _transactionsSubscription?.cancel();

    _userSubscription = _listenUserDataUseCase.execute(uid).listen((user) {
      _currentUser = user;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Error al escuchar datos de usuario: $error');
    });

    _transactionsSubscription = _getTransactionsUseCase.execute(uid).listen((txns) {
      _transactions = txns;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Error al escuchar transacciones: $error');
    });
  }


  Future<String?> transferMoney({
    required String cuentaDestino,
    required double monto,
  }) async {
    if (_currentUser == null) return 'Usuario no autenticado';

  
    if (cuentaDestino.trim() == _currentUser!.numeroCuenta.trim()) {
      return 'No puede transferirse dinero a su propia cuenta';
    }

   
    if (monto > _currentUser!.saldo) {
      return 'Fondos insuficientes. Saldo disponible: \$${_currentUser!.saldo.toStringAsFixed(2)}';
    }

    _setLoading(true);
    try {
      await _transferMoneyUseCase.execute(
        uidOrigen: _currentUser!.uid,
        cuentaDestino: cuentaDestino.trim(),
        monto: monto,
      );

      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _transactionsSubscription?.cancel();
    super.dispose();
  }
}