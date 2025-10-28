# 🔮 SafeKey — Grimório Digital de Senhas

> **Projeto Flutter + Firebase** desenvolvido como parte do exercício de **Desenvolvimento Android (2º semestre)**, transformado em um aplicativo temático e divertido com a estética de um **grimório de feitiços digitais**.

---

## 🧭 Visão Geral do Projeto

O **SafeKey** é um aplicativo que gera e gerencia senhas de forma segura e estilizada.  
Inspirado em um **“grimório de feitiços”**, o app permite que o usuário conjure (gere), sele (salve) e visualize suas senhas, tudo integrado ao **Firebase Authentication** e **Cloud Firestore**.

---

## 🧩 Estrutura e Funcionalidades

### 🪄 **1. Splash Screen**

- Exibe uma animação Lottie mágica (círculo arcano).
- Verifica se o usuário está logado e se deve mostrar a introdução.
- Redireciona automaticamente para a tela apropriada (Intro, Login ou Home).

### 📜 **2. Intro Screen**

- Mostra 3 telas de introdução com animações, títulos e descrições:
  1. _Descubra seus Encantamentos_
  2. _Crie Senhas Poderosas_
  3. _Proteja seu Grimório_
- Permite avançar, voltar e ocultar a introdução para futuras execuções.

### 🔐 **3. Login / Registro**

- Formulário de autenticação com FirebaseAuth.
- Login e criação de contas com e-mail e senha.
- Snackbars personalizadas com mensagens temáticas (“Portais abertos”, “Feitiço falhou”…).
- Feedback visual e estado de carregamento.
- Inputs de textos customizados 

### 🏠 **4. Home Screen**

- Exibe a saudação personalizada com o e-mail do usuário.
- Mostra uma imagem promocional do **Plano Plus** (versão premium imaginária).
- Lista de senhas salvas, carregadas em tempo real via `StreamBuilder`.
- Cada senha pode ser:
  - **Revelada / ocultada** (olho mágico 👁️).
  - **Excluída** individualmente.
  - **Copiada** para a área de transferência 
- Estado vazio com ícone e mensagem mística.

### ✨ **5. New Password Screen**

- Permite gerar senhas com a API pública [SafeKey API](https://safekey-api-a1bd9aa97953.herokuapp.com/docs/).
- Configurações ajustáveis: tamanho, letras minúsculas, maiúsculas, números e símbolos.
- Exibe o resultado e permite copiar para a área de transferência.
- Salva a senha no Firebase após pedir um título (com validação se estiver vazio).
- Redireciona automaticamente para a tela Home após o salvamento.

---

## 🧠 Tecnologias Utilizadas

| Categoria                | Ferramenta / Versão                                            |
| ------------------------ | -------------------------------------------------------------- |
| Framework                | Flutter                                                        |
| Linguagem                | Dart                                                           |
| Backend                  | Firebase Authentication / Firestore                            |
| API de geração de senhas | SafeKey API                                                    |
| Animações                | Lottie                                                         |
| Estilo visual            | Tema claro “gregório” (tons pergaminho, dourado e roxo arcano) |

---

## ⚙️ Estrutura do Código

```
lib/
│
├── data/
│ └── settings_repository.dart # controle de preferências locais
│
├── screens/
│ ├── splash_screen.dart # verificação inicial e redirecionamento
│ ├── intro_screen.dart # introdução em 3 páginas com Lottie
│ ├── login_screen.dart # autenticação Firebase
│ ├── home_screen.dart # listagem e exclusão de senhas
│ └── newpassword_screen.dart # geração e salvamento de senhas
|
├── widgets/
| ├── custom_field.dart # widget do input de texto
│ ├── password_result.dart # widget da senha gerada
│
├── routes.dart # controle de rotas nomeadas
└── main.dart # inicialização e tema global
```

---

## 🎥 Demonstração

📺 **[Clique aqui para assistir ao vídeo do app funcionando](https://youtu.be/rYWytxMk7Oo)**

---

## 🏫 Aulas de Referência

| Funcionalidade                  | Aula                                       |
| ------------------------------- | ------------------------------------------ |
| Autenticação (Login e Registro) | flutter-firebase-auth                      |
| Integração com Firestore        | flutter-firebase-firestore-manual          |
| Splash, Introdução e lottie     | flutter-rotas-nomeadas-com-sharedprefences |
| Requisições HTTP (API SafeKey)  | flutter-webservices-crud-endereco          |

---

## 🔐 Observação Importante — Controle por Usuário

> Atualmente, todas as senhas são salvas na coleção global **`passwords`**, o que significa que qualquer usuário logado poderia visualizar registros de outros.
>
> 💡 **Melhoria planejada:** incluir o campo `uid` (ou criar uma subcoleção `users/{uid}/passwords`) para que cada usuário visualize apenas suas próprias senhas.  
> Também é recomendada a configuração de **regras de segurança no Firestore** garantindo esse isolamento.

---

## 🌟 Créditos e Agradecimentos

- **Professor(a):** Heider Lopes
- **Curso:** Desenvolvimento Cross Plataforma - FIAP
- **Aluno:** Rick Alves Domingues
- **Ano:** 2025
- Tema visual e narrativa Grimório: inspiração autoral e implantado com ajuda da IA

---

> “A cada senha gerada, um novo feitiço é conjurado.  
> Proteja bem seu grimório.” 🔮
