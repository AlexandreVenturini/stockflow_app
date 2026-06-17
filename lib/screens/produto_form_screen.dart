import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../models/categoria.dart';
import '../services/produto_service.dart';

class ProdutoFormScreen extends StatefulWidget {
  final Produto? produto;
  const ProdutoFormScreen({super.key, this.produto});

  @override
  State<ProdutoFormScreen> createState() => _ProdutoFormScreenState();
}

class _ProdutoFormScreenState extends State<ProdutoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _precoCtrl = TextEditingController();
  final _quantidadeCtrl = TextEditingController();
  String _categoriaSelecionada = categorias.first.nome;

  @override
  void initState() {
    super.initState();
    if (widget.produto != null) {
      _nomeCtrl.text = widget.produto!.nome;
      _descricaoCtrl.text = widget.produto!.descricao;
      _precoCtrl.text = widget.produto!.preco.toStringAsFixed(2);
      _quantidadeCtrl.text = widget.produto!.quantidade.toString();
      _categoriaSelecionada = widget.produto!.categoria;
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descricaoCtrl.dispose();
    _precoCtrl.dispose();
    _quantidadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final produto = Produto(
        id: widget.produto?.id,
        nome: _nomeCtrl.text.trim(),
        descricao: _descricaoCtrl.text.trim(),
        preco: double.parse(_precoCtrl.text.replaceAll(',', '.')),
        quantidade: int.parse(_quantidadeCtrl.text),
        categoria: _categoriaSelecionada,
      );
      if (widget.produto == null) {
        ProdutoService().adicionar(produto);
      } else {
        ProdutoService().atualizar(produto);
      }
      if (!mounted) return;
      Navigator.pop(context, _categoriaSelecionada);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.produto != null;
    final catAtual = categoriaByNome(_categoriaSelecionada);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
              title: Text(
                editando ? 'Editar Produto' : 'Novo Produto',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
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
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seletor de categoria
                    _Secao(
                      titulo: 'Categoria',
                      child: SizedBox(
                        height: 88,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categorias.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final cat = categorias[i];
                            final sel = cat.nome == _categoriaSelecionada;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _categoriaSelecionada = cat.nome),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 72,
                                decoration: BoxDecoration(
                                  color: sel ? cat.cor : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: sel ? cat.cor : Colors.grey.shade200,
                                    width: 2,
                                  ),
                                  boxShadow: sel
                                      ? [
                                          BoxShadow(
                                            color: cat.cor.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(cat.icone,
                                        color: sel ? Colors.white : cat.cor,
                                        size: 26),
                                    const SizedBox(height: 5),
                                    Text(
                                      cat.nome,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w700,
                                        color: sel ? Colors.white : cat.cor,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Badge categoria selecionada
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: catAtual.cor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: catAtual.cor.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(catAtual.icone,
                              size: 14, color: catAtual.cor),
                          const SizedBox(width: 6),
                          Text(
                            catAtual.nome,
                            style: TextStyle(
                              color: catAtual.cor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dados do produto
                    _Secao(
                      titulo: 'Informações do produto',
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nomeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nome do produto',
                              prefixIcon: Icon(Icons.label_outline,
                                  color: Color(0xFF2E7D32)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Informe o nome'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descricaoCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Descrição',
                              prefixIcon: Icon(Icons.notes,
                                  color: Color(0xFF2E7D32)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Preço e quantidade
                    _Secao(
                      titulo: 'Preço e estoque',
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _precoCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Preço (R\$)',
                                prefixIcon: Icon(Icons.attach_money,
                                    color: Color(0xFF2E7D32)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Informe o preço';
                                if (double.tryParse(v.replaceAll(',', '.')) == null)
                                  return 'Inválido';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _quantidadeCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Quantidade',
                                prefixIcon: Icon(Icons.inventory_2_outlined,
                                    color: Color(0xFF2E7D32)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Informe a qtd';
                                if (int.tryParse(v) == null) return 'Inválido';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botão salvar
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _salvar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        icon: Icon(
                            editando ? Icons.check_circle_outline : Icons.add_circle_outline,
                            size: 22),
                        label: Text(
                          editando ? 'Salvar Alterações' : 'Adicionar Produto',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  final String titulo;
  final Widget child;
  const _Secao({required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E7D32),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
