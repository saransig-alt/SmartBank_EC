import 'package:flutter/material.dart';

/// Sistema de colores semántico para SmartBank EC.
/// Usa Theme.of(context) para adaptarse automáticamente a Claro/Oscuro.
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color brand = Color(0xFF00BFA5);       // Teal principal
  static const Color brandLight = Color(0xFF1DE9B6);  // Teal más claro
  static const Color brandDark = Color(0xFF00897B);   // Teal más oscuro

  // ── Semánticos ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ── Modo Oscuro ────────────────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF243044);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);

  // ── Modo Claro ─────────────────────────────────────────────────────────────
  static const Color lightBg = Color(0xFFF1F5F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // ── Retrocompatibilidad (para código no migrado aún) ───────────────────────
  static const Color primary = darkBg;
  static const Color accent = brand;
  static const Color surface = darkSurface;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;

  // Para compatibilidad con código existente (main.dart)
  static const Color brandPrimary = brand;


  // ── Helpers de contexto ────────────────────────────────────────────────────
  static Color bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBg : lightBg;

  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : lightCard;

  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;

  static Color textSub(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : lightBorder;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}