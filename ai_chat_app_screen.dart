// import 'dart:convert';
// import 'package:first_project/modal/GeminiResponse.dart';
// import 'package:first_project/utilities/keys.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// class AIChatApp extends StatelessWidget {
//   const AIChatApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: ChatScreen(), debugShowCheckedModeBanner: false);
//   }
// }
//
// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   TextEditingController messageController = TextEditingController();
//
//   List<String> messages = [];
//   bool isLoading = false;
//
//   Future<void> sendMessage() async {
//     String message = messageController.text.trim();
//
//     if (message.isEmpty || isLoading) {
//       return;
//     }
//
//     setState(() {
//       messages.add("You: $message");
//       isLoading = true;
//       messageController.clear();
//     });
//
//     try {
//       final response = await http.post(
//         Uri.parse(Keys.geminiUrl),
//         headers: {
//           "Content-Type": "application/json",
//           "x-goog-api-key": Keys.apiKey,
//         },
//         body: jsonEncode({"model": Keys.model, "input": message}),
//       );
//
//       print("STATUS CODE: ${response.statusCode}");
//       print("RESPONSE: ${response.body}");
//
//       if (response.statusCode == 200) {
//         Map<String, dynamic> data = jsonDecode(response.body);
//
//         String reply = GeminiResponse.parseData(data);
//
//         setState(() {
//           messages.add("Gemini: $reply");
//         });
//       } else {
//         setState(() {
//           messages.add("Error: ${response.statusCode}");
//         });
//       }
//     } catch (e) {
//       setState(() {
//         messages.add("Something went wrong!");
//       });
//
//       print(e);
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     messageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Gemini AI Chat")),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: const EdgeInsets.all(10),
//                   child: Text(messages[index]),
//                 );
//               },
//             ),
//           ),
//
//           if (isLoading)
//             const Padding(
//               padding: EdgeInsets.all(8),
//               child: CircularProgressIndicator(),
//             ),
//
//           Padding(
//             padding: const EdgeInsets.all(10),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: messageController,
//                     decoration: const InputDecoration(
//                       hintText: "Type your message...",
//                       border: OutlineInputBorder(),
//                     ),
//                     onSubmitted: (_) => sendMessage(),
//                   ),
//                 ),
//
//                 IconButton(
//                   onPressed: isLoading ? null : sendMessage,
//                   icon: const Icon(Icons.send),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:first_project/modal/GeminiResponse.dart';
import 'package:first_project/utilities/keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AIChatApp extends StatelessWidget {
  const AIChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Chat Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff6750A4)),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatMessage {
  final String message;
  final bool isUser;

  ChatMessage({required this.message, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final List<ChatMessage> messages = [
    ChatMessage(
      message: "Hello! 👋 I'm your AI Assistant. How can I help you today?",
      isUser: false,
    ),
    ChatMessage(message: "Can you explain what Flutter is?", isUser: true),
    ChatMessage(
      message:
          "Flutter is Google's UI toolkit for building beautiful applications for mobile, web, and desktop using a single codebase.",
      isUser: false,
    ),
    ChatMessage(message: "That's helpful. Thank you!", isUser: true),
    ChatMessage(
      message: "You're welcome! 😊 Feel free to ask me anything else.",
      isUser: false,
    ),
  ];

  void sendMessage() async {
    final text = messageController.text.trim();

    if (text.isEmpty) return;
    setState(() {
      messages.add(
          ChatMessage(
              message: messageController.text.trim(),
              isUser: true
          )
      );
    });

    final response = await http.post(
      Uri.parse("${Keys.geminiUrl}?key=${Keys.apiKey}"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gemini-3.8-flash",
        "input": messageController.text,
      }),
    );
    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      String aiResponse = GeminiResponse.parseData(res);

      setState(() {
        messages.add(
          ChatMessage(message: aiResponse, isUser: false),
        );
      });
    } else if (response.statusCode == 503) {
      setState(() {
        messages.add(
          ChatMessage(
            message: "Gemini is busy right now. Please try again shortly.",
            isUser: false,
          ),
        );
      });
    } else {
      setState(() {
        messages.add(
          ChatMessage(
            message: "Error ${response.statusCode}: Please try again.",
            isUser: false,
          ),
        );
      });
    }

    messageController.clear();

    // Scroll to the latest message
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F9),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,

        title: const Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xff6750A4),
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 21),
            ),

            SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Assistant",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Online",
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),

      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                return MessageBubble(
                  message: message.message,
                  isUser: message.isUser,
                );
              },
            ),
          ),

          // Bottom input area
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x15000000),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),

            child: Row(
              children: [
                // Text field
                Expanded(
                  child: TextField(
                    controller: messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => sendMessage(),

                    decoration: InputDecoration(
                      hintText: "Ask anything...",
                      hintStyle: const TextStyle(color: Colors.grey),

                      filled: true,
                      fillColor: const Color(0xffF4F4F6),

                      prefixIcon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.grey,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xff6750A4),
                    shape: BoxShape.circle,
                  ),

                  child: IconButton(
                    onPressed: sendMessage,
                    icon: const Icon(Icons.arrow_upward, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const MessageBubble({super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // AI avatar
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 8),

              child: const CircleAvatar(
                radius: 17,
                backgroundColor: Color(0xff6750A4),

                child: Icon(Icons.auto_awesome, color: Colors.white, size: 17),
              ),
            ),

          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

              decoration: BoxDecoration(
                color: isUser ? const Color(0xff6750A4) : Colors.white,

                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),

                  bottomLeft: Radius.circular(isUser ? 18 : 4),

                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),

                boxShadow: isUser
                    ? null
                    : const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
              ),

              child: Text(
                message,

                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isUser ? Colors.white : const Color(0xff222222),
                ),
              ),
            ),
          ),

          // User avatar
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 8),

              child: const CircleAvatar(
                radius: 17,
                backgroundColor: Color(0xffE7E0EC),

                child: Icon(Icons.person, color: Color(0xff6750A4), size: 19),
              ),
            ),
        ],
      ),
    );
  }
}
