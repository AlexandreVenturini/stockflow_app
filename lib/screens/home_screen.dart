import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../models/categoria.dart';
import '../services/auth_service.dart';
import '../services/produto_service.dart';
import 'produto_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _categoriaFiltro; // null = todas

  @override
  void initState() {
    super.initState();
    ProdutoService().popularSeVazio();
  }

  Future<void> _confirmarExclusao(BuildContext context, Produto produto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir produto'),
        content: Text('Deseja excluir "${produto.nome}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await ProdutoService().excluir(produto.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StockFlow — Supermercado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chips de filtro por categoria
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                // Chip "Todos"
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: const Text('Todos'),
                    selected: _categoriaFiltro == null,
                    onSelected: (_) => setState(() => _categoriaFiltro = null),
                  ),
                ),
                ...categorias.map((cat) {
                  final selecionado = _categoriaFiltro == cat.nome;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      avatar: Icon(cat.icone,
                          size: 16,
                          color: selecionado ? Colors.white : cat.cor),
                      label: Text(cat.nome),
                      selected: selecionado,
                      selectedColor: cat.cor,
                      labelStyle: TextStyle(
                          color: selecionado ? Colors.white : null,
                          fontSize: 12),
                      onSelected: (_) =>
                          setState(() => _categoriaFiltro = cat.nome),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),
          // Lista de produtos
          Expanded(
            child: StreamBuilder<List<Produto>>(
              stream: ProdutoService().listar(categoria: _categoriaFiltro),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                final produtos = snapshot.data ?? [];
                if (produtos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          _categoriaFiltro == null
                              ? 'Nenhum produto cadastrado.\nToque em + para adicionar.'
                              : 'Nenhum produto em "$_categoriaFiltro".',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: produtos.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = produtos[index];
                    final cat = categoriaByNome(p.categoria);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cat.cor.withOpacity(0.2),
                        child: Icon(cat.icone, color: cat.cor, size: 22),
                      ),
                      title: Text(p.nome,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (p.descricao.isNotEmpty)
                            Text(p.descricao,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Chip(
                                label: Text(p.categoria,
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.white)),
                                backgroundColor: cat.cor,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              const SizedBox(width: 6),
                              Text('Qtd: ${p.quantidade}',
                                  style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'R\$ ${p.preco.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blue, size: 20),
                            tooltip: 'Editar',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ProdutoFormScreen(produto: p)),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 20),
                            tooltip: 'Excluir',
                            onPressed: () =>
                                _confirmarExclusao(context, p),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo produto',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProdutoFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
