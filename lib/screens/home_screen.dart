import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../models/categoria.dart';
import '../services/auth_service.dart';
import '../services/produto_service.dart';
import 'produto_form_screen.dart';
import 'produto_detalhe_screen.dart';
import 'relatorio_screen.dart';

enum _Ordenacao { nome, preco, quantidade }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _categoriaFiltro;
  String _busca = '';
  _Ordenacao _ordenacao = _Ordenacao.nome;
  bool _buscaAberta = false;
  final _buscaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    ProdutoService().popularSeVazio();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  List<Produto> _filtrarEOrdenar(List<Produto> produtos) {
    var lista = produtos;

    if (_busca.isNotEmpty) {
      final termo = _busca.toLowerCase();
      lista = lista
          .where((p) => p.nome.toLowerCase().contains(termo))
          .toList();
    }

    switch (_ordenacao) {
      case _Ordenacao.nome:
        lista.sort((a, b) => a.nome.compareTo(b.nome));
        break;
      case _Ordenacao.preco:
        lista.sort((a, b) => a.preco.compareTo(b.preco));
        break;
      case _Ordenacao.quantidade:
        lista.sort((a, b) => a.quantidade.compareTo(b.quantidade));
        break;
    }

    return lista;
  }

  Future<void> _confirmarExclusao(Produto produto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Excluir produto'),
          ],
        ),
        content: Text('Deseja excluir "${produto.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await ProdutoService().excluir(produto.id!);
    }
  }

  void _abrirOrdenacao() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Ordenar por',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1B5E20))),
            const SizedBox(height: 8),
            ..._Ordenacao.values.map((o) {
              final labels = {
                _Ordenacao.nome: ('Nome (A-Z)', Icons.sort_by_alpha),
                _Ordenacao.preco: ('Menor preço', Icons.attach_money),
                _Ordenacao.quantidade: ('Menor estoque', Icons.inventory_2_outlined),
              };
              final (label, icone) = labels[o]!;
              return ListTile(
                leading: Icon(icone,
                    color: _ordenacao == o
                        ? const Color(0xFF2E7D32)
                        : Colors.grey),
                title: Text(label),
                trailing: _ordenacao == o
                    ? const Icon(Icons.check, color: Color(0xFF2E7D32))
                    : null,
                onTap: () {
                  setState(() => _ordenacao = o);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart_outlined),
                tooltip: 'Relatório',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RelatorioScreen()),
                ),
              ),
              IconButton(
                icon: Icon(_buscaAberta ? Icons.search_off : Icons.search),
                tooltip: 'Buscar',
                onPressed: () {
                  setState(() {
                    _buscaAberta = !_buscaAberta;
                    if (!_buscaAberta) {
                      _busca = '';
                      _buscaCtrl.clear();
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.sort),
                tooltip: 'Ordenar',
                onPressed: _abrirOrdenacao,
              ),
              IconButton(
                icon: const Icon(Icons.logout_outlined),
                tooltip: 'Sair',
                onPressed: () async {
                  await AuthService().logout();
                  if (!mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 0, 14),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Icons.storefront, size: 20, color: Colors.white),
                  const SizedBox(width: 6),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'StockFlow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      Text(
                        _categoriaFiltro ?? 'Todos os produtos',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                  ),
                ),
                child: Stack(
                  children: [
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
                  ],
                ),
              ),
            ),
          ),

          // Campo de busca
          if (_buscaAberta)
            SliverToBoxAdapter(
              child: Container(
                color: const Color(0xFF2E7D32),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _buscaCtrl,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar produto...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _busca.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: Colors.white70),
                            onPressed: () =>
                                setState(() {
                                  _busca = '';
                                  _buscaCtrl.clear();
                                }),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (v) => setState(() => _busca = v),
                ),
              ),
            ),

          // Filtros de categoria
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF2E7D32),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F8F1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          const Text(
                            'Categorias',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFF2E7D32),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          // Badge de ordenação ativa
                          if (_ordenacao != _Ordenacao.nome)
                            GestureDetector(
                              onTap: _abrirOrdenacao,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.sort,
                                        size: 12,
                                        color: Color(0xFF2E7D32)),
                                    const SizedBox(width: 4),
                                    Text(
                                      _ordenacao == _Ordenacao.preco
                                          ? 'Preço'
                                          : 'Estoque',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF2E7D32),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          _FiltroChip(
                            label: 'Todos',
                            icone: Icons.apps,
                            cor: const Color(0xFF2E7D32),
                            selecionado: _categoriaFiltro == null,
                            onTap: () =>
                                setState(() => _categoriaFiltro = null),
                          ),
                          ...categorias.map((cat) => _FiltroChip(
                                label: cat.nome,
                                icone: cat.icone,
                                cor: cat.cor,
                                selecionado:
                                    _categoriaFiltro == cat.nome,
                                onTap: () => setState(
                                    () => _categoriaFiltro = cat.nome),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),

          // Lista de produtos
          StreamBuilder<List<Produto>>(
            stream:
                ProdutoService().listar(categoria: _categoriaFiltro),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                      child: Text('Erro: ${snapshot.error}')),
                );
              }

              final todos = snapshot.data ?? [];
              final semEstoque =
                  todos.where((p) => p.quantidade == 0).toList();
              final produtos = _filtrarEOrdenar(todos);

              if (todos.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 72, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          _categoriaFiltro == null
                              ? 'Nenhum produto cadastrado.\nToque em + para adicionar.'
                              : 'Nenhum produto em\n"$_categoriaFiltro".',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(12, 0, 12, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Banner de alerta de estoque zerado (primeiro item)
                      if (index == 0 &&
                          semEstoque.isNotEmpty &&
                          _busca.isEmpty) {
                        return Column(
                          children: [
                            _AlertaEstoqueZerado(
                                produtos: semEstoque),
                            const SizedBox(height: 8),
                            if (produtos.isNotEmpty)
                              _buildCard(context, produtos[0]),
                          ],
                        );
                      }

                      final itemIndex =
                          semEstoque.isNotEmpty && _busca.isEmpty
                              ? index - 1
                              : index;

                      if (itemIndex < 0 ||
                          itemIndex >= produtos.length) {
                        return const SizedBox.shrink();
                      }

                      return _buildCard(
                          context, produtos[itemIndex]);
                    },
                    childCount: produtos.isEmpty
                        ? 0
                        : produtos.length +
                            (semEstoque.isNotEmpty && _busca.isEmpty
                                ? 1
                                : 0),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final cat = await Navigator.push<String>(
            context,
            MaterialPageRoute(
                builder: (_) => const ProdutoFormScreen()),
          );
          if (cat != null) setState(() => _categoriaFiltro = cat);
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo produto',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFFF57F17),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCard(BuildContext context, Produto p) {
    final cat = categoriaByNome(p.categoria);
    return _ProdutoCard(
      produto: p,
      categoria: cat,
      onTap: () async {
        final resultado = await Navigator.push<String>(
          context,
          MaterialPageRoute(
              builder: (_) => ProdutoDetalheScreen(produto: p)),
        );
        if (resultado != null) {
          setState(() => _categoriaFiltro = resultado);
        }
      },
      onEditar: () async {
        final c = await Navigator.push<String>(
          context,
          MaterialPageRoute(
              builder: (_) => ProdutoFormScreen(produto: p)),
        );
        if (c != null) setState(() => _categoriaFiltro = c);
      },
      onExcluir: () => _confirmarExclusao(p),
    );
  }
}

class _AlertaEstoqueZerado extends StatelessWidget {
  final List<Produto> produtos;

  const _AlertaEstoqueZerado({required this.produtos});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded,
              color: Colors.red.shade700, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${produtos.length} produto${produtos.length > 1 ? 's' : ''} sem estoque',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  produtos.map((p) => p.nome).join(', '),
                  style: TextStyle(
                      fontSize: 11, color: Colors.red.shade400),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final IconData icone;
  final Color cor;
  final bool selecionado;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.icone,
    required this.cor,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selecionado ? cor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selecionado ? cor : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: selecionado
                ? [
                    BoxShadow(
                        color: cor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone,
                  size: 14,
                  color: selecionado ? Colors.white : cor),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selecionado
                      ? Colors.white
                      : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProdutoCard extends StatelessWidget {
  final Produto produto;
  final Categoria categoria;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _ProdutoCard({
    required this.produto,
    required this.categoria,
    required this.onTap,
    required this.onEditar,
    required this.onExcluir,
  });

  Color get _estoqueColor {
    if (produto.quantidade == 0) return Colors.red.shade700;
    if (produto.quantidade <= 5) return Colors.red.shade600;
    if (produto.quantidade <= 15) return Colors.orange.shade700;
    return const Color(0xFF2E7D32);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Faixa colorida
            Container(
              width: 6,
              height: 80,
              decoration: BoxDecoration(
                color: produto.quantidade == 0
                    ? Colors.red.shade400
                    : categoria.cor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            // Ícone
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: categoria.cor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(categoria.icone,
                    color: categoria.cor, size: 24),
              ),
            ),
            // Conteúdo
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (produto.descricao.isNotEmpty)
                      Text(
                        produto.descricao,
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'R\$ ${produto.preco.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          produto.quantidade == 0
                              ? Icons.warning_rounded
                              : Icons.inventory_2_outlined,
                          size: 12,
                          color: _estoqueColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          produto.quantidade == 0
                              ? 'Sem estoque'
                              : '${produto.quantidade} un',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _estoqueColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Ações
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: Color(0xFF1565C0), size: 20),
                  tooltip: 'Editar',
                  onPressed: onEditar,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Colors.red.shade400, size: 20),
                  tooltip: 'Excluir',
                  onPressed: onExcluir,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
