import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/dmc_datasource.dart';
import '../../data/models/dmc_model.dart';
import 'dmc_card.dart';

/// DMC directory browse — country/state filter + supplier list.
///
/// Rendered in place of the association list when the 'DMC' filter pill is
/// active on [AssociationsScreen]. Public directory, no association session
/// required (matches the old app's DMC tab).
class AssociationDmcBrowseSection extends ConsumerStatefulWidget {
  const AssociationDmcBrowseSection({super.key, required this.colors});
  final AppColorScheme colors;

  @override
  ConsumerState<AssociationDmcBrowseSection> createState() =>
      _AssociationDmcBrowseSectionState();
}

class _AssociationDmcBrowseSectionState
    extends ConsumerState<AssociationDmcBrowseSection> {
  late final DmcDatasource _ds;

  bool _loadingCountries = false;
  bool _loadingStates = false;
  bool _loadingList = false;

  List<String> _countries = [];
  List<String> _states = [];
  List<DmcModel> _dmcList = [];

  String? _selectedCountry;
  String? _selectedState;

  @override
  void initState() {
    super.initState();
    _ds = DmcDatasource(ref.read(dioProvider));
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    setState(() => _loadingCountries = true);
    try {
      _countries = await _ds.fetchCountries();
    } catch (_) {
      // ponytail: silent fail matches old app; the empty-state below covers it
    } finally {
      if (mounted) setState(() => _loadingCountries = false);
    }
  }

  Future<void> _onCountrySelected(String country) async {
    setState(() {
      _selectedCountry = country;
      _selectedState = null;
      _states = [];
      _dmcList = [];
      _loadingStates = true;
    });
    try {
      _states = await _ds.fetchStates(country);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingStates = false);
    }
  }

  Future<void> _onStateSelected(String state) async {
    setState(() {
      _selectedState = state;
      _dmcList = [];
      _loadingList = true;
    });
    try {
      _dmcList = await _ds.fetchDmcList(_selectedCountry!, state);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingList = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => context.push(RouteNames.dmcRegister),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: colors.goldPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.app_registration, size: 16, color: colors.ink900),
                    const SizedBox(width: 8),
                    Text(
                      'Register as DMC',
                      style: AppTypography.label.copyWith(
                        color: colors.ink900,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _DropdownField(
                  label: 'Select Country',
                  icon: Icons.public,
                  isLoading: _loadingCountries,
                  items: _countries,
                  selected: _selectedCountry,
                  colors: colors,
                  onChanged: _onCountrySelected,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DropdownField(
                  label: 'Select State',
                  icon: Icons.map_outlined,
                  isLoading: _loadingStates,
                  items: _states,
                  selected: _selectedState,
                  enabled: _selectedCountry != null,
                  colors: colors,
                  onChanged: _onStateSelected,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildBody(colors),
      ],
    );
  }

  Widget _buildBody(AppColorScheme colors) {
    if (_loadingList) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_selectedCountry == null) {
      return _emptyState(colors, Icons.public,
          'Select a Country', 'Choose a country and state to view DMC listings in that region');
    }
    if (_selectedState == null) {
      return _emptyState(
          colors, Icons.map_outlined, 'Select a State', 'Choose a state to view DMC listings');
    }
    if (_dmcList.isEmpty) {
      return _emptyState(colors, Icons.search_off_rounded, 'No DMC Found',
          'No Destination Management Companies found for the selected region');
    }
    return Column(
      children: _dmcList.map((dmc) => DmcCard(dmc: dmc, colors: colors)).toList(),
    );
  }

  Widget _emptyState(AppColorScheme colors, IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        children: [
          Icon(icon, size: 48, color: colors.ink400),
          const SizedBox(height: 14),
          Text(title,
              style: AppTypography.body.copyWith(
                  color: colors.ink900, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 12)),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.items,
    required this.selected,
    required this.colors,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final bool isLoading;
  final List<String> items;
  final String? selected;
  final AppColorScheme colors;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: enabled ? colors.surfaceCard : colors.surfaceTertiary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.lineSoft),
      ),
      child: isLoading
          ? Center(
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: colors.goldPrimary),
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                isDense: true,
                hint: Row(
                  children: [
                    Icon(icon, size: 16, color: enabled ? colors.ink600 : colors.ink400),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        label,
                        style: AppTypography.caption.copyWith(
                          color: enabled ? colors.ink600 : colors.ink400,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                value: selected,
                items: items
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: AppTypography.body.copyWith(color: colors.ink900, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: enabled ? (v) { if (v != null) onChanged(v); } : null,
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: enabled ? colors.ink600 : colors.ink400),
              ),
            ),
    );
  }
}
