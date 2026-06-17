class Produto {
  final String? id;
  final String nome;
  final String descricao;
  final double preco;
  final int quantidade;

  Produto({
    this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.quantidade,
  });

  factory Produto.fromMap(Map<String, dynamic> map, String id) {
    return Produto(
      id: id,
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      preco: (map['preco'] ?? 0).toDouble(),
      quantidade: map['quantidade'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'quantidade': quantidade,
    };
  }
}
