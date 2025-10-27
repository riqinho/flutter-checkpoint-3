import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// ------------------ MODEL ------------------
class Password {
  final String password;
  Password({required this.password});

  factory Password.fromJson(Map<String, dynamic> json) =>
      Password(password: json['password'] as String);
}

// ------------------ SERVICE ------------------
class ApiService {
  // sem barra no final
  static const String _baseUrl =
      'https://safekey-api-a1bd9aa97953.herokuapp.com';

  /// Gera a senha conforme as opções (POST /generate com JSON)
  static Future<Password> generatePassword({
    required int length,
    required bool includeLowercase,
    required bool includeUppercase,
    required bool includeNumbers,
    required bool includeSymbols,
  }) async {
    final uri = Uri.parse('$_baseUrl/generate');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'length': length,
        'includeLowercase': includeLowercase,
        'includeUppercase': includeUppercase,
        'includeNumbers': includeNumbers,
        'includeSymbols': includeSymbols,
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('Erro ${resp.statusCode}: ${resp.body}');
    }

    final data = json.decode(resp.body) as Map<String, dynamic>;
    return Password.fromJson(data);
  }
}

// ------------------ UI ------------------
class NewpasswordScreen extends StatefulWidget {
  const NewpasswordScreen({super.key});

  @override
  State<NewpasswordScreen> createState() => _NewpasswordScreenState();
}

class _NewpasswordScreenState extends State<NewpasswordScreen> {
  String? _password;
  double _length = 12;
  bool _lower = true;
  bool _upper = true;
  bool _numbers = true;
  bool _symbols = false;
  bool _expanded = true;
  bool _loading = false;

  bool get _hasAnyCategory => _lower || _upper || _numbers || _symbols;

  Future<void> _generatePassword() async {
    if (!_hasAnyCategory) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione ao menos um tipo de caractere.'),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await ApiService.generatePassword(
        length: _length.round(),
        includeLowercase: _lower,
        includeUppercase: _upper,
        includeNumbers: _numbers,
        includeSymbols: _symbols,
      );
      setState(() => _password = res.password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha gerada com sucesso')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Falha ao gerar senha: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _copyPassword() {
    final p = _password;
    if (p == null) return;
    Clipboard.setData(ClipboardData(text: p));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Senha copiada!')));
  }

  Future<void> _savePassword() async {
    if (_password == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gere uma senha antes de salvar.')),
      );
      return;
    }

    // pega o título no modal
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final c = TextEditingController();
        return AlertDialog(
          title: const Text('Salvar senha'),
          content: TextField(
            controller: c,
            decoration: const InputDecoration(
              labelText: 'Título',
              hintText: 'Ex.: Email do trabalho',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (title == null || title.isEmpty) return;

    try {
      // 👇 exatamente a sua coleção simples: passwords (doc com fields title/password)
      await FirebaseFirestore.instance.collection('passwords').add({
        'title': title,
        'password': _password,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Senha salva!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  void _toggleExpanded() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerador de Senhas'),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // senha gerada
            Card(
              elevation: 2,
              child: ListTile(
                title: Text(
                  _password ?? 'Senha não informada',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copiar senha',
                  onPressed: _password == null ? null : _copyPassword,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // opções
            Card(
              child: AnimatedCrossFade(
                crossFadeState: _expanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 300),
                firstChild: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Tamanho da senha: ${_length.round()}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Slider(
                        value: _length,
                        min: 6,
                        max: 32,
                        divisions: 26,
                        label: _length.round().toString(),
                        onChanged: (v) => setState(() => _length = v),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Incluir letras minúsculas'),
                        value: _lower,
                        onChanged: (v) => setState(() => _lower = v),
                      ),
                      SwitchListTile(
                        title: const Text('Incluir letras maiúsculas'),
                        value: _upper,
                        onChanged: (v) => setState(() => _upper = v),
                      ),
                      SwitchListTile(
                        title: const Text('Incluir números'),
                        value: _numbers,
                        onChanged: (v) => setState(() => _numbers = v),
                      ),
                      SwitchListTile(
                        title: const Text('Incluir símbolos'),
                        value: _symbols,
                        onChanged: (v) => setState(() => _symbols = v),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _toggleExpanded,
                          child: const Text('Ocultar opções'),
                        ),
                      ),
                    ],
                  ),
                ),
                secondChild: ListTile(
                  title: const Text('Mostrar opções'),
                  trailing: const Icon(Icons.expand_more),
                  onTap: _toggleExpanded,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // botão gerar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _generatePassword,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Gerar Senha'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _password == null ? null : _savePassword,
        tooltip: 'Salvar senha',
        child: const Icon(Icons.save),
      ),
    );
  }
}
