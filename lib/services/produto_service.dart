import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/produto.dart';

class ProdutoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _colecao {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('usuarios').doc(uid).collection('produtos');
  }

  Stream<List<Produto>> listar({String? categoria}) {
    Query query = _colecao.orderBy('nome');
    if (categoria != null) {
      query = _colecao.where('categoria', isEqualTo: categoria).orderBy('nome');
    }
    return query.snapshots().map((snap) {
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

  /// Insere produtos de exemplo se o estoque estiver vazio.
  Future<void> popularSeVazio() async {
    final snap = await _colecao.limit(1).get();
    if (snap.docs.isNotEmpty) return; // já tem dados, não faz nada

    final produtos = [
      // Frutas e Verduras
      Produto(nome: 'Maçã Fuji', descricao: 'Maçã fuji premium, saco 1 kg', preco: 8.99, quantidade: 50, categoria: 'Frutas e Verduras'),
      Produto(nome: 'Banana Prata', descricao: 'Banana prata madura, cacho ~1 kg', preco: 4.49, quantidade: 80, categoria: 'Frutas e Verduras'),
      Produto(nome: 'Tomate Italiano', descricao: 'Tomate italiano firme, bandeja 600 g', preco: 5.99, quantidade: 60, categoria: 'Frutas e Verduras'),
      Produto(nome: 'Alface Crespa', descricao: 'Alface crespa hidropônica, unidade', preco: 2.99, quantidade: 40, categoria: 'Frutas e Verduras'),
      Produto(nome: 'Cenoura', descricao: 'Cenoura lavada, pacote 500 g', preco: 3.49, quantidade: 45, categoria: 'Frutas e Verduras'),

      // Carnes e Peixes
      Produto(nome: 'Frango Inteiro', descricao: 'Frango inteiro resfriado, aprox. 2 kg', preco: 18.90, quantidade: 30, categoria: 'Carnes e Peixes'),
      Produto(nome: 'Picanha Bovina', descricao: 'Picanha bovina premium, kg', preco: 89.90, quantidade: 15, categoria: 'Carnes e Peixes'),
      Produto(nome: 'Filé de Tilápia', descricao: 'Filé de tilápia congelado, pacote 500 g', preco: 22.50, quantidade: 25, categoria: 'Carnes e Peixes'),
      Produto(nome: 'Linguiça Calabresa', descricao: 'Linguiça calabresa defumada, 500 g', preco: 14.90, quantidade: 35, categoria: 'Carnes e Peixes'),

      // Laticínios
      Produto(nome: 'Leite Integral', descricao: 'Leite integral longa vida, 1 L', preco: 5.49, quantidade: 100, categoria: 'Laticínios'),
      Produto(nome: 'Queijo Mussarela', descricao: 'Queijo mussarela fatiado, 200 g', preco: 9.90, quantidade: 40, categoria: 'Laticínios'),
      Produto(nome: 'Iogurte Natural', descricao: 'Iogurte natural integral, pote 170 g', preco: 3.79, quantidade: 55, categoria: 'Laticínios'),
      Produto(nome: 'Manteiga com Sal', descricao: 'Manteiga com sal, tablete 200 g', preco: 11.90, quantidade: 30, categoria: 'Laticínios'),

      // Padaria
      Produto(nome: 'Pão Francês', descricao: 'Pão francês crocante, unidade', preco: 0.79, quantidade: 200, categoria: 'Padaria'),
      Produto(nome: 'Pão de Forma Integral', descricao: 'Pão de forma integral, pacote 500 g', preco: 7.49, quantidade: 45, categoria: 'Padaria'),
      Produto(nome: 'Croissant', descricao: 'Croissant de manteiga, unidade', preco: 4.99, quantidade: 30, categoria: 'Padaria'),
      Produto(nome: 'Bolo de Cenoura', descricao: 'Fatia de bolo de cenoura com cobertura', preco: 6.50, quantidade: 20, categoria: 'Padaria'),

      // Bebidas
      Produto(nome: 'Água Mineral', descricao: 'Água mineral sem gás, garrafa 500 ml', preco: 2.49, quantidade: 120, categoria: 'Bebidas'),
      Produto(nome: 'Suco de Laranja', descricao: 'Suco de laranja natural, caixa 1 L', preco: 8.90, quantidade: 60, categoria: 'Bebidas'),
      Produto(nome: 'Refrigerante Cola', descricao: 'Refrigerante cola, garrafa 2 L', preco: 9.99, quantidade: 70, categoria: 'Bebidas'),
      Produto(nome: 'Café Solúvel', descricao: 'Café solúvel tradicional, frasco 200 g', preco: 19.90, quantidade: 35, categoria: 'Bebidas'),

      // Mercearia
      Produto(nome: 'Arroz Branco', descricao: 'Arroz branco tipo 1, pacote 5 kg', preco: 24.90, quantidade: 80, categoria: 'Mercearia'),
      Produto(nome: 'Feijão Carioca', descricao: 'Feijão carioca, pacote 1 kg', preco: 8.99, quantidade: 65, categoria: 'Mercearia'),
      Produto(nome: 'Macarrão Espaguete', descricao: 'Macarrão espaguete, pacote 500 g', preco: 4.29, quantidade: 90, categoria: 'Mercearia'),
      Produto(nome: 'Azeite Extra Virgem', descricao: 'Azeite extra virgem, garrafa 500 ml', preco: 29.90, quantidade: 25, categoria: 'Mercearia'),

      // Higiene e Limpeza
      Produto(nome: 'Sabonete Líquido', descricao: 'Sabonete líquido hidratante, 250 ml', preco: 6.99, quantidade: 50, categoria: 'Higiene e Limpeza'),
      Produto(nome: 'Detergente Neutro', descricao: 'Detergente neutro, frasco 500 ml', preco: 2.99, quantidade: 75, categoria: 'Higiene e Limpeza'),
      Produto(nome: 'Shampoo Anticaspa', descricao: 'Shampoo anticaspa, frasco 400 ml', preco: 15.90, quantidade: 30, categoria: 'Higiene e Limpeza'),
      Produto(nome: 'Papel Higiênico', descricao: 'Papel higiênico folha dupla, pacote 12 un', preco: 18.90, quantidade: 40, categoria: 'Higiene e Limpeza'),

      // Congelados
      Produto(nome: 'Pizza Margherita', descricao: 'Pizza margherita congelada, 460 g', preco: 19.90, quantidade: 25, categoria: 'Congelados'),
      Produto(nome: 'Lasanha à Bolonhesa', descricao: 'Lasanha à bolonhesa congelada, 600 g', preco: 17.50, quantidade: 20, categoria: 'Congelados'),
      Produto(nome: 'Nuggets de Frango', descricao: 'Nuggets de frango congelados, 300 g', preco: 12.90, quantidade: 35, categoria: 'Congelados'),
      Produto(nome: 'Sorvete de Creme', descricao: 'Sorvete de creme, pote 1,5 L', preco: 22.90, quantidade: 18, categoria: 'Congelados'),

      // Outros
      Produto(nome: 'Sacola Retornável', descricao: 'Sacola reutilizável ecológica', preco: 3.99, quantidade: 100, categoria: 'Outros'),
      Produto(nome: 'Pilha AA', descricao: 'Pilha AA alcalina, cartela com 4 un', preco: 12.90, quantidade: 40, categoria: 'Outros'),
      Produto(nome: 'Vela de Emergência', descricao: 'Vela de parafina 8 horas, pacote 12 un', preco: 5.99, quantidade: 30, categoria: 'Outros'),
    ];

    final batch = _db.batch();
    for (final p in produtos) {
      batch.set(_colecao.doc(), p.toMap());
    }
    await batch.commit();
  }
}
