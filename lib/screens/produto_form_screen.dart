import 'package:flutter/material.dart';
import '../models/produto.dart';
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
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    if (widget.produto != null) {
      _nomeCtrl.text = widget.produto!.nome;
      _descricaoCtrl.text = widget.produto!.descricao;
      _precoCtrl.text = widget.produto!.preco.toStringAsFixed(2);
      _quantidadeCtrl.text = widget.produto!.quantidade.toString();
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
      );
      if (widget.produto == null) {
        await ProdutoService().adicionar(produto);
      } else {
        await ProdutoService().atualizar(produto);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.produto != null;
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
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoCtrl,
                decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precoCtrl,
                decoration: const InputDecoration(labelText: 'Preço (R\$)', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o preço';
                  if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Preço inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantidadeCtrl,
                decoration: const InputDecoration(labelText: 'Quantidade', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a quantidade';
                  if (int.tryParse(v) == null) return 'Quantidade inválida';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const CircularProgressIndicator()
                      : Text(editando ? 'Salvar Alterações' : 'Adicionar Produto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
