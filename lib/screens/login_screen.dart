import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _verSenha = false;
  bool _lembrarEmail = false;
  bool _carregando = false;

  static const _keyEmail = 'lembrar_email';
  static const _keyLembrar = 'lembrar_ativo';

  @override
  void initState() {
    super.initState();
    _carregarEmailSalvo();
  }

  Future<void> _carregarEmailSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    final lembrar = prefs.getBool(_keyLembrar) ?? false;
    if (lembrar) {
      final email = prefs.getString(_keyEmail) ?? '';
      setState(() {
        _lembrarEmail = true;
        _emailController.text = email;
      });
    }
  }

  Future<void> _salvarPreferencia() async {
    final prefs = await SharedPreferences.getInstance();
    if (_lembrarEmail) {
      await prefs.setBool(_keyLembrar, true);
      await prefs.setString(_keyEmail, _emailController.text.trim());
    } else {
      await prefs.setBool(_keyLembrar, false);
      await prefs.remove(_keyEmail);
    }
  }

  String _traduzirErro(String erro) {
    if (erro.contains('user-not-found')) return 'Nenhuma conta encontrada com este e-mail.';
    if (erro.contains('wrong-password') || erro.contains('invalid-credential')) return 'E-mail ou senha incorretos.';
    if (erro.contains('invalid-email')) return 'E-mail inválido.';
    if (erro.contains('user-disabled')) return 'Esta conta foi desativada.';
    if (erro.contains('too-many-requests')) return 'Muitas tentativas. Aguarde um momento.';
    if (erro.contains('network-request-failed')) return 'Sem conexão com a internet.';
    return 'Erro ao entrar. Tente novamente.';
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      await _salvarPreferencia();
      await AuthService().login(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_traduzirErro(e.toString()))),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaController,
                obscureText: !_verSenha,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: _verSenha ? 'Ocultar senha' : 'Ver senha',
                    icon: Icon(
                        _verSenha ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _verSenha = !_verSenha),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a senha';
                  return null;
                },
              ),
              const SizedBox(height: 4),
              // Checkbox "Lembrar e-mail"
              Row(
                children: [
                  Checkbox(
                    value: _lembrarEmail,
                    onChanged: (v) => setState(() => _lembrarEmail = v ?? false),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _lembrarEmail = !_lembrarEmail),
                    child: const Text('Lembrar e-mail'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _carregando ? null : _login,
                  icon: _carregando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.login),
                  label: Text(_carregando ? 'Entrando...' : 'Entrar'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Criar conta'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/forgot'),
                child: const Text('Esqueci minha senha'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
