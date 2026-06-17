import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/produto.dart';

class ProdutoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _colecao {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('usuarios').doc(uid).collection('produtos');
  }

  Stream<List<Produto>> listar() {
    return _colecao.orderBy('nome').snapshots().map((snap) {
      return snap.docs
          .map((doc) => Produto.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> adicionar(Produto produto) async {
    await _colecao.add(produto.toMap());
  }

  Future<void> atualizar(Produto produto) async {
    await _colecao.doc(produto.id).update(produto.toMap());
  }

  Future<void> excluir(String id) async {
    await _colecao.doc(id).delete();
  }
}
