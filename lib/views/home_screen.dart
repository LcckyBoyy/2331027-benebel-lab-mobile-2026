import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/news_provider.dart';
import '../widgets/article_card.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/offline_banner.dart';
import 'detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch headlines on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().fetchHeadlines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // ── App Bar ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'News from around the world',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    // Search Button
                    _SearchButton(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SearchScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Category Filter ──
            SliverToBoxAdapter(
              child: _CategoryFilter(),
            ),

            // ── Offline Banner ──
            Consumer<NewsProvider>(
              builder: (context, provider, _) {
                if (provider.isOffline && provider.hasData) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: OfflineBanner(),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
          body: Consumer<NewsProvider>(
            builder: (context, provider, _) {
              // ── Loading State ──
              if (provider.isLoading) {
                return const LoadingShimmer();
              }

              // ── Error State ──
              if (provider.hasError) {
                return AppErrorWidget(
                  message: provider.errorMessage!,
                  onRetry: provider.retry,
                );
              }

              // ── Empty State ──
              if (!provider.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.newspaper_rounded,
                        size: 64,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No articles found',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // ── Article List ──
              return RefreshIndicator(
                onRefresh: provider.fetchHeadlines,
                color: colorScheme.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  itemCount: provider.articles.length,
                  itemBuilder: (context, index) {
                    final article = provider.articles[index];

                    // First article = large card, rest = compact
                    if (index == 0) {
                      return ArticleCard(
                        article: article,
                        onTap: () => _openDetail(context, article),
                      );
                    }
                    return ArticleCardCompact(
                      article: article,
                      onTap: () => _openDetail(context, article),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(article: article),
      ),
    );
  }
}

// ── Search Button ────────────────────────────────────────────────────────
class _SearchButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.search_rounded,
          color: colorScheme.onSurfaceVariant,
          size: 22,
        ),
      ),
    );
  }
}

// ── Category Filter Chips ────────────────────────────────────────────────
class _CategoryFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<NewsProvider>(
      builder: (context, provider, _) {
        return SizedBox(
          height: 56,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            scrollDirection: Axis.horizontal,
            itemCount: NewsProvider.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = NewsProvider.categories[index];
              final isSelected = provider.selectedCategory == category['key'];

              return GestureDetector(
                onTap: () => provider.changeCategory(category['key']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 16,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category['label'] as String,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
