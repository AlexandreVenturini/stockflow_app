import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../models/categoria.dart';
import 'produto_form_screen.dart';

class ProdutoDetalheScreen extends StatelessWidget {
  final Produto produto;

  const ProdutoDetalheScreen({super.key, required this.produto});

  Color get _estoqueColor {
    if (produto.quantidade == 0) return Colors.red.shade700;
    if (produto.quantidade <= 5) return Colors.red.shade600;
    if (produto.quantidade <= 15) return Colors.orange.shade700;
    return const Color(0xFF2E7D32);
  }

  String get _estoqueLabel {
    if (produto.quantidade == 0) return 'Sem estoque';
    if (produto.quantidade <= 5) return 'Estoque crítico';
    if (produto.quantidade <= 15) return 'Estoque baixo';
    return 'Em estoque';
  }

  @override
  Widget build(BuildContext context) {
    final cat = categoriaByNome(produto.categoria);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: cat.cor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Editar',
                onPressed: () async {
                  final resultado = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProdutoFormScreen(produto: produto)),
                  );
                  if (resultado != null && context.mounted) {
                    Navigator.pop(context, resultado);
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
              title: Text(
                produto.nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cat.cor.withOpacity(0.8),
                      cat.cor,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(cat.icone,
                                size: 40, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoria badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cat.cor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cat.cor.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icone, size: 14, color: cat.cor),
                        const SizedBox(width: 6),
                        Text(
                          cat.nome,
                          style: TextStyle(
                            color: cat.cor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nome e descrição
                  Text(
                    produto.nome,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  if (produto.descricao.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      produto.descricao,
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Cards de info
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icone: Icons.attach_money,
                          titulo: 'Preço',
                          valor:
                              'R\$ ${produto.preco.toStringAsFixed(2)}',
                          cor: const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icone: Icons.inventory_2_outlined,
                          titulo: 'Quantidade',
                          valor: '${produto.quantidade} un',
                          cor: _estoqueColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Status do estoque
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _estoqueColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: _estoqueColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          produto.quantidade == 0
                              ? Icons.warning_rounded
                              : produto.quantidade <= 15
                                  ? Icons.warning_amber_rounded
                                  : Icons.check_circle_outline,
                          color: _estoqueColor,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _estoqueLabel,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _estoqueColor,
                                fontSize: 14,
                              ),
                            ),
                            if (produto.quantidade == 0)
                              Text(
                                'Produto indisponível para venda',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _estoqueColor.withOpacity(0.8)),
                              )
                            else if (produto.quantidade <= 5)
                              Text(
                                'Repor estoque com urgência',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _estoqueColor.withOpacity(0.8)),
                              )
                            else if (produto.quantidade <= 15)
                              Text(
                                'Considere repor em breve',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _estoqueColor.withOpacity(0.8)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botão editar
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final resultado = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ProdutoFormScreen(produto: produto)),
                        );
                        if (resultado != null && context.mounted) {
                          Navigator.pop(context, resultado);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label: const Text('Editar produto',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;
  final Color cor;

  const _InfoCard({
    required this.icone,
    required this.titulo,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: cor, size: 20),
          const SizedBox(height: 8),
          Text(titulo,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(valor,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: cor)),
        ],
      ),
    );
  }
}
