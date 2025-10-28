import 'package:checkpoint_3/main.dart';
import 'package:checkpoint_3/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // collection criada no firebase database
  final CollectionReference passwordRefs = FirebaseFirestore.instance
      .collection('passwords');

  // controla quais itens estão revelados (por id do documento)
  final Set<String> _revealed = {};

  // função para deslogar o usuário
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // função para deletar senha
  void deletePassword(DocumentSnapshot doc) {
    passwordRefs.doc(doc.id).delete();
  }

  // função para revelear/ocultar senha
  void _toggleReveal(String docId) {
    setState(() {
      if (_revealed.contains(docId)) {
        _revealed.remove(docId);
      } else {
        _revealed.add(docId);
      }
    });
  }

  void _snack(
    String msg, {
    Color color = AppMagicColors.primary,
    IconData icon = Icons.auto_awesome,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
      ),
    );
  }

  void _copyPassword(String value) {
    Clipboard.setData(ClipboardData(text: value));
    _snack('Senha copiada para a área mágica');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppMagicColors.bg,
      appBar: AppBar(
        backgroundColor: AppMagicColors.bg,
        elevation: 0,
        title: const Text(
          'Meu Grimório',
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
          // imagem do promocional - plus
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Image.asset('assets/images/banner-plus.png'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Suas senhas salvas aparecerão aqui.',
            style: TextStyle(fontSize: 15, color: AppMagicColors.text2),
          ),
          const SizedBox(height: 20),
          // lista de senhas salvas
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
                          color: AppMagicColors.gold.withOpacity(0.4),
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
                          revealed ? password : '•' * password.length,
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
                          _copyPassword(password);
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
        tooltip: "Nova Senha",
        child: const Icon(Icons.add),
      ),
    );
  }
}
