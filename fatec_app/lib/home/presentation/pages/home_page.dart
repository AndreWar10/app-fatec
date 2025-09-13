import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fatec_app/core/theme/app_colors.dart';
import 'package:fatec_app/core/services/firestore_service.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _bannerPageController;
  Timer? _timer;
  List<dynamic> _highlights = [];
  bool _isLoading = true;

  // Lista de cursos com ícones
  static const List<Map<String, dynamic>> _courses = [
    {
      'name': 'Análise e Desenvolvimento de Sistemas',
      'icon': Icons.computer,
      'abbreviation': 'ADS',
    },
    {
      'name': 'Desenvolvimento de Software Multiplataforma',
      'icon': Icons.phone_android,
      'abbreviation': 'DSM',
    },
    {
      'name': 'Gestão Empresarial',
      'icon': Icons.business,
      'abbreviation': 'GE',
    },
    {
      'name': 'Gestão de Produção Industrial',
      'icon': Icons.precision_manufacturing,
      'abbreviation': 'GPI',
    },
    {
      'name': 'Gestão de Recursos Humanos',
      'icon': Icons.people,
      'abbreviation': 'GRH',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController();
    _startAutoScroll();
    _loadHighlights();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerPageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_bannerPageController.hasClients) {
        final currentPage = _bannerPageController.page?.round() ?? 0;
        final nextPage = (currentPage + 1) % _highlights.length; // Usar quantidade de highlights
        _bannerPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadHighlights() async {
    try {
      // Primeiro, imprime todos os dados do documento
      await FirestoreService.printHomeData();
      
      // Depois busca especificamente os highlights
      final highlights = await FirestoreService.getHighlights();
      
      // Debug: Print highlights structure
      print('=== HIGHLIGHTS DEBUG ===');
      print('Highlights count: ${highlights?.length ?? 0}');
      if (highlights != null) {
        for (int i = 0; i < highlights.length; i++) {
          print('Highlight $i: ${highlights[i]}');
          print('Highlight $i type: ${highlights[i].runtimeType}');
        }
      }
      print('========================');
      
      if (mounted) {
        setState(() {
          _highlights = highlights ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading highlights: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildHighlightImage(int index, dynamic highlight) {
    String? imageUrl;
    String title = 'Destaque ${index + 1}';
    String? description;

    // Handle different data structures
    if (highlight is String) {
      // If highlight is a direct URL string
      imageUrl = highlight;
    } else if (highlight is Map<String, dynamic>) {
      // If highlight is a map with image URL and other data
      imageUrl = highlight['imageUrl'] ?? highlight['url'] ?? highlight['image'];
      title = highlight['title'] ?? title;
      description = highlight['description'];
    }

    // Check if we have a valid image URL
    if (imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
      return _buildNetworkImageWithFallback(imageUrl, index, highlight);
    } else {
      // No valid image URL, show error banner
      return _buildErrorBanner(index, highlight);
    }
  }

  Widget _buildNetworkImageWithFallback(String imageUrl, int index, dynamic highlight) {
    return FutureBuilder<http.Response>(
      future: _loadImageWithHeaders(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.statusCode != 200) {
          print('Image loading failed for URL: $imageUrl');
          print('Status code: ${snapshot.data?.statusCode}');
          print('Error: ${snapshot.error}');
          return _buildErrorBanner(index, highlight);
        }

        return Image.memory(
          snapshot.data!.bodyBytes,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            print('Image decoding error: $error');
            return _buildErrorBanner(index, highlight);
          },
        );
      },
    );
  }

  Future<http.Response> _loadImageWithHeaders(String imageUrl) async {
    final uri = Uri.parse(imageUrl);
    
    // Try different approaches based on the domain
    if (imageUrl.contains('pngtree.com')) {
      // For pngtree, try multiple approaches
      try {
        // First try with referer
        return await http.get(uri, headers: {
          'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
          'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
          'Referer': 'https://pngtree.com/',
        });
      } catch (e) {
        // If that fails, try without referer
        return await http.get(uri, headers: {
          'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
          'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
        });
      }
    } else if (imageUrl.contains('brave.com')) {
      // For Brave search images
      return await http.get(uri, headers: {
        'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
        'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
      });
    } else {
      // Default headers for other domains
      return await http.get(uri, headers: {
        'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
        'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
      });
    }
  }

  // Fallback image URLs for testing
  List<String> _getFallbackImages() {
    return [
      'https://picsum.photos/400/200?random=1',
      'https://picsum.photos/400/200?random=2',
      'https://picsum.photos/400/200?random=3',
    ];
  }

  Widget _buildErrorBanner(int index, dynamic highlight) {
    String title = 'Destaque ${index + 1}';
    String? description;

    if (highlight is Map<String, dynamic>) {
      title = highlight['title'] ?? title;
      description = highlight['description'];
    }

    // Try to use a fallback image from picsum
    final fallbackImages = _getFallbackImages();
    final fallbackIndex = index % fallbackImages.length;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Fallback image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              fallbackImages[fallbackIndex],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                // If even the fallback fails, show the error UI
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (description != null && description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Text(
                              description,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Overlay with title
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (description != null && description.isNotEmpty)
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.imageBackground,
              ),
              child: Image.asset(
                'assets/home/fatec-header.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Fatec Header',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Conteúdo principal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Seção de Cursos
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Cursos Disponíveis',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ListView horizontal dos cursos
                  SizedBox(
                    height: 168, // Aumentado em 28px (era 140px)
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _courses.length,
                      itemBuilder: (context, index) {
                        final course = _courses[index];
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            // boxShadow: AppColors.cardShadow,
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  course['icon'] as IconData,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  course['abbreviation'] as String,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  course['name'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Seção de Banners (Carrossel)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Destaques',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : _highlights.isEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 32,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Nenhum destaque encontrado',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : PageView.builder(
                                controller: _bannerPageController,
                                itemCount: _highlights.length,
                                itemBuilder: (context, index) {
                                  final highlight = _highlights[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: _buildHighlightImage(index, highlight),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}