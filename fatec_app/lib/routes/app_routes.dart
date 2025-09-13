import 'package:flutter/material.dart';
import 'package:fatec_app/home/presentation/pages/home_page.dart';

class AppRoutes {
  // Nomes das rotas
  static const String home = '/';
  static const String profile = '/profile';
  static const String settings = '/settings';
  
  // Mapa de rotas
  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomePage(),
    profile: (context) => const ProfilePage(),
    settings: (context) => const SettingsPage(),
  };
  
  // Rota inicial
  static String get initialRoute => home;
  
  // Método para navegar
  static void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }
  
  // Método para navegar e remover rotas anteriores
  static void navigateAndRemoveUntil(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }
  
  // Método para substituir rota atual
  static void navigateReplacement(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }
}

// Páginas temporárias para demonstração
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: const Center(
        child: Text('Página de Perfil'),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: const Center(
        child: Text('Página de Configurações'),
      ),
    );
  }
}
