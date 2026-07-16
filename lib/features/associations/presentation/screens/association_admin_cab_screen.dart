import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/association_content_datasource.dart';
import '../../data/models/association_content_model.dart';
import '../../data/models/association_model.dart';
import '../providers/association_content_providers.dart';
import '../providers/association_session_provider.dart';

const _tileBlue = Color(0xFFE8EEF5);
const _tileBlueText = Color(0xFF2A4A6B);

/// Admin Cab — mirrors the old app's UploadCabList screen:
/// two tabs ("Admin Cab" = my vehicles with manage actions,
/// "All Cab" = association-wide list with API search).
class AssociationAdminCabScreen extends ConsumerStatefulWidget {
  const AssociationAdminCabScreen({super.key, required this.assoc});
  final AssociationModel assoc;

  @override
  ConsumerState<AssociationAdminCabScreen> createState() =>
      _AssociationAdminCabScreenState();
}

class _AssociationAdminCabScreenState
    extends ConsumerState<AssociationAdminCabScreen> {
  int _tabIdx = 0; // 0 = Admin Cab, 1 = All Cab
  bool _showAvailableOnly = true; // old app default: available cars
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  bool _busy = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _searchQuery = q.trim());
    });
  }

  Future<void> _runAction(
      Future<void> Function(AssociationContentDatasource ds, String token)
          action) async {
    final session = ref.read(associationSessionProvider)[widget.assoc.id];
    if (session == null || _busy) return;
    setState(() => _busy = true);
    try {
      final ds = AssociationContentDatasource(ref.read(dioProvider));
      await action(ds, session.token);
      ref.invalidate(associationMyVehiclesProvider);
      ref.invalidate(associationAllVehiclesProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Action failed. Try again.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openUpload() {
    context.push(
      RouteNames.associationCabUpload.replaceFirst(':id', widget.assoc.id),
      extra: widget.assoc,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Column(
        children: [
          // ── App bar
          Padding(
            padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 12),
            child: Row(children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surfaceCard,
                    border: Border.all(color: colors.lineSoft),
                  ),
                  child: Icon(Icons.arrow_back, size: 18, color: colors.ink900),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Admin Cab',
                style: AppTypography.displayMd.copyWith(
                  color: colors.ink900,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ]),
          ),

          // ── Tabs (Admin Cab / All Cab — same as old app)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: List.generate(2, (i) {
                final label = i == 0 ? 'Admin Cab' : 'All Cab';
                final active = i == _tabIdx;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tabIdx = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? colors.ink900 : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: active ? colors.ink900 : colors.lineSoft),
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: AppTypography.label.copyWith(
                          color: active ? colors.surfacePrimary : colors.ink600,
                          fontSize: 12,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          Expanded(child: _tabIdx == 0 ? _adminTab(colors) : _allTab(colors)),
        ],
      ),
    );
  }

  // ── Tab 1: my vehicles with manage actions ────────────────────────────────

  Widget _adminTab(AppColorScheme colors) {
    final async = ref.watch(associationMyVehiclesProvider(widget.assoc.id));
    final myMemberId =
        ref.watch(associationSessionProvider)[widget.assoc.id]?.memberId;
    return Column(
      children: [
        // Available / Not Available filter (old app's ToggleButtons)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: List.generate(2, (i) {
              final label = i == 0 ? 'Available' : 'Not Available';
              final active = (i == 0) == _showAvailableOnly;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _showAvailableOnly = i == 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? colors.goldPrimary.withValues(alpha: 0.10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: active ? colors.goldPrimary : colors.lineSoft),
                    ),
                    child: Text(
                      label,
                      style: AppTypography.label.copyWith(
                        color: active ? colors.ink900 : colors.ink600,
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => _shimmerList(colors),
            error: (_, __) => _retry(
                colors, () => ref.invalidate(associationMyVehiclesProvider)),
            data: (all) {
              final vehicles = all
                  .where((v) => v.isAvailable == _showAvailableOnly)
                  .toList();
              if (vehicles.isEmpty) {
                return _emptyState(
                    colors,
                    _showAvailableOnly
                        ? 'No available cars'
                        : 'No unavailable cars');
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: vehicles.length,
                itemBuilder: (_, i) {
                  // Manage actions only on entries posted by this member
                  final mine =
                      myMemberId != null && vehicles[i].memberId == myMemberId;
                  return _VehicleCard(
                    vehicle: vehicles[i],
                    colors: colors,
                    onDelete: mine
                        ? () => _runAction((ds, token) => ds.deleteVehicle(
                            vehicleId: vehicles[i].id, token: token))
                        : null,
                    onToggle: mine
                        ? () => _runAction((ds, token) =>
                            ds.toggleVehicleAvailability(
                                vehicleId: vehicles[i].id, token: token))
                        : null,
                  );
                },
              );
            },
          ),
        ),
        // Add Cab — the screen's single primary CTA
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: GestureDetector(
            onTap: _busy ? null : () => _openUpload(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: colors.goldPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _busy
                  ? const Center(
                      child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white)))
                  : Text('Add Cab',
                      textAlign: TextAlign.center,
                      style: AppTypography.label.copyWith(
                          color: colors.ink900,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Tab 2: association-wide list with API search ──────────────────────────

  Widget _allTab(AppColorScheme colors) {
    final async = ref.watch(associationAllVehiclesProvider(
        (assocId: widget.assoc.id, query: _searchQuery)));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: TextField(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            style:
                AppTypography.body.copyWith(color: colors.ink900, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search vehicles…',
              hintStyle: AppTypography.body
                  .copyWith(color: colors.ink400, fontSize: 13),
              prefixIcon: Icon(Icons.search, size: 18, color: colors.ink400),
              filled: true,
              fillColor: colors.surfaceCard,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.lineSoft)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.lineSoft)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.ink900)),
            ),
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => _shimmerList(colors),
            error: (_, __) => _retry(
                colors, () => ref.invalidate(associationAllVehiclesProvider)),
            data: (vehicles) => vehicles.isEmpty
                ? _emptyState(colors, 'No vehicles found')
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: vehicles.length,
                    itemBuilder: (_, i) =>
                        _VehicleCard(vehicle: vehicles[i], colors: colors),
                  ),
          ),
        ),
      ],
    );
  }

  // ── Shared states ─────────────────────────────────────────────────────────

  Widget _shimmerList(AppColorScheme colors) => ListView.builder(
        itemCount: 4,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: colors.surfaceTertiary,
          highlightColor: colors.surfaceCard,
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            height: 96,
            decoration: BoxDecoration(
                color: colors.surfaceCard,
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );

  Widget _retry(AppColorScheme colors, VoidCallback onTap) => Center(
        child: GestureDetector(
          onTap: onTap,
          child: Text('Retry',
              style: AppTypography.label.copyWith(
                  color: colors.goldPrimary, fontWeight: FontWeight.w600)),
        ),
      );

  Widget _emptyState(AppColorScheme colors, String msg) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: colors.surfaceTertiary),
            child: Icon(Icons.directions_car_outlined,
                color: colors.ink400, size: 28),
          ),
          const SizedBox(height: 14),
          Text(msg,
              style: AppTypography.body.copyWith(
                  color: colors.ink600,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ]),
      );
}

// ── Vehicle card ──────────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.colors,
    this.onDelete,
    this.onToggle,
  });

  final AssociationVehicleModel vehicle;
  final AppColorScheme colors;
  final VoidCallback? onDelete;
  final VoidCallback? onToggle;

  // No edit: backend has no update API the app can rely on
  bool get _managed => onToggle != null;

  @override
  Widget build(BuildContext context) {
    final available = vehicle.isAvailable;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.lineSoft),
      ),
      clipBehavior: Clip.antiAlias,
      // IntrinsicHeight bounds the stretch axis — ListView gives unbounded height
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 96,
              child: vehicle.images.isEmpty
                  ? Container(
                      color: colors.surfaceTertiary,
                      child: Icon(Icons.directions_car_outlined,
                          color: colors.ink400, size: 28),
                    )
                  : CachedNetworkImage(
                      imageUrl: vehicle.images.first,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: colors.surfaceTertiary),
                      errorWidget: (_, __, ___) => Container(
                          color: colors.surfaceTertiary,
                          child: Icon(Icons.broken_image_outlined,
                              color: colors.ink400, size: 22)),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(vehicle.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body.copyWith(
                                color: colors.ink900,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                      if (_managed)
                        GestureDetector(
                          onTap: onDelete,
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: Icon(Icons.delete_outline,
                                size: 18, color: colors.ink600),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: _tileBlue,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(vehicle.type,
                              style: const TextStyle(
                                  color: _tileBlueText,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        Text(vehicle.year,
                            style: AppTypography.caption
                                .copyWith(color: colors.ink600, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(available ? 'Available' : 'Not Available',
                            style: AppTypography.caption.copyWith(
                                color:
                                    available ? colors.success : colors.error,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                        if (_managed)
                          SizedBox(
                            height: 24,
                            child: Transform.scale(
                              scale: 0.75,
                              alignment: Alignment.centerRight,
                              child: Switch(
                                value: available,
                                activeThumbColor: Colors.white,
                                activeTrackColor: colors.success,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: colors.error,
                                trackOutlineColor:
                                    const WidgetStatePropertyAll(
                                        Colors.transparent),
                                onChanged: (_) => onToggle!(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Upload / edit form — mirrors old app's UploadCabs ─────────────────────────

// Static option lists copied verbatim from the old app.
const _carList = [
  'Hyundai - Cresta',
  'Hyundai - i20',
  'Hyundai - Creta',
  'Toyota - Fortuner',
  'Toyota - Innova Crysta',
  'Honda - City',
  'Honda - Amaze',
  'Tata - Harrier',
  'Mahindra - XUV700',
  'Ford - Mustang',
  'Kia - Seltos',
  'Volkswagen - Polo',
  'Skoda - Octavia',
  'Mercedes-Benz - C-Class',
  'BMW - X1',
  'Audi - Q3',
];

const _carTypes = [
  'Sedan',
  'Hatchback',
  'SUV',
  'Crossover',
  'Coupe',
  'Convertible',
  'Pickup Truck',
  'Minivan',
  'Station Wagon',
  'Electric',
  'Hybrid',
  'Luxury',
  'Sports Car',
  'Off-Road',
  'Compact',
  'Microcar',
  'Roadster',
  'Muscle Car',
  'Diesel',
  'Van',
];

class AssociationCabUploadScreen extends ConsumerStatefulWidget {
  const AssociationCabUploadScreen({super.key, required this.assoc});
  final AssociationModel assoc;

  @override
  ConsumerState<AssociationCabUploadScreen> createState() =>
      _AssociationCabUploadScreenState();
}

class _AssociationCabUploadScreenState
    extends ConsumerState<AssociationCabUploadScreen> {
  static final _years =
      List.generate(45, (i) => (1980 + i).toString()).reversed.toList();

  String? _car;
  String? _type;
  String? _year;
  File? _image;
  bool _loading = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker()
        .pickImage(source: source, imageQuality: 80, maxWidth: 1200);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _submit() async {
    if (_car == null || _type == null || _year == null) {
      setState(() => _error = 'Select car, type and year.');
      return;
    }
    final session = ref.read(associationSessionProvider)[widget.assoc.id];
    if (session == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ds = AssociationContentDatasource(ref.read(dioProvider));
      // ponytail: edit posts addVehicle too — old app had no update endpoint
      await ds.addVehicle(
        associationId: widget.assoc.id,
        token: session.token,
        name: _car!,
        type: _type!,
        year: _year!,
        imagePath: _image?.path,
      );
      ref.invalidate(associationMyVehiclesProvider);
      ref.invalidate(associationAllVehiclesProvider);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not upload. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, topPad + 64, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _label('Car', colors),
                _dropdown(
                    value: _car,
                    hint: 'Select Car',
                    items: _carList,
                    onChanged: (v) => setState(() => _car = v),
                    colors: colors),
                _label('Car Type', colors),
                _dropdown(
                    value: _type,
                    hint: 'Select Car Type',
                    items: _carTypes,
                    onChanged: (v) => setState(() => _type = v),
                    colors: colors),
                _label('Year', colors),
                _dropdown(
                    value: _year,
                    hint: 'Select Year',
                    items: _years,
                    onChanged: (v) => setState(() => _year = v),
                    colors: colors),
                _label('Photo', colors),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colors.surfaceCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.lineSoft),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _image != null
                          ? Image.file(_image!, fit: BoxFit.cover)
                          : Icon(Icons.image_outlined,
                              color: colors.ink400, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _photoButton(
                              'Take a Picture',
                              Icons.camera_alt_outlined,
                              () => _pick(ImageSource.camera),
                              colors),
                          const SizedBox(height: 8),
                          _photoButton(
                              'Pick from Gallery',
                              Icons.photo_outlined,
                              () => _pick(ImageSource.gallery),
                              colors),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_error != null) ...[
                  Text(_error!,
                      style: AppTypography.caption
                          .copyWith(color: colors.error, fontSize: 11),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                ],
                GestureDetector(
                  onTap: _loading ? null : _submit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: colors.goldPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _loading
                        ? const Center(
                            child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white)))
                        : Text('Upload',
                            textAlign: TextAlign.center,
                            style: AppTypography.label.copyWith(
                                color: colors.ink900,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: colors.surfacePrimary,
              padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 12),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.surfaceCard,
                        border: Border.all(color: colors.lineSoft)),
                    child:
                        Icon(Icons.arrow_back, size: 18, color: colors.ink900),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Upload Cab',
                    style: AppTypography.displayMd.copyWith(
                        color: colors.ink900,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, AppColorScheme colors) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: AppTypography.label.copyWith(
                color: colors.ink900,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      );

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required AppColorScheme colors,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          hint: Text(hint,
              style: AppTypography.body
                  .copyWith(color: colors.ink400, fontSize: 13)),
          dropdownColor: colors.surfaceCard,
          style:
              AppTypography.body.copyWith(color: colors.ink900, fontSize: 13),
          icon: Icon(Icons.keyboard_arrow_down, color: colors.ink600),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surfaceCard,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.lineSoft)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.lineSoft)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.ink900)),
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      );

  Widget _photoButton(String label, IconData icon, VoidCallback onTap,
          AppColorScheme colors) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.lineSoft),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: colors.ink900),
              const SizedBox(width: 8),
              Text(label,
                  style: AppTypography.label.copyWith(
                      color: colors.ink900,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}
