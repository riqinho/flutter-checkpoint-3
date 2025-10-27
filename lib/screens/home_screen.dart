import 'package:checkpoint_3/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppMagicColors {
  static const primary = Color(0xFF8B5CF6);
  static const gold = Color(0xFFE3B341);
  static const bg = Color(0xFFFAF8F5);
  static const card = Color(0xFFF2EEE9);
  static const text = Color(0xFF1E1E1E);
  static const text2 = Color(0xFF5E5E5E);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference passwordRefs = FirebaseFirestore.instance
      .collection('passwords');

  // controla quais itens estão revelados (por id do documento)
  final Set<String> _revealed = {};

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void deletePassword(DocumentSnapshot doc) {
    passwordRefs.doc(doc.id).delete();
  }

  void _toggleReveal(String docId) {
    setState(() {
      if (_revealed.contains(docId)) {
        _revealed.remove(docId);
      } else {
        _revealed.add(docId);
      }
    });
  }

  String _masked() => '•' * 8; // não revela o tamanho real da senha

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppMagicColors.bg,
      appBar: AppBar(
        backgroundColor: AppMagicColors.bg,
        elevation: 0,
        title: const Text(
          'Grimório',
          style: TextStyle(
            color: AppMagicColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppMagicColors.primary),
            onPressed: _signOut,
            tooltip: "Sair",
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Bem-vindo, ${user?.email ?? 'Usuário'}!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppMagicColors.text,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // bloco promocional plano Plus (ícone trocado)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppMagicColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppMagicColors.gold.withOpacity(.5)),
              boxShadow: [
                BoxShadow(
                  color: AppMagicColors.primary.withOpacity(.08),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome, // ✨ mais “mágico” que o escudo
                  size: 84,
                  color: AppMagicColors.primary,
                ),
                const SizedBox(width: 18),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🔮 Teste o Plano Plus!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppMagicColors.text,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Desbloqueie novos feitiços e proteja suas senhas com poder arcano avançado. "
                        "Experimente a magia premium gratuitamente por 7 dias!",
                        style: TextStyle(
                          color: AppMagicColors.text2,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Suas senhas salvas aparecerão aqui.',
            style: TextStyle(fontSize: 15, color: AppMagicColors.text2),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: passwordRefs.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppMagicColors.primary,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro: ${snapshot.error}',
                      style: const TextStyle(color: AppMagicColors.text2),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  // estado vazio com ícone
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_book_outlined, // grimório
                            size: 96,
                            color: AppMagicColors.primary,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Nenhuma senha salva ainda.\nConjure seu primeiro feitiço tocando no +',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppMagicColors.text2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final doc = docs[index];
                    final id = doc.id;
                    final title = (doc['title'] ?? 'Sem título') as String;
                    final password = (doc['password'] ?? 'Sem senha') as String;
                    final revealed = _revealed.contains(id);

                    return Card(
                      color: AppMagicColors.card,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppMagicColors.gold.withOpacity(.4),
                        ),
                      ),
                      child: ListTile(
                        // ícone vira “olho” que mostra/esconde
                        leading: IconButton(
                          tooltip: revealed ? 'Ocultar senha' : 'Revelar senha',
                          icon: Icon(
                            revealed ? Icons.visibility : Icons.visibility_off,
                            color: AppMagicColors.primary,
                          ),
                          onPressed: () => _toggleReveal(id),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(color: AppMagicColors.text),
                        ),
                        subtitle: Text(
                          revealed ? password : _masked(),
                          style: const TextStyle(color: AppMagicColors.text2),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: AppMagicColors.primary,
                          ),
                          onPressed: () => deletePassword(doc),
                          tooltip: "Excluir Senha",
                        ),
                        onTap: () {
                          // também alterna ao tocar na linha
                          _toggleReveal(id);
                        },
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
        backgroundColor: AppMagicColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.pushNamed(context, Routes.newPassword),
        child: const Icon(Icons.add),
        tooltip: "Nova Senha",
      ),
    );
  }
}
