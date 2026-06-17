import 'package:flutter/material.dart';

class Categoria {
  final String nome;
  final IconData icone;
  final Color cor;

  const Categoria({required this.nome, required this.icone, required this.cor});
}

const List<Categoria> categorias = [
  Categoria(nome: 'Frutas e Verduras', icone: Icons.eco, cor: Color(0xFF4CAF50)),
  Categoria(nome: 'Carnes e Peixes',   icone: Icons.set_meal, cor: Color(0xFFF44336)),
  Categoria(nome: 'Laticínios',        icone: Icons.egg_alt, cor: Color(0xFFFFF9C4)),
  Categoria(nome: 'Padaria',           icone: Icons.bakery_dining, cor: Color(0xFFFF9800)),
  Categoria(nome: 'Bebidas',           icone: Icons.local_drink, cor: Color(0xFF2196F3)),
  Categoria(nome: 'Mercearia',         icone: Icons.rice_bowl, cor: Color(0xFF795548)),
  Categoria(nome: 'Higiene e Limpeza', icone: Icons.clean_hands, cor: Color(0xFF00BCD4)),
  Categoria(nome: 'Congelados',        icone: Icons.ac_unit, cor: Color(0xFF90CAF9)),
  Categoria(nome: 'Outros',            icone: Icons.category, cor: Color(0xFF9E9E9E)),
];

Categoria categoriaByNome(String nome) {
  return categorias.firstWhere(
    (c) => c.nome == nome,
    orElse: () => categorias.last,
  );
}
