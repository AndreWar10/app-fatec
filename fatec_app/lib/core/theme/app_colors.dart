import 'package:flutter/material.dart';

class AppColors {
  // Cor principal do app
  static const Color primary = Color(0xFFB20000);
  
  // Variações da cor principal
  static const Color primaryLight = Color(0xFFE53333);
  static const Color primaryDark = Color(0xFF8A0000);
  
  // Cores de superfície
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color imageBackground = Color(0xFFF0F0F0);
  
  // Cores de texto
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF000000);
  static const Color onSurfaceVariant = Color(0xFF666666);
  
  // Cores de fundo
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  
  // Cores de borda e divisores
  static const Color outline = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Cores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Cores de hover e pressed
  static const Color hover = Color(0xFFF5F5F5);
  static const Color pressed = Color(0xFFE0E0E0);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryLight, primary],
  );
  
  // Sombras
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
}
