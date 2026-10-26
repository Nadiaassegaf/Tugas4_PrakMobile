import 'package:flutter/material.dart';
import 'api_service.dart';
import 'article_model.dart';

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Berita',
      debugShowCheckedModeBanner: false,
      home: const NewsScreenApp(),
    );
  }
}

class NewsScreenApp extends StatefulWidget {
  const NewsScreenApp({super.key});

  @override
  State<NewsScreenApp> createState() => _NewsScreenAppState();
}

class _NewsScreenAppState extends State<NewsScreenApp> {
  late Future<List<Article>> _articlesFuture;

  final ScrollController _scrollController = ScrollController();

  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();

    _articlesFuture = ApiService().fetchArticles();

    _scrollController.addListener(() {
      if (_scrollController.offset > 200) {
        if (!_showBackToTop) {
          setState(() {
            _showBackToTop = true;
          });
        }
      } else {
        if (_showBackToTop) {
          setState(() {
            _showBackToTop = false;
          });
        }
      }
    });
  }

  // Memuat ulang berita
  Future<void> _refreshArticles() async {
    final newFuture = ApiService().fetchArticles();

    setState(() {
      _articlesFuture = newFuture;
    });

    try {
      await newFuture;
    } catch (e) {
      // Error ditampilkan oleh FutureBuilder
    }
  }

  // Kembali ke posisi paling atas
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aplikasi Berita',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),

      body: FutureBuilder<List<Article>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData &&
              snapshot.data!.isNotEmpty) {
            final articles = snapshot.data!;

            return RefreshIndicator(
              onRefresh: _refreshArticles,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (article.urlToImage != null &&
                              article.urlToImage!.isNotEmpty)
                            Image.network(
                              article.urlToImage!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const SizedBox(
                                  height: 100,
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                            ),

                          const SizedBox(height: 10),

                          Text(
                            article.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            article.description ??
                                'Tidak ada deskripsi',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(
              child: Text('Tidak ada berita yang ditemukan'),
            );
          }
        },
      ),

      // Tombol kembali ke atas
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: Colors.redAccent,
              child: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}