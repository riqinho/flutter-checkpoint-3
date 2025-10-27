import 'package:checkpoint_3/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final CollectionReference passwordRefs = FirebaseFirestore.instance
      .collection('passwords');

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  //excluir senha
  void deletePassword(DocumentSnapshot doc) {
    passwordRefs.doc(doc.id).delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: "Sair",
          ),
        ],
      ),
      body: Column(
        children: [
          Text(
            'Bem-vindo, ${user?.email ?? 'Usuário'}!',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          Container(
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, size: 100, color: Colors.blue),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text("opa"), Text("opa 2")],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Suas senhas salvas aparecerão aqui.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: passwordRefs.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhuma senha salva.'));
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final doc = docs[index];
                    return ListTile(
                      title: Text(doc['title'] ?? 'Sem título'),
                      subtitle: Text(doc['password'] ?? 'Sem senha'),
                      leading: const Icon(Icons.vpn_key),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deletePassword(doc),
                        tooltip: "Excluir Senha",
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
        onPressed: () {
          Navigator.pushNamed(context, Routes.newPassword);
        },
        child: const Icon(Icons.add),
        tooltip: "Nova Senha",
      ),
    );
  }
}
