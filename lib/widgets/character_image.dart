import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_theme.dart';

// Cache damit nicht jedes Mal neu geladen wird
final Map<String, String?> _imageCache = {};

class CharacterImage extends StatefulWidget {
  final String? storedUrl;
  final String characterName;
  final double size;
  final BoxFit fit;

  const CharacterImage({
    super.key,
    required this.storedUrl,
    required this.characterName,
    required this.size,
    this.fit = BoxFit.cover,
  });

  @override
  State<CharacterImage> createState() => _CharacterImageState();
}

class _CharacterImageState extends State<CharacterImage> {
  String? _resolvedUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    // 1. Stored URL vorhanden und ist PokeAPI → direkt nutzen (immer zuverlässig)
    if (widget.storedUrl != null &&
        widget.storedUrl!.contains('raw.githubusercontent.com/PokeAPI')) {
      setState(() {
        _resolvedUrl = widget.storedUrl;
        _loading = false;
      });
      return;
    }

    // 2. Cache prüfen
    final cacheKey = widget.characterName.toLowerCase();
    if (_imageCache.containsKey(cacheKey)) {
      setState(() {
        _resolvedUrl = _imageCache[cacheKey];
        _loading = false;
      });
      return;
    }

    // 3. Stored URL testen ob sie lädt
    if (widget.storedUrl != null && widget.storedUrl!.startsWith('http')) {
      final works = await _urlWorks(widget.storedUrl!);
      if (works) {
        _imageCache[cacheKey] = widget.storedUrl;
        setState(() {
          _resolvedUrl = widget.storedUrl;
          _loading = false;
        });
        return;
      }
    }

    // 4. Über Jikan API (MyAnimeList) suchen
    final jikanUrl = await _fetchFromJikan(widget.characterName);
    _imageCache[cacheKey] = jikanUrl;
    if (mounted) {
      setState(() {
        _resolvedUrl = jikanUrl;
        _loading = false;
      });
    }
  }

  Future<bool> _urlWorks(String url) async {
    try {
      final response =
          await http.head(Uri.parse(url)).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _fetchFromJikan(String name) async {
    try {
      // Klammern und Klarnamen bereinigen
      final clean = name
          .replaceAll(RegExp(r'\(.*?\)'), '')
          .replaceAll(RegExp(r'[^a-zA-ZäöüÄÖÜß\s]'), '')
          .trim();

      final uri = Uri.parse(
          'https://api.jikan.moe/v4/characters?q=${Uri.encodeComponent(clean)}&limit=1');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'] as List?;
        if (data != null && data.isNotEmpty) {
          final images = data[0]['images'];
          final jpg = images?['jpg'];
          final url = jpg?['image_url'] as String?;
          return url;
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    if (_loading) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    if (_resolvedUrl == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.person_outline,
          color: AppColors.textSecondary,
          size: size * 0.5,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        _resolvedUrl!,
        width: size,
        height: size,
        fit: widget.fit,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: AppColors.surfaceVariant,
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.textSecondary,
            size: size * 0.4,
          ),
        ),
      ),
    );
  }
}
