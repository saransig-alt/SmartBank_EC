# SmartBank EC - Estado de implementación

## ✅ Completado

- [x] **Arquitectura limpia**: core/, domain/, data/, presentation/, views/
- [x] **Inyección de dependencias**: get_it con todas las capas registradas
- [x] **Firebase Auth**: Registro, inicio sesión, cierre sesión, recuperación contraseña
- [x] **Firestore**: Perfiles de usuario, transacciones en tiempo real
- [x] **Generación de QR**: QR único por usuario con uid + número de cuenta
- [x] **Escaneo de QR**: mobile_scanner que extrae cuenta destino
- [x] **Transferencias bancarias**: Opción A (manual) + Opción B (desde QR)
- [x] **Transferencia atómica**: Firestore runTransaction con débito/crédito + 2 registros
- [x] **Historial de transacciones**: Vista con pestañas (Todas, Depósitos, Enviadas, Recibidas)
- [x] **Consulta de saldo**: Tarjeta de saldo en Home con actualización en tiempo real
- [x] **Resumen de movimientos**: Totales de enviado/recibido/depósitos
- [x] **Últimos movimientos**: 3 transacciones más recientes en Home
- [x] **Validaciones**: No a sí mismo, cuenta existe, saldo suficiente, formularios

## Pendientes

- [ ] **Firestore rules**: Agregar `firestore.rules` con seguridad por usuario
- [ ] **Cerrar sesión redirige a login**: Ya implementado en HomeScreen
- [ ] **Widget tests**: Actualizar test/widget_test.dart