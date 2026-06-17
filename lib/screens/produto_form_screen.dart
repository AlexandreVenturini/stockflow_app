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
  bool _salvando = false;

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
    setState(() => _salvando = true);
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
        await ProdutoService().adicionar(produto);
      } else {
        await ProdutoService().atualizar(produto);
      }
      Navigator.pop(context);
    } catch (e) {
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.produto != null;
    final catAtual = categoriaByNome(_categoriaSelecionada);

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar Produto' : 'Novo Produto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Seletor de categoria visual
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categorias.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = categorias[i];
                    final selecionado = cat.nome == _categoriaSelecionada;
                    return GestureDetector(
                      onTap: () => setState(() => _categoriaSelecionada = cat.nome),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 75,
                        decoration: BoxDecoration(
                          color: selecionado ? cat.cor : cat.cor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: selecionado
                              ? Border.all(color: cat.cor, width: 2)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(cat.icone,
                                color: selecionado ? Colors.white : cat.cor,
                                size: 28),
                            const SizedBox(height: 4),
                            Text(
                              cat.nome,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: selecionado ? Colors.white : cat.cor,
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
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: Icon(catAtual.icone, color: Colors.white, size: 16),
                  label: Text(catAtual.nome,
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                  backgroundColor: catAtual.cor,
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nome do produto', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoCtrl,
                decoration: const InputDecoration(
                    labelText: 'Descrição', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precoCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Preço (R\$)', border: OutlineInputBorder()),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
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
                          labelText: 'Quantidade', border: OutlineInputBorder()),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: _salvando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(editando ? 'Salvar Alterações' : 'Adicionar Produto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
