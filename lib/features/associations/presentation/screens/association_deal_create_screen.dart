import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../data/models/association_model.dart';
import '../providers/association_content_providers.dart';
import '../providers/association_session_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/association_content_datasource.dart';

const _tileBlue = Color(0xFFE8EEF5);
const _tileBlueText = Color(0xFF2A4A6B);

class AssociationDealCreateScreen extends ConsumerStatefulWidget {
  const AssociationDealCreateScreen({super.key, required this.assoc});
  final AssociationModel assoc;

  @override
  ConsumerState<AssociationDealCreateScreen> createState() =>
      _AssociationDealCreateScreenState();
}

class _AssociationDealCreateScreenState
    extends ConsumerState<AssociationDealCreateScreen> {
  int _catIndex = 0;
  static const _cats = ['Package', 'Hotel', 'Transport'];

  final _destCtrl = TextEditingController();
  final _nightsCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _hotelCatCtrl = TextEditingController();

  File? _image;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _destCtrl.dispose();
    _nightsCtrl.dispose();
    _daysCtrl.dispose();
    _priceCtrl.dispose();
    _hotelCatCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _submit() async {
    final dest = _destCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    if (dest.isEmpty || price <= 0) {
      setState(() => _error = 'Enter destination and price.');
      return;
    }
    final session =
        ref.read(associationSessionProvider)[widget.assoc.id];
    if (session == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ds = AssociationContentDatasource(ref.read(dioProvider));
      await ds.createOffer(
        associationId: widget.assoc.id,
        token: session.token,
        category: _cats[_catIndex],
        destination: dest,
        nights: int.tryParse(_nightsCtrl.text) ?? 0,
        days: int.tryParse(_daysCtrl.text) ?? 0,
        price: price,
        hotelCategory: _hotelCatCtrl.text.trim(),
        imagePath: _image?.path,
      );
      ref.invalidate(associationOffersProvider);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not publish. Try again.');
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
                _Label(text: 'Category', colors: colors),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(3, (i) {
                    final sel = i == _catIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _catIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: sel
                                ? colors.goldPrimary.withValues(alpha: 0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: sel ? colors.goldPrimary : colors.lineSoft,
                              width: sel ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            _cats[i],
                            style: AppTypography.label.copyWith(
                              color: sel ? colors.ink900 : colors.ink600,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                _Label(text: 'Destination', colors: colors),
                _Field(ctrl: _destCtrl, hint: 'e.g. Bali, Indonesia', colors: colors),

                Row(
                  children: [
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _Label(text: 'Nights', colors: colors),
                      _Field(ctrl: _nightsCtrl, hint: '6', keyboardType: TextInputType.number, colors: colors),
                    ])),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _Label(text: 'Days', colors: colors),
                      _Field(ctrl: _daysCtrl, hint: '7', keyboardType: TextInputType.number, colors: colors),
                    ])),
                  ],
                ),

                _Label(text: 'Price per person (₹)', colors: colors),
                _Field(ctrl: _priceCtrl, hint: '82000', keyboardType: TextInputType.number, colors: colors),

                _Label(text: 'Hotel Category', colors: colors),
                _Field(ctrl: _hotelCatCtrl, hint: '3-star, 4-star, 5-star…', colors: colors),

                _Label(text: 'Cover Photo', colors: colors),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: _image != null ? 180 : 100,
                    decoration: BoxDecoration(
                      color: _image != null ? null : colors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.lineSoft,
                        style: _image != null ? BorderStyle.solid : BorderStyle.solid,
                        width: 1.5,
                      ),
                      image: _image != null
                          ? DecorationImage(
                              image: FileImage(_image!), fit: BoxFit.cover)
                          : null,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _image == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _tileBlue,
                                ),
                                child: const Icon(Icons.image_outlined,
                                    color: _tileBlueText, size: 16),
                              ),
                              const SizedBox(height: 8),
                              Text('Upload destination photo',
                                  style: AppTypography.label.copyWith(
                                      color: colors.ink900,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text('JPG/PNG · Max 5MB',
                                  style: AppTypography.caption
                                      .copyWith(color: colors.ink600, fontSize: 10)),
                            ],
                          )
                        : null,
                  ),
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
                        : Text('Publish Offer',
                            style: AppTypography.label.copyWith(
                                color: colors.ink900,
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center),
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
              child: Row(
                children: [
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
                    'Create Offer',
                    style: AppTypography.displayMd.copyWith(
                        color: colors.ink900,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Demand create screen ──────────────────────────────────────────────────────

class AssociationDemandCreateScreen extends ConsumerStatefulWidget {
  const AssociationDemandCreateScreen({super.key, required this.assoc});
  final AssociationModel assoc;

  @override
  ConsumerState<AssociationDemandCreateScreen> createState() =>
      _AssociationDemandCreateScreenState();
}

class _AssociationDemandCreateScreenState
    extends ConsumerState<AssociationDemandCreateScreen> {
  int _catIndex = 0;
  static const _cats = ['Package', 'Hotel', 'Transport'];

  final _destCtrl = TextEditingController();
  final _budMinCtrl = TextEditingController();
  final _budMaxCtrl = TextEditingController();
  final _paxCtrl = TextEditingController();
  final _nightsCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _destCtrl.dispose();
    _budMinCtrl.dispose();
    _budMaxCtrl.dispose();
    _paxCtrl.dispose();
    _nightsCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final dest = _destCtrl.text.trim();
    if (dest.isEmpty) {
      setState(() => _error = 'Enter destination.');
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
      await ds.createDemand(
        associationId: widget.assoc.id,
        token: session.token,
        category: _cats[_catIndex],
        destination: dest,
        budgetMin: double.tryParse(_budMinCtrl.text) ?? 0,
        budgetMax: double.tryParse(_budMaxCtrl.text) ?? 0,
        pax: int.tryParse(_paxCtrl.text) ?? 0,
        nights: int.tryParse(_nightsCtrl.text) ?? 0,
        details: _detailsCtrl.text.trim(),
      );
      ref.invalidate(associationDemandsProvider);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not post demand. Try again.');
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
                _Label(text: 'Category', colors: colors),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(3, (i) {
                    final sel = i == _catIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _catIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: sel ? colors.goldPrimary.withValues(alpha: 0.08) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: sel ? colors.goldPrimary : colors.lineSoft, width: sel ? 1.5 : 1),
                          ),
                          child: Text(_cats[i],
                              style: AppTypography.label.copyWith(
                                  color: sel ? colors.ink900 : colors.ink600,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                _Label(text: 'Destination', colors: colors),
                _Field(ctrl: _destCtrl, hint: 'e.g. Bali, Indonesia', colors: colors),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _Label(text: 'Budget Min (₹)', colors: colors),
                    _Field(ctrl: _budMinCtrl, hint: '70000', keyboardType: TextInputType.number, colors: colors),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _Label(text: 'Budget Max (₹)', colors: colors),
                    _Field(ctrl: _budMaxCtrl, hint: '85000', keyboardType: TextInputType.number, colors: colors),
                  ])),
                ]),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _Label(text: 'Pax', colors: colors),
                    _Field(ctrl: _paxCtrl, hint: '8', keyboardType: TextInputType.number, colors: colors),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _Label(text: 'Nights', colors: colors),
                    _Field(ctrl: _nightsCtrl, hint: '6', keyboardType: TextInputType.number, colors: colors),
                  ])),
                ]),
                _Label(text: 'Details', colors: colors),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: _detailsCtrl,
                    maxLines: 3,
                    style: AppTypography.body.copyWith(color: colors.ink900, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Hotel preference, inclusions, travel dates…',
                      hintStyle: AppTypography.body.copyWith(color: colors.ink400, fontSize: 13),
                      filled: true,
                      fillColor: colors.surfaceCard,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.lineSoft)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.lineSoft)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.ink900)),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  Text(_error!, style: AppTypography.caption.copyWith(color: colors.error, fontSize: 11), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                ],
                GestureDetector(
                  onTap: _loading ? null : _submit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(color: colors.goldPrimary, borderRadius: BorderRadius.circular(12)),
                    child: _loading
                        ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                        : Text('Post Demand',
                            style: AppTypography.label.copyWith(color: colors.ink900, fontSize: 14, fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              color: colors.surfacePrimary,
              padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 12),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: colors.surfaceCard, border: Border.all(color: colors.lineSoft)),
                    child: Icon(Icons.arrow_back, size: 18, color: colors.ink900),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Post Demand', style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 18, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label({required this.text, required this.colors});
  final String text;
  final AppColorScheme colors;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: AppTypography.label.copyWith(
                color: colors.ink900, fontSize: 12, fontWeight: FontWeight.w600)),
      );
}

class _Field extends StatelessWidget {
  const _Field({required this.ctrl, required this.hint, required this.colors, this.keyboardType});
  final TextEditingController ctrl;
  final String hint;
  final AppColorScheme colors;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: AppTypography.body.copyWith(color: colors.ink900, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body.copyWith(color: colors.ink400, fontSize: 13),
            filled: true,
            fillColor: colors.surfaceCard,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.lineSoft)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.lineSoft)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.ink900)),
          ),
        ),
      );
}
