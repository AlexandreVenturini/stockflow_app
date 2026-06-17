import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../models/categoria.dart';
import '../services/produto_service.dart';

class RelatorioScreen extends StatelessWidget {
  const RelatorioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      body: StreamBuilder<List<Produto>>(
        stream: ProdutoService().listar(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final produtos = snapshot.data ?? [];

          final totalProdutos = produtos.length;
          final totalItens =
              produtos.fold(0, (soma, p) => soma + p.quantidade);
          final valorTotal = produtos.fold(
              0.0, (soma, p) => soma + p.preco * p.quantidade);
          final semEstoque =
              produtos.where((p) => p.quantidade == 0).length;
          final estoqueAbaixo =
              produtos.where((p) => p.quantidade > 0 && p.quantidade <= 15).length;

          // Valor por categoria
          final Map<String, double> valorPorCategoria = {};
          final Map<String, int> itensPorCategoria = {};
          for (final p in produtos) {
            valorPorCategoria[p.categoria] =
                (valorPorCategoria[p.categoria] ?? 0) +
                    p.preco * p.quantidade;
            itensPorCategoria[p.categoria] =
                (itensPorCategoria[p.categoria] ?? 0) + p.quantidade;
          }

          final categoriasOrdenadas = valorPorCategoria.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 130,
                pinned: true,
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
                  title: const Text(
                    'Relatório de Estoque',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                      ),
                    ),
                    child: Stack(children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cards principais
                      Row(
                        children: [
                          Expanded(
                            child: _CardResumo(
                              icone: Icons.inventory_2_outlined,
                              titulo: 'Produtos',
                              valor: '$totalProdutos',
                              subtitulo: 'cadastrados',
                              cor: const Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CardResumo(
                              icone: Icons.layers_outlined,
                              titulo: 'Itens',
                              valor: '$totalItens',
                              subtitulo: 'em estoque',
                              cor: const Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _CardValorTotal(valor: valorTotal),
                      const SizedBox(height: 12),

                      // Alertas
                      if (semEstoque > 0 || estoqueAbaixo > 0)
                        _CardAlertas(
                            semEstoque: semEstoque,
                            estoqueAbaixo: estoqueAbaixo),

                      if (semEstoque > 0 || estoqueAbaixo > 0)
                        const SizedBox(height: 12),

                      // Por categoria
                      if (categoriasOrdenadas.isNotEmpty) ...[
                        const _SecaoTitulo('Valor por categoria'),
                        const SizedBox(height: 8),
                        ...categoriasOrdenadas.map((entry) {
                          final cat = categoriaByNome(entry.key);
                          final itens = itensPorCategoria[entry.key] ?? 0;
                          final percentual = valorTotal > 0
                              ? entry.value / valorTotal
                              : 0.0;
                          return _CardCategoria(
                            categoria: cat,
                            valor: entry.value,
                            itens: itens,
                            percentual: percentual,
                          );
                        }),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SecaoTitulo extends StatelessWidget {
  final String texto;
  const _SecaoTitulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2E7D32),
        letterSpacing: 1,
      ),
    );
  }
}

class _CardResumo extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;
  final String subtitulo;
  final Color cor;

  const _CardResumo({
    required this.icone,
    required this.titulo,
    required this.valor,
    required this.subtitulo,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icone, color: cor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(valor,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: cor)),
          Text(subtitulo,
              style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          Text(titulo,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _CardValorTotal extends StatelessWidget {
  final double valor;
  const _CardValorTotal({required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Valor total do estoque',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              Text(
                'R\$ ${valor.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardAlertas extends StatelessWidget {
  final int semEstoque;
  final int estoqueAbaixo;

  const _CardAlertas(
      {required this.semEstoque, required this.estoqueAbaixo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_rounded,
                  color: Colors.red.shade700, size: 18),
              const SizedBox(width: 6),
              Text('Alertas de estoque',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.red.shade700,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          if (semEstoque > 0)
            _LinhaAlerta(
              cor: Colors.red.shade700,
              texto:
                  '$semEstoque produto${semEstoque > 1 ? 's' : ''} sem estoque',
            ),
          if (estoqueAbaixo > 0)
            _LinhaAlerta(
              cor: Colors.orange.shade700,
              texto:
                  '$estoqueAbaixo produto${estoqueAbaixo > 1 ? 's' : ''} com estoque baixo (≤ 15 un)',
            ),
        ],
      ),
    );
  }
}

class _LinhaAlerta extends StatelessWidget {
  final Color cor;
  final String texto;
  const _LinhaAlerta({required this.cor, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 8),
            decoration:
                BoxDecoration(color: cor, shape: BoxShape.circle),
          ),
          Text(texto,
              style: TextStyle(fontSize: 12, color: cor)),
        ],
      ),
    );
  }
}

class _CardCategoria extends StatelessWidget {
  final Categoria categoria;
  final double valor;
  final int itens;
  final double percentual;

  const _CardCategoria({
    required this.categoria,
    required this.valor,
    required this.itens,
    required this.percentual,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: categoria.cor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(categoria.icone,
                    color: categoria.cor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(categoria.nome,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF1A1A1A))),
                    Text('$itens itens',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Text(
                'R\$ ${valor.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF2E7D32)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentual,
              minHeight: 5,
              backgroundColor: Colors.grey.shade100,
              valueColor:
                  AlwaysStoppedAnimation<Color>(categoria.cor),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(percentual * 100).toStringAsFixed(1)}% do total',
              style: TextStyle(
                  fontSize: 10, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }
}
