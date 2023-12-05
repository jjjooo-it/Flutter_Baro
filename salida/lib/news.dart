import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: News(),
    ),
  );
}

class News extends StatefulWidget {
  const News({Key? key}) : super(key: key);

  @override
  State<News> createState() => _NewsPageState();
}

class _NewsPageState extends State<News> {
  List<Map<String, String>> newsList = [
    {'title': '[속보] 어쩌구저쩌구어쩌구저쩌구', 'text':'요약요약요약요약요약요약요약요약요약','url': 'https://google.com'},
    {'title': '[속보] 어쩌구저쩌구어쩌구저쩌구', 'text':'요약요약요약요약요약요약요약요약요약','url': 'https://flutter.dev'},
    {'title': '[속보] 어쩌구저쩌구어쩌구저쩌구', 'text':'요약요약요약요약요약요약요약요약요약','url': 'https://openai.com'},
    {'title': '[속보] 어쩌구저쩌구어쩌구저쩌구', 'text':'요약요약요약요약요약요약요약요약요약','url': 'https://openai.com'},
    {'title': '[속보] 어쩌구저쩌구어쩌구저쩌구', 'text':'요약요약요약요약요약요약요약요약요약','url': 'https://openai.com'},
    {'title': '[속보] 어쩌구저쩌구어쩌구저쩌구', 'text':'요약요약요약요약요약요약요약요약요약','url': 'https://openai.com'},
    {'title': '[속보] 어쩌구저쩌구어쩌구저쩌구', 'text':'요약요약요약요약요약요약요약요약요약','url': 'https://openai.com'},
    {'title': '[속보] 어쩌구저쩌구어쩌구저쩌구', 'text':'요약요약요약요약요약요약요약요약요약','url': 'https://google.com'},
    {'title': '[속보] 어쩌구저쩌구어쩌구저쩌구', 'text':'요약요약요약요약요약요약요약요약요약','url': 'https://flutter.dev'},
    {'title': '[속보] 어쩌구저쩌구어쩌구저쩌구', 'text':'요약요약요약요약요약요약요약요약요약','url': 'https://openai.com'},
    {'title': '[속보] 어쩌구저쩌구어쩌구저쩌구', 'text':'요약요약요약요약요약요약요약요약요약','url': 'https://openai.com'},
    {'title': '[속보] 어쩌구저쩌구어쩌구저쩌구', 'text':'요약요약요약요약요약요약요약요약요약','url': 'https://openai.com'},
    {'title': '[속보] 어쩌구저쩌구어쩌구저쩌구', 'text':'요약요약요약요약요약요약요약요약요약','url': 'https://openai.com'},
    {'title': '[속보] 어쩌구저쩌구어쩌구저쩌구', 'text':'요약요약요약요약요약요약요약요약요약','url': 'https://openai.com'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('재난 뉴스', style: TextStyle(color: Colors.black)),
          centerTitle: true,
        ),
        body: ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => _launchURL(newsList[index]['url']!),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          newsList[index]['title']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(newsList[index]['text']!),
                      ],
                    ),
                  ),
                ),
              );
              },
    ),
    );
  }

  Widget _hyperlinkText(String title, String text, String url) {
    return InkWell(
        child: Text(text),
        onTap: () => _launchURL(url),
      );
  }
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw 'Could not launch $urlString';
    }
  }
}


