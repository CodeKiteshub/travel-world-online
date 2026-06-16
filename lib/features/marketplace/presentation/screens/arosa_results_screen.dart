import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../providers/marketplace_providers.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

class ArosaResultsScreen extends ConsumerStatefulWidget {
  const ArosaResultsScreen({super.key});

  @override
  ConsumerState<ArosaResultsScreen> createState() => _ArosaResultsScreenState();
}

class _ArosaResultsScreenState extends ConsumerState<ArosaResultsScreen> {
  static const _rivers = ['Danube', 'Douro', 'Rhine', 'Rhône', 'Saône', 'Seine'];

  String? _selectedRiver;
  String? _selectedMonthKey; // 'YYYY-MM'
  String? _searchToken;
  String? _searchDate;
  String? _searchRiver;

  // Generate next 15 months as display/key pairs
  List<({String label, String key})> get _months {
    final now = DateTime.now();
    return List.generate(15, (i) {
      final d = DateTime(now.year, now.month + i, 1);
      final label = '${_monthNames[d.month - 1]} ${d.year}';
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      return (label: label, key: key);
    });
  }

  Future<void> _search() async {
    if (_selectedRiver == null || _selectedMonthKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a river and month')),
      );
      return;
    }
    // Fetch token then trigger search
    final token = await ref.read(arosaTokenProvider.future).catchError((_) => '');
    setState(() {
      _searchToken = token;
      _searchDate = '${_selectedMonthKey!}-01';
      _searchRiver = _selectedRiver;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfaceCard,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.ink900, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'A-ROSA River Cruises',
          style: AppTypography.heading.copyWith(color: colors.ink900),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: colors.surfaceCard,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SearchDropdown(
                        label: 'River / Destination',
                        value: _selectedRiver,
                        items: _rivers,
                        colors: colors,
                        onChanged: (v) => setState(() => _selectedRiver = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SearchDropdown(
                        label: 'Month',
                        value: _selectedMonthKey,
                        items: _months.map((m) => m.key).toList(),
                        displayItems: _months.map((m) => m.label).toList(),
                        colors: colors,
                        onChanged: (v) => setState(() => _selectedMonthKey = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Search Cruises'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.goldPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _searchToken == null
                ? _EmptyPrompt(colors: colors)
                : _ArosaResults(
                    token: _searchToken!,
                    date: _searchDate!,
                    river: _searchRiver!,
                    colors: colors,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ArosaResults extends ConsumerWidget {
  const _ArosaResults({
    required this.token,
    required this.date,
    required this.river,
    required this.colors,
  });

  final String token;
  final String date;
  final String river;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (token: token, date: date, river: river);
    final packagesAsync = ref.watch(arosaPackagesProvider(params));

    return packagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: colors.ink400),
              const SizedBox(height: 12),
              Text(
                'Could not load cruises',
                style: AppTypography.heading.copyWith(color: colors.ink900),
              ),
              const SizedBox(height: 4),
              Text(
                'Please try again',
                style: AppTypography.caption.copyWith(color: colors.ink400),
              ),
            ],
          ),
        ),
      ),
      data: (packages) {
        if (packages.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sailing_rounded, size: 48, color: colors.ink400),
                const SizedBox(height: 12),
                Text(
                  'No cruises found',
                  style: AppTypography.heading.copyWith(color: colors.ink900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Try a different month or river',
                  style: AppTypography.caption.copyWith(color: colors.ink400),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: packages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final pkg = packages[i];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.lineSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pkg.name.isNotEmpty)
                    Text(
                      pkg.name,
                      style: AppTypography.heading.copyWith(color: colors.ink900),
                    ),
                  if (pkg.river.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.water_rounded, size: 14, color: colors.ink400),
                        const SizedBox(width: 4),
                        Text(pkg.river,
                            style: AppTypography.caption
                                .copyWith(color: colors.ink400)),
                      ],
                    ),
                  ],
                  if (pkg.date.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 14, color: colors.ink400),
                        const SizedBox(width: 4),
                        Text(pkg.date,
                            style: AppTypography.caption
                                .copyWith(color: colors.ink400)),
                      ],
                    ),
                  ],
                  if (pkg.duration.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, size: 14, color: colors.ink400),
                        const SizedBox(width: 4),
                        Text(pkg.duration,
                            style: AppTypography.caption
                                .copyWith(color: colors.ink400)),
                      ],
                    ),
                  ],
                  if (pkg.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      pkg.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body.copyWith(color: colors.ink600),
                    ),
                  ],
                  if (pkg.price > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${pkg.currency} ${pkg.price.toStringAsFixed(0)}',
                          style: AppTypography.heading.copyWith(
                            color: colors.goldPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          ' / person',
                          style: AppTypography.caption
                              .copyWith(color: colors.ink400),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyPrompt extends StatelessWidget {
  const _EmptyPrompt({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sailing_rounded, size: 64, color: colors.ink400),
          const SizedBox(height: 16),
          Text(
            'Search A-ROSA Cruises',
            style: AppTypography.heading.copyWith(color: colors.ink900),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a river and month above\nto find available packages',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: colors.ink400),
          ),
        ],
      ),
    );
  }
}

class _SearchDropdown extends StatelessWidget {
  const _SearchDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.colors,
    required this.onChanged,
    this.displayItems,
  });

  final String label;
  final String? value;
  final List<String> items;
  final List<String>? displayItems;
  final AppColorScheme colors;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value, // ignore: deprecated_member_use
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.caption.copyWith(color: colors.ink400),
        filled: true,
        fillColor: colors.surfacePrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.lineSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.lineSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.goldPrimary, width: 1.5),
        ),
      ),
      onChanged: onChanged,
      style: AppTypography.body.copyWith(color: colors.ink900),
      isExpanded: true,
      items: List.generate(items.length, (i) {
        final key = items[i];
        final display = (displayItems != null && i < displayItems!.length)
            ? displayItems![i]
            : key;
        return DropdownMenuItem(value: key, child: Text(display));
      }),
    );
  }
}
