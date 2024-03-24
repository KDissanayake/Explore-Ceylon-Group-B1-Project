import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:useraccount/components/appbar.dart';

class ChatContent {
  final String role;
  final List<Part> parts;

  ChatContent({required this.role, required this.parts});
}

class AIchat extends StatefulWidget {
  const AIchat({Key? key}) : super(key: key);

  @override
  State<AIchat> createState() => _HomeState();
}

class _HomeState extends State<AIchat> {
  final _inputController = TextEditingController();
  late final ChatSession _session;
  final GenerativeModel _model = GenerativeModel(
      model: 'gemini-pro', apiKey: 'AIzaSyAVhVcKzCx1CpmLGyDa3rlMfD2LHwYrlhk');
  bool _loading = false;
  final ScrollController _scrollController = ScrollController();

  bool _showIntro = true;
  List<ChatContent> _chatHistory = [];

  final FirebasePerformance performance = FirebasePerformance.instance;

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeOutCirc,
    );
  }

  @override
  void initState() {
    super.initState();
    _session = _model.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight * 1.5),
        child: CustomAppBarWithProfile(
          context: context,
          height: kToolbarHeight * 1.5, // Define the height of the app bar
        ),
      ),
      backgroundColor: Color(0xFF456461), // Set background color
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (_showIntro)
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255)
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        'Welcome to Explore Ceylon Travel Chat! How can I assist you?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    top: _showIntro
                        ? MediaQuery.of(context).size.height * 0.3
                        : 0,
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                  ),
                  itemCount: _chatHistory.length,
                  itemBuilder: (context, index) {
                    final content = _chatHistory[index];
                    var text = content.parts
                        .whereType<TextPart>()
                        .map<String>((e) => e.text)
                        .join('');

                    // Define different colors for user and bot messages
                    Color messageColor = content.role == 'user'
                        ? const Color(
                            0xFF182727) // Light green for user messages
                        : const Color(
                            0xFF243647); // Lighter green for bot messages

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: messageColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            content.role == 'user' ? 'Me:' : 'Travel Bot:',
                            style: TextStyle(
                              color: const Color.fromARGB(
                                  255, 255, 255, 255), // Text color in black
                              fontWeight:
                                  FontWeight.bold, // Optional: Bold text
                              fontSize: 16, // Optional: Adjust font size
                            ),
                          ),
                          MarkdownBody(
                            data: text,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 35.0, right: 10.0, left: 10),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFF182727), // Set input field color
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: 'Type a message....',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12.0),
                        hintStyle: TextStyle(
                          color: Color(0x845F5F5F), // Set hint color
                        ),
                      ),
                      style: TextStyle(color: Colors.white), // Set text color
                      onEditingComplete: () {
                        if (!_loading) {
                          _sendMessage();
                        }
                      },
                      onChanged: (value) {
                        setState(() {
                          _showIntro = value.isEmpty;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: _loading ? null : _sendMessage,
                    icon: _loading
                        ? CircularProgressIndicator()
                        : Icon(Icons.send),
                    color: Colors.white, // Set icon color
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    // Start trace for sending message
    final Trace sendTrace = performance.newTrace('send_message');
    sendTrace.start();

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      // Hide the intro banner when the user starts typing
      _showIntro = false;
    });

    // Add user message to chat history
    final userMessage = _inputController.text;
    _chatHistory.add(ChatContent(role: 'user', parts: [TextPart(userMessage)]));

    try {
      // Start trace for API call
      final Trace apiTrace = performance.newTrace('api_call');
      apiTrace.start();

      final response = await _session.sendMessage(Content.text(userMessage));

      // Stop API trace
      apiTrace.stop();

      if (response.text == null) {
        _showError('Please try again later. I am sleeping');
      } else {
        // Add bot response to chat history
        _chatHistory
            .add(ChatContent(role: 'bot', parts: [TextPart(response.text!)]));

        setState(() {
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      // Stop send message trace
      sendTrace.stop();
      _inputController.clear();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
