import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/villa_city_model.dart';
import '../../data/models/villa_rate_model.dart';
import '../providers/marketplace_providers.dart';

class VillaSearchScreen extends ConsumerStatefulWidget {
  const VillaSearchScreen({super.key});

  @override
  ConsumerState<VillaSearchScreen> createState() => _VillaSearchScreenState();
}

class _VillaSearchScreenState extends ConsumerState<VillaSearchScreen> {
  VillaCityModel? _selectedCity;
  DateTime? _checkin;
  DateTime? _checkout;
  int _adults = 2;
  int _children = 0;
  int _units = 1;

  VillaSearchParams? _activeSearch;
  bool _autoLoaded = false;

  Future<void> _pickDate({required bool isCheckin}) async {
    final now = DateTime.now();
    final first = isCheckin ? now : (_checkin?.add(const Duration(days: 1)) ?? now);
    final preferred = isCheckin
        ? (_checkin ?? now.add(const Duration(days: 1)))
        : (_checkout ?? now.add(const Duration(days: 3)));
    final initial = preferred.isBefore(first) ? first : preferred;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckin) {
        _checkin = picked;
        if (_checkout != null && !_checkout!.isAfter(picked)) {
          _checkout = picked.add(const Duration(days: 1));
        }
      } else {
        _checkout = picked;
      }
    });
  }

  void _search({VillaCityModel? cityOverride}) {
    final city = cityOverride ?? _selectedCity;
    if (city == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a city')),
      );
      return;
    }
    setState(() {
      _activeSearch = (
        city: city.slug.isNotEmpty ? city.slug : city.name,
        checkin: _checkin != null ? _formatDate(_checkin!) : '',
        checkout: _checkout != null ? _formatDate(_checkout!) : '',
        adults: _adults,
        children: _children,
      );
    });
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _displayDate(DateTime? d) {
    if (d == null) return 'Select date';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final citiesAsync = ref.watch(villaCitiesProvider);

    // Auto-load suggestions with first city when cities arrive
    citiesAsync.whenData((cities) {
      if (cities.isNotEmpty && !_autoLoaded) {
        _autoLoaded = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _search(cityOverride: cities.first);
        });
      }
    });

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfaceCard,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.ink900, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Villa Search',
          style: AppTypography.heading.copyWith(color: colors.ink900),
        ),
      ),
      body: Column(
        children: [
          // Search form
          Container(
            color: colors.surfaceCard,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // City dropdown
                citiesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => Text(
                    'Failed to load cities',
                    style: AppTypography.caption.copyWith(color: AppColors.error),
                  ),
                  data: (cities) => DropdownButtonFormField<VillaCityModel>(
                    value: _selectedCity, // ignore: deprecated_member_use
                    decoration: _inputDecoration('City', colors),
                    onChanged: (v) => setState(() => _selectedCity = v),
                    items: cities
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.name),
                            ))
                        .toList(),
                    style: AppTypography.body.copyWith(color: colors.ink900),
                    hint: Text('Select city',
                        style: AppTypography.body.copyWith(color: colors.ink400)),
                  ),
                ),
                const SizedBox(height: 12),

                // Date row
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDate(isCheckin: true),
                        child: _DateTile(
                          label: 'Check-in',
                          value: _displayDate(_checkin),
                          colors: colors,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDate(isCheckin: false),
                        child: _DateTile(
                          label: 'Check-out',
                          value: _displayDate(_checkout),
                          colors: colors,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Guests row
                Row(
                  children: [
                    Expanded(
                      child: _Counter(
                        label: 'Adults',
                        value: _adults,
                        min: 1,
                        max: 10,
                        colors: colors,
                        onChanged: (v) => setState(() => _adults = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Counter(
                        label: 'Children',
                        value: _children,
                        min: 0,
                        max: 5,
                        colors: colors,
                        onChanged: (v) => setState(() => _children = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Counter(
                        label: 'Units',
                        value: _units,
                        min: 1,
                        max: 5,
                        colors: colors,
                        onChanged: (v) => setState(() => _units = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                FilledButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Search Villas'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.goldPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
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
            child: _activeSearch == null
                ? _EmptyState(colors: colors)
                : _VillaResults(
                    params: _activeSearch!,
                    isSuggestion: _selectedCity == null,
                    colors: colors,
                  ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, AppColorScheme colors) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.caption.copyWith(color: colors.ink400),
      filled: true,
      fillColor: colors.surfacePrimary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
    );
  }
}

// ── Results list ──────────────────────────────────────────────────────────────

class _VillaResults extends ConsumerWidget {
  const _VillaResults({
    required this.params,
    required this.colors,
    this.isSuggestion = false,
  });
  final VillaSearchParams params;
  final AppColorScheme colors;
  final bool isSuggestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(villaRatesProvider(params));
    return ratesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: colors.ink400),
              const SizedBox(height: 12),
              Text('Could not load villas',
                  style: AppTypography.heading.copyWith(color: colors.ink900)),
              const SizedBox(height: 4),
              Text('Please try again',
                  style: AppTypography.caption.copyWith(color: colors.ink400)),
            ],
          ),
        ),
      ),
      data: (rates) {
        if (rates.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.villa_rounded, size: 48, color: colors.ink400),
                const SizedBox(height: 12),
                Text('No villas available',
                    style: AppTypography.heading.copyWith(color: colors.ink900)),
                const SizedBox(height: 4),
                Text('Try different dates or city',
                    style: AppTypography.caption.copyWith(color: colors.ink400)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: rates.length + 1,
          separatorBuilder: (_, i) =>
              i == 0 ? const SizedBox(height: 12) : const SizedBox(height: 12),
          itemBuilder: (_, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  isSuggestion ? 'Suggested Villas' : '${rates.length} villa${rates.length != 1 ? 's' : ''} found',
                  style: AppTypography.heading.copyWith(color: colors.ink900),
                ),
              );
            }
            return _VillaCard(rate: rates[i - 1], colors: colors);
          },
        );
      },
    );
  }
}

class _VillaCard extends StatelessWidget {
  const _VillaCard({required this.rate, required this.colors});
  final VillaRateModel rate;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.villaDetail, extra: rate),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.lineSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: rate.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: rate.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _NavyFallback(colors: colors),
                    )
                  : _NavyFallback(colors: colors),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          rate.propertyName,
                          style: AppTypography.heading.copyWith(color: colors.ink900),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (rate.ratePlanCode.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colors.goldPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            rate.ratePlanCode,
                            style: AppTypography.label.copyWith(
                              color: colors.goldPrimary,
                              fontSize: 9,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (rate.city.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14, color: colors.ink400),
                        const SizedBox(width: 4),
                        Text(rate.city,
                            style: AppTypography.caption
                                .copyWith(color: colors.ink400)),
                      ],
                    ),
                  ],
                  if (rate.numberOfOffers > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${rate.numberOfOffers} offer${rate.numberOfOffers > 1 ? 's' : ''} available',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.success),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Starting from',
                              style: AppTypography.caption
                                  .copyWith(color: colors.ink400)),
                          Text(
                            '${rate.currency} ${rate.amount.toStringAsFixed(0)}',
                            style: AppTypography.heading.copyWith(
                              color: colors.goldPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.navyDeep,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'View Details',
                          style: AppTypography.label
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ],
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.villa_rounded, size: 64, color: colors.ink400),
          const SizedBox(height: 16),
          Text('Find Your Perfect Villa',
              style: AppTypography.heading.copyWith(color: colors.ink900)),
          const SizedBox(height: 8),
          Text(
            'Select a city, dates and guests\nthen tap Search Villas',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: colors.ink400),
          ),
        ],
      ),
    );
  }
}

class _NavyFallback extends StatelessWidget {
  const _NavyFallback({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: colors.navyDeep,
      child: const Center(
        child: Icon(Icons.villa_rounded, size: 48, color: Colors.white54),
      ),
    );
  }
}

// ── Search form sub-widgets ───────────────────────────────────────────────────

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.colors,
  });

  final String label;
  final String value;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.lineSoft),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined, size: 16, color: colors.ink400),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTypography.caption
                        .copyWith(color: colors.ink400, fontSize: 10)),
                Text(value,
                    style: AppTypography.body.copyWith(color: colors.ink900),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.colors,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final AppColorScheme colors;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.lineSoft),
      ),
      child: Column(
        children: [
          Text(label,
              style: AppTypography.caption
                  .copyWith(color: colors.ink400, fontSize: 10)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: value > min ? () => onChanged(value - 1) : null,
                child: Icon(
                  Icons.remove_circle_outline_rounded,
                  size: 20,
                  color: value > min ? colors.ink600 : colors.ink400,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '$value',
                  style: AppTypography.heading.copyWith(color: colors.ink900),
                ),
              ),
              GestureDetector(
                onTap: value < max ? () => onChanged(value + 1) : null,
                child: Icon(
                  Icons.add_circle_outline_rounded,
                  size: 20,
                  color: value < max ? colors.goldPrimary : colors.ink400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
