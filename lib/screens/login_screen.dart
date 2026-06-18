import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../widgets/captcha_widget.dart';

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
  bool _captchaOk = false;

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
    if (!_captchaOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Complete a verificação de segurança.'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
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
        SnackBar(
          content: Text(_traduzirErro(e.toString())),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
      backgroundColor: const Color(0xFF1B5E20),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header verde com logo
            SizedBox(
              height: 280,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Círculos decorativos
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.storefront,
                            size: 52, color: Color(0xFF2E7D32)),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'StockFlow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Text(
                        'Gestão de Estoque',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Card do formulário
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 280,
              ),
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Bem-vindo de volta!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Entre para acessar o estoque',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF2E7D32)),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Informe o e-mail' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: !_verSenha,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2E7D32)),
                        suffixIcon: IconButton(
                          icon: Icon(_verSenha ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey),
                          onPressed: () => setState(() => _verSenha = !_verSenha),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe a senha' : null,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Checkbox(
                          value: _lembrarEmail,
                          activeColor: const Color(0xFF2E7D32),
                          onChanged: (v) => setState(() => _lembrarEmail = v ?? false),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _lembrarEmail = !_lembrarEmail),
                          child: const Text('Lembrar e-mail',
                              style: TextStyle(fontSize: 14)),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/forgot'),
                          child: const Text('Esqueci a senha',
                              style: TextStyle(color: Color(0xFF2E7D32), fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CaptchaWidget(
                      onValidated: (ok) => setState(() => _captchaOk = ok),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _carregando ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _carregando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Entrar',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Não tem conta? ',
                            style: TextStyle(color: Colors.grey)),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/register'),
                          child: const Text('Criar conta',
                              style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
