import 'dart:math';
import 'package:flutter/material.dart';

class CaptchaWidget extends StatefulWidget {
  final ValueChanged<bool> onValidated;

  const CaptchaWidget({super.key, required this.onValidated});

  @override
  State<CaptchaWidget> createState() => CaptchaWidgetState();
}

class CaptchaWidgetState extends State<CaptchaWidget> {
  final _controller = TextEditingController();
  late int _a, _b, _resposta;
  String? _erro;
  bool _validado = false;

  @override
  void initState() {
    super.initState();
    _gerarPergunta(notificar: false);
  }

  void _gerarPergunta({bool notificar = false}) {
    final rand = Random();
    _a = rand.nextInt(9) + 1;
    _b = rand.nextInt(9) + 1;
    _resposta = _a + _b;
    _controller.clear();
    _erro = null;
    _validado = false;
    if (notificar) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onValidated(false);
      });
    }
  }

  void validar() {
    final digitado = int.tryParse(_controller.text.trim());
    if (digitado == null) {
      setState(() => _erro = 'Digite um número');
      widget.onValidated(false);
      return;
    }
    if (digitado == _resposta) {
      setState(() {
        _erro = null;
        _validado = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onValidated(true);
      });
    } else {
      setState(() => _gerarPergunta());
      setState(() => _erro = 'Resposta incorreta');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onValidated(false);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(
          color: _validado
              ? const Color(0xFF2E7D32)
              : _erro != null
                  ? Colors.red.shade400
                  : Colors.grey.shade300,
          width: _validado ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: _validado ? const Color(0xFFE8F5E9) : Colors.grey.shade50,
      ),
      child: _validado
          ? const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 22),
                SizedBox(width: 10),
                Text(
                  'Verificação concluída',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        color: Color(0xFF2E7D32), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Verificação de segurança',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_a + $_b = ?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          hintText: '?',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Color(0xFF2E7D32), width: 2),
                          ),
                          errorText: _erro,
                        ),
                        onSubmitted: (_) => validar(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() => _gerarPergunta(notificar: true));
                      },
                      icon: const Icon(Icons.refresh,
                          color: Color(0xFF2E7D32), size: 22),
                      tooltip: 'Nova pergunta',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: validar,
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Verificar',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
    );
  }
}
