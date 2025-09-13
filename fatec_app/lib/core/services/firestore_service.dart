
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Busca dados do documento 'home' na collection 'app-assets'
  static Future<Map<String, dynamic>?> getHomeData() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('app-assets')
          .doc('home')
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      } else {
        print('Documento "home" não encontrado na collection "app-assets"');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar dados do Firestore: $e');
      return null;
    }
  }

  /// Busca especificamente o campo 'highlights' do documento 'home'
  static Future<List<dynamic>?> getHighlights() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('app-assets')
          .doc('home')
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['highlights'] as List<dynamic>?;
      } else {
        print('Documento "home" não encontrado na collection "app-assets"');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar highlights do Firestore: $e');
      return null;
    }
  }

  /// Imprime todos os dados do documento 'home' no console
  static Future<void> printHomeData() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('app-assets')
          .doc('home')
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('=== DADOS DO DOCUMENTO HOME ===');
        print('ID do documento: ${doc.id}');
        print('Dados completos:');
        data.forEach((key, value) {
          print('  $key: $value');
        });
        print('===============================');
      } else {
        print('Documento "home" não encontrado na collection "app-assets"');
      }
    } catch (e) {
      print('Erro ao imprimir dados do Firestore: $e');
    }
  }
}
