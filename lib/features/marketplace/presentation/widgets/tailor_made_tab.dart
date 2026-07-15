import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/tailor_made_request_model.dart';
import '../providers/marketplace_providers.dart';

/// Tailor Made sub-tab: the member's submitted requests with a button to
/// create a new one — same flow as the old app's TailorMadeTab.
class TailorMadeTab extends ConsumerWidget {
  const TailorMadeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final requestsAsync = ref.watch(tailorMadeRequestsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      // Styled to match the marketplace 'Post Deal' pill.
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TailorMadeFormScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          decoration: BoxDecoration(
            color: colors.goldPrimary,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC9A84C).withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 16, color: AppColors.navyDeep),
              const SizedBox(width: 6),
              Text(
                'Create Request',
                style: AppTypography.label.copyWith(
                  color: AppColors.navyDeep,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 48, color: colors.ink400),
              const SizedBox(height: 12),
              Text('Could not load requests',
                  style: AppTypography.body.copyWith(color: colors.ink600)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => ref.invalidate(tailorMadeRequestsProvider),
                child: Text('Retry',
                    style: AppTypography.label.copyWith(
                        color: colors.goldPrimary,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.travel_explore_rounded,
                      size: 64, color: colors.ink400),
                  const SizedBox(height: 16),
                  Text('No Tailor Made Requests Yet',
                      style:
                          AppTypography.body.copyWith(color: colors.ink600)),
                  const SizedBox(height: 4),
                  Text('Tap the button below to create your first request',
                      style: AppTypography.caption
                          .copyWith(color: colors.ink400)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(tailorMadeRequestsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
              itemCount: requests.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RequestCard(request: requests[i], colors: colors),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.colors});
  final TailorMadeRequest request;
  final AppColorScheme colors;

  Color get _statusColor {
    switch (request.status?.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'approved':
      case 'completed':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return colors.ink400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = request.status;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  size: 18, color: colors.goldPrimary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  request.destination ?? 'Unknown',
                  style: AppTypography.heading.copyWith(color: colors.ink900),
                ),
              ),
              if (status != null && status.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: AppTypography.caption.copyWith(
                      color: _statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _chip(Icons.calendar_today_rounded,
                  _formatDate(request.travelDate)),
              _chip(Icons.timer_outlined, request.duration ?? '-'),
              _chip(Icons.people_outline_rounded,
                  '${request.adult ?? '0'}A ${request.child ?? '0'}C'),
              _chip(Icons.currency_rupee_rounded, request.budget ?? '-'),
              _chip(Icons.hotel_outlined, request.hotelCategory ?? '-'),
              _chip(Icons.restaurant_outlined, request.mealPlan ?? '-'),
            ],
          ),
          if (request.message?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text(
              request.message!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(color: colors.ink600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: colors.ink400),
        const SizedBox(width: 4),
        Text(text,
            style: AppTypography.caption
                .copyWith(color: colors.ink600, fontSize: 12)),
      ],
    );
  }
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  return '${parsed.day.toString().padLeft(2, '0')} ${_months[parsed.month - 1]} ${parsed.year}';
}

/// Full-screen form to create a tailor-made request. Sends the same body
/// as the old app's CreateTailorMadeForm so the backend contract matches.
class TailorMadeFormScreen extends ConsumerStatefulWidget {
  const TailorMadeFormScreen({super.key});

  @override
  ConsumerState<TailorMadeFormScreen> createState() =>
      _TailorMadeFormScreenState();
}

class _TailorMadeFormScreenState extends ConsumerState<TailorMadeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _travelDateCtrl = TextEditingController();
  final _adultCtrl = TextEditingController(text: '2');
  final _childCtrl = TextEditingController(text: '0');
  final _childAgeCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  String? _destination;
  String? _duration;
  String? _hotelCategory;
  String? _roomSharing;
  String? _mealPlan;
  bool _loading = false;

  static const _durations = [
    '2D/1N', '3D/2N', '4D/3N', '5D/4N', '6D/5N',
    '7D/6N', '8D/7N', '10D/9N', '12D/11N', '15D/14N',
  ];
  static const _hotelCategories = [
    '2 Star', '3 Star', '4 Star', '5 Star', 'Luxury', 'Budget',
  ];
  static const _roomSharings = ['Single', 'Double', 'Triple', 'Quad'];
  static const _mealPlans = {
    'EP': 'EP (No Meals)',
    'CP': 'CP (Breakfast)',
    'MAP': 'MAP (Breakfast + Dinner)',
    'AP': 'AP (All Meals)',
  };

  @override
  void initState() {
    super.initState();
    // Prefill contact details from the association session.
    final session = ref.read(marketplaceSessionProvider);
    _nameCtrl.text = session?.memberName ?? '';
    _emailCtrl.text = session?.memberEmail ?? '';
    _phoneCtrl.text = session?.memberPhone ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _travelDateCtrl.dispose();
    _adultCtrl.dispose();
    _childCtrl.dispose();
    _childAgeCtrl.dispose();
    _budgetCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      _travelDateCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final session = ref.read(marketplaceSessionProvider);
    if (session == null) return; // gate prevents this path
    setState(() => _loading = true);
    try {
      await ref.read(marketplaceDatasourceProvider).submitTailorMade({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'destination': _destination,
        'travelDate': _travelDateCtrl.text.trim(),
        'duration': _duration,
        'adult': _adultCtrl.text.trim(),
        'child': _childCtrl.text.trim(),
        'childAge': _childAgeCtrl.text.trim(),
        'budget': _budgetCtrl.text.trim(),
        'hotelCategory': _hotelCategory,
        'roomSharing': _roomSharing,
        'mealPlan': _mealPlan,
        'message': _messageCtrl.text.trim(),
        'memberId': session.memberId,
      }, token: session.token);
      ref.invalidate(tailorMadeRequestsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tailor Made request submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit request. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final destinationsAsync = ref.watch(tailorMadeDestinationsProvider);

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        foregroundColor: colors.ink900,
        title: Text('Tailor Made Request',
            style: AppTypography.heading.copyWith(color: colors.ink900)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _section('Personal Details', colors),
              const SizedBox(height: 12),
              _field(_nameCtrl, 'Full Name', colors, req: true),
              const SizedBox(height: 12),
              _field(_emailCtrl, 'Email', colors,
                  req: true, keyboard: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _field(_phoneCtrl, 'Phone', colors,
                  req: true, keyboard: TextInputType.phone),
              const SizedBox(height: 20),
              _section('Trip Details', colors),
              const SizedBox(height: 12),
              destinationsAsync.when(
                loading: () => _dropdown(
                    'Destination', const [], null, (_) {}, colors),
                error: (_, __) => _dropdown(
                    'Destination', const [], null, (_) {}, colors),
                data: (destinations) => _dropdown(
                  'Destination',
                  destinations,
                  _destination,
                  (v) => setState(() => _destination = v),
                  colors,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _travelDateCtrl,
                readOnly: true,
                onTap: _pickDate,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Select travel date' : null,
                style: AppTypography.body.copyWith(color: colors.ink900),
                decoration: _decoration('Travel Date', colors).copyWith(
                  suffixIcon: Icon(Icons.calendar_today_rounded,
                      size: 18, color: colors.ink400),
                ),
              ),
              const SizedBox(height: 12),
              _dropdown('Duration', _durations, _duration,
                  (v) => setState(() => _duration = v), colors),
              const SizedBox(height: 20),
              _section('Travellers', colors),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _field(_adultCtrl, 'Adults', colors,
                          req: true, keyboard: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field(_childCtrl, 'Children', colors,
                          keyboard: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field(_childAgeCtrl, 'Child Age', colors,
                          keyboard: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 20),
              _section('Preferences', colors),
              const SizedBox(height: 12),
              _field(_budgetCtrl, 'Budget (₹)', colors,
                  req: true, keyboard: TextInputType.number),
              const SizedBox(height: 12),
              _dropdown('Hotel Category', _hotelCategories, _hotelCategory,
                  (v) => setState(() => _hotelCategory = v), colors),
              const SizedBox(height: 12),
              _dropdown('Room Sharing', _roomSharings, _roomSharing,
                  (v) => setState(() => _roomSharing = v), colors),
              const SizedBox(height: 12),
              _dropdown(
                'Meal Plan',
                _mealPlans.keys.toList(),
                _mealPlan,
                (v) => setState(() => _mealPlan = v),
                colors,
                labelOf: (v) => _mealPlans[v] ?? v,
              ),
              const SizedBox(height: 12),
              _field(_messageCtrl, 'Message / Special Requirements', colors,
                  maxLines: 3),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.goldPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text('Submit Request',
                        style: AppTypography.heading
                            .copyWith(color: Colors.white)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, AppColorScheme colors) {
    return Text(title,
        style: AppTypography.heading.copyWith(color: colors.ink900));
  }

  InputDecoration _decoration(String label, AppColorScheme colors) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.caption.copyWith(color: colors.ink400),
      filled: true,
      fillColor: colors.surfaceCard,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

  Widget _field(
    TextEditingController ctrl,
    String label,
    AppColorScheme colors, {
    bool req = false,
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: req
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
      style: AppTypography.body.copyWith(color: colors.ink900),
      decoration: _decoration(label, colors),
    );
  }

  Widget _dropdown(
    String label,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
    AppColorScheme colors, {
    String Function(String)? labelOf,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items
          .map((d) => DropdownMenuItem(
                value: d,
                child: Text(labelOf?.call(d) ?? d,
                    style: AppTypography.body.copyWith(color: colors.ink900)),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Required' : null,
      dropdownColor: colors.surfaceCard,
      decoration: _decoration(label, colors),
    );
  }
}
