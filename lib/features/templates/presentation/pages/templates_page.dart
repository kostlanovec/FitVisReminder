import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/core/utils/app_router.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';
import 'package:fit_vis_reminder/features/templates/domain/entities/reminder_template.dart';
import 'package:fit_vis_reminder/features/templates/presentation/providers/template_provider.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';

class TemplatesPage extends ConsumerStatefulWidget {
  const TemplatesPage({super.key});

  @override
  ConsumerState<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends ConsumerState<TemplatesPage> {
  final _searchController = TextEditingController();
  ReminderCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final templates = ref.watch(allTemplatesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredTemplates = templates.where((t) {
      final matchesSearch = t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t.description.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesCategory = _selectedCategory == null || t.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    final grouped = <ReminderCategory, List<ReminderTemplate>>{};
    for (final t in filteredTemplates) {
      (grouped[t.category] ??= []).add(t);
    }

    final categories = ReminderCategory.values;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(l.templatesTitle),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: l.templatesSearchHint,
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: categories.length + 1,
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          final isSelected = _selectedCategory == null;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(l.dashboardSeeAll, style: const TextStyle(fontSize: 12)),
                              selected: isSelected,
                              onSelected: (_) => setState(() => _selectedCategory = null),
                            ),
                          );
                        }
                        final cat = categories[i - 1];
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            avatar: Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                            label: Text(cat.localizedLabel(l), style: const TextStyle(fontSize: 12)),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedCategory = cat),
                            selectedColor: cat.color.withOpacity(0.2),
                            checkmarkColor: cat.color,
                            labelStyle: TextStyle(
                              color: isSelected ? cat.color : null,
                              fontWeight: isSelected ? FontWeight.w600 : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (filteredTemplates.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 64, color: AppColors.textTertiary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(l.templatesEmpty, style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final cat = grouped.keys.elementAt(i);
                  final catTemplates = grouped[cat]!;
                  return _CategorySection(
                    category: cat,
                    templates: catTemplates,
                    isDark: isDark,
                    l: l,
                  );
                },
                childCount: grouped.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.templates,
    required this.isDark,
    required this.l,
  });

  final ReminderCategory category;
  final List<ReminderTemplate> templates;
  final bool isDark;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Text(
                category.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                category.localizedLabel(l).toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: category.color,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Divider(color: category.color.withOpacity(0.2)),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: templates.length,
          itemBuilder: (context, i) {
            final tpl = templates[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.badge),
                  ),
                  child: Center(child: Text(tpl.icon, style: const TextStyle(fontSize: 20))),
                ),
                title: Text(tpl.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  tpl.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.add_rounded, color: AppColors.primary),
                onTap: () => _useTemplate(context, tpl),
              ),
            ).animate(delay: Duration(milliseconds: i * 30)).fadeIn().slideX(begin: 0.05);
          },
        ),
      ],
    );
  }

  void _useTemplate(BuildContext context, ReminderTemplate template) {
    // Navigate to form with template pre-filled
    // We can use a query parameter or pass it via state if the router supports it.
    // For now, we'll just push to the add route.
    // Ideally, the form page should accept a templateId.
    // Looking at ReminderFormPage, it has a template picker inside.
    // We can push to reminderAdd and then the user can pick it, or we enhance the router.
    
    // Better: Navigate to add and pass templateId
    context.push(AppRoutes.reminderAdd, extra: template);
  }
}
