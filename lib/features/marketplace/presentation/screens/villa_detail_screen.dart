import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../data/datasources/marketplace_remote_datasource.dart';
import '../../data/models/villa_rate_model.dart';
import '../../data/models/villa_rate_plan_model.dart';
import '../providers/marketplace_providers.dart';

// Same live key the old app ships for villa payments.
const String _villaRazorpayKey = 'rzp_live_SJyy6qt0I2DKtU';

class VillaDetailScreen extends ConsumerStatefulWidget {
  const VillaDetailScreen({super.key, required this.rate});

  final VillaRateModel rate;

  @override
  ConsumerState<VillaDetailScreen> createState() => _VillaDetailScreenState();
}

class _VillaDetailScreenState extends ConsumerState<VillaDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openBookingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VillaBookingSheet(rate: widget.rate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final rate = widget.rate;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: colors.surfaceCard,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: rate.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: rate.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: colors.navyDeep,
                        child: const Center(
                          child: Icon(Icons.villa_rounded,
                              size: 64, color: Colors.white54),
                        ),
                      ),
                    )
                  : Container(
                      color: colors.navyDeep,
                      child: const Center(
                        child: Icon(Icons.villa_rounded,
                            size: 64, color: Colors.white54),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property name + city
                  Text(
                    rate.propertyName,
                    style: AppTypography.displayMd.copyWith(color: colors.ink900),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: colors.ink400),
                      const SizedBox(width: 4),
                      Text(rate.fullLocation,
                          style: AppTypography.body.copyWith(color: colors.ink400)),
                      if (rate.ratePlanCode.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.goldPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            rate.ratePlanCode,
                            style: AppTypography.label
                                .copyWith(color: colors.goldPrimary, fontSize: 9),
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (rate.numberOfOffers > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.local_offer_outlined,
                            size: 14, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          '${rate.numberOfOffers} special offer${rate.numberOfOffers > 1 ? 's' : ''} available',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.success),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Tabs
                  TabBar(
                    controller: _tabController,
                    labelColor: colors.ink900,
                    unselectedLabelColor: colors.ink400,
                    indicatorColor: colors.goldPrimary,
                    labelStyle: AppTypography.label,
                    unselectedLabelStyle: AppTypography.label,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Amenities'),
                      Tab(text: 'Rules'),
                      Tab(text: 'Location'),
                    ],
                  ),
                  const Divider(height: 1),

                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Overview — API description is HTML
                        rate.description.isNotEmpty
                            ? _HtmlTabContent(html: rate.description)
                            : _TabContent(
                                text:
                                    'Experience luxury villa living with premium amenities and personalised service in ${rate.fullLocation}.',
                              ),
                        _AmenitiesTab(amenities: rate.topAmenities),
                        const _RulesTab(),
                        _LocationTab(rate: rate),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom padding so content clears the sticky bar
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          border: Border(top: BorderSide(color: colors.lineSoft)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Starting from',
                    style: AppTypography.caption.copyWith(color: colors.ink400)),
                Text(
                  '${rate.currency} ${rate.amount.toStringAsFixed(0)}',
                  style: AppTypography.heading.copyWith(
                    color: colors.goldPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: rate.soldOut ? null : _openBookingSheet,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.goldPrimary,
                  disabledBackgroundColor: colors.lineSoft,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(rate.soldOut ? 'Sold Out' : 'Book Now',
                    style: AppTypography.heading.copyWith(
                        color:
                            rate.soldOut ? colors.ink400 : Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        style: AppTypography.body.copyWith(color: colors.ink600, height: 1.6),
      ),
    );
  }
}

class _HtmlTabContent extends StatelessWidget {
  const _HtmlTabContent({required this.html});
  final String html;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: HtmlWidget(
        html,
        textStyle:
            AppTypography.body.copyWith(color: colors.ink600, height: 1.6),
      ),
    );
  }
}

class _AmenitiesTab extends StatelessWidget {
  const _AmenitiesTab({required this.amenities});
  final List<String> amenities;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    if (amenities.isEmpty) {
      return const _TabContent(
        text:
            'Amenity details are shared by the villa host. Contact our team for the full list.',
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: amenities
            .map(
              (name) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: colors.lineSoft),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded,
                        size: 14, color: colors.goldPrimary),
                    const SizedBox(width: 6),
                    Text(
                      name,
                      style: AppTypography.body
                          .copyWith(color: colors.ink900, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _RulesTab extends StatelessWidget {
  const _RulesTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: const [
          _IconTextRow(
            icon: Icons.assignment_outlined,
            text:
                'House rules and check-in details are shared by the villa host after booking confirmation.',
          ),
          SizedBox(height: 12),
          _IconTextRow(
            icon: Icons.support_agent_outlined,
            text:
                'Contact our team for specific requirements such as pets, events, or early check-in.',
          ),
        ],
      ),
    );
  }
}

class _LocationTab extends StatelessWidget {
  const _LocationTab({required this.rate});
  final VillaRateModel rate;

  @override
  Widget build(BuildContext context) {
    final area = [rate.location, rate.city, rate.state]
        .where((s) => s.isNotEmpty)
        .toSet()
        .join(', ');
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          if (rate.streetLine.isNotEmpty) ...[
            _IconTextRow(
                icon: Icons.location_on_outlined, text: rate.streetLine),
            const SizedBox(height: 12),
          ],
          if (area.isNotEmpty) ...[
            _IconTextRow(icon: Icons.map_outlined, text: area),
            const SizedBox(height: 12),
          ],
          const _IconTextRow(
            icon: Icons.directions_outlined,
            text:
                'Exact directions are shared by our team after booking confirmation.',
          ),
        ],
      ),
    );
  }
}

class _IconTextRow extends StatelessWidget {
  const _IconTextRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.goldPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colors.goldPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: AppTypography.body
                  .copyWith(color: colors.ink600, height: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Booking Bottom Sheet ──────────────────────────────────────────────────────

class _VillaBookingSheet extends ConsumerStatefulWidget {
  const _VillaBookingSheet({required this.rate});
  final VillaRateModel rate;

  @override
  ConsumerState<_VillaBookingSheet> createState() => _VillaBookingSheetState();
}

class _VillaBookingSheetState extends ConsumerState<_VillaBookingSheet> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  VillaRatePlanModel? _selectedPlan;
  bool _loading = false;

  // Booking dates — editable so villas opened from the dateless "Suggested
  // Villas" list can still be booked.
  late String _checkin = widget.rate.checkin;
  late String _checkout = widget.rate.checkout;

  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _razorpay.clear();
    super.dispose();
  }

  VillaRatePlanParams get _ratePlanParams => (
        propertyId: widget.rate.propertyId,
        city: widget.rate.city,
        checkin: _checkin,
        checkout: _checkout,
        adults: widget.rate.adults,
        children: widget.rate.children,
      );

  bool get _hasDates => _checkin.isNotEmpty && _checkout.isNotEmpty;

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate({required bool isCheckin}) async {
    final now = DateTime.now();
    final current = DateTime.tryParse(isCheckin ? _checkin : _checkout);
    final first = isCheckin
        ? now
        : (DateTime.tryParse(_checkin)?.add(const Duration(days: 1)) ?? now);
    var initial = current ?? first;
    if (initial.isBefore(first)) initial = first;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckin) {
        _checkin = _formatDate(picked);
        final checkout = DateTime.tryParse(_checkout);
        if (checkout == null || !checkout.isAfter(picked)) {
          _checkout = _formatDate(picked.add(const Duration(days: 1)));
        }
      } else {
        _checkout = _formatDate(picked);
      }
      // Plans are date-specific; force a fresh selection.
      _selectedPlan = null;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  Future<void> _proceedToPayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_checkin.isEmpty || _checkout.isEmpty) {
      _showError('Please select check-in and check-out dates');
      return;
    }
    final plan = _selectedPlan;
    if (plan == null || plan.id.trim().isEmpty) {
      _showError('Please select a rate plan');
      return;
    }
    setState(() => _loading = true);
    try {
      final ds = ref.read(marketplaceDatasourceProvider);
      final amountInPaise = plan.payableInPaise;
      final orderId = await ds.createVillaPaymentOrder(amountInPaise);
      if (orderId.isEmpty) {
        throw Exception('Unable to create Razorpay order');
      }
      final options = {
        'key': _villaRazorpayKey,
        'amount': amountInPaise,
        'currency': 'INR',
        'order_id': orderId,
        'name': 'Travel World Online',
        'description': '${widget.rate.propertyName} – ${plan.ratePlanCode}',
        'prefill': {
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'contact': _phoneCtrl.text.trim(),
        },
        'external': {
          'wallets': ['paytm'],
        },
        'theme': {'color': '#C9A84C'},
      };
      _razorpay.open(options);
    } catch (e) {
      if (mounted) {
        _showError('Payment setup failed: $e');
        setState(() => _loading = false);
      }
    }
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    final paymentId = (response.paymentId ?? '').trim();
    final plan = _selectedPlan;
    if (plan == null || plan.id.trim().isEmpty || paymentId.isEmpty) {
      if (mounted) {
        setState(() => _loading = false);
        _showError('Payment verification failed: booking reference missing. '
            'Contact support with payment ID $paymentId.');
      }
      return;
    }
    setState(() => _loading = true);
    try {
      final ds = ref.read(marketplaceDatasourceProvider);
      await ds.submitVillaBooking(buildVillaBookingBody(
        quoteId: plan.id,
        guestName: _nameCtrl.text.trim(),
        guestEmail: _emailCtrl.text.trim(),
        guestPhone: _phoneCtrl.text.trim(),
        transactionId: paymentId,
        paidAmountRupees: plan.netAfterTax.round(),
      ));
      if (mounted) {
        Navigator.of(context).pop(); // close sheet
        _showSuccessDialog();
      }
    } catch (_) {
      // Payment went through but the booking API rejected it — never fake
      // success here; the user needs the payment ID to follow up.
      if (mounted) {
        _showError('Payment received, but the booking could not be '
            'confirmed. Contact support with payment ID $paymentId.');
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response.message ?? 'Unknown error'}'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _loading = false);
    }
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    // No action needed
  }

  void _showSuccessDialog() {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                size: 64, color: AppColors.success),
            const SizedBox(height: 16),
            Text('Booking Confirmed!',
                style: AppTypography.heading.copyWith(color: colors.ink900),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Your villa booking for ${widget.rate.propertyName} has been confirmed. You will receive a confirmation email shortly.',
              style: AppTypography.body.copyWith(color: colors.ink600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Done',
                style: AppTypography.heading.copyWith(color: colors.goldPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final plansAsync = ref.watch(villaRatePlansProvider(_ratePlanParams));

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.lineSoft,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Text(
                  'Book ${widget.rate.propertyName}',
                  style: AppTypography.heading.copyWith(color: colors.ink900),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Stay summary — dates are editable
                        _InfoRow(
                            colors: colors,
                            icon: Icons.calendar_today_outlined,
                            label: 'Check-in',
                            value: _checkin,
                            onTap: () => _pickDate(isCheckin: true)),
                        const SizedBox(height: 8),
                        _InfoRow(
                            colors: colors,
                            icon: Icons.calendar_today_outlined,
                            label: 'Check-out',
                            value: _checkout,
                            onTap: () => _pickDate(isCheckin: false)),
                        const SizedBox(height: 8),
                        _InfoRow(colors: colors, icon: Icons.people_outline_rounded,
                            label: 'Guests',
                            value: '${widget.rate.adults} adults, ${widget.rate.children} children'),
                        const SizedBox(height: 20),

                        // Rate plan selection
                        Text('Select Rate Plan',
                            style: AppTypography.heading
                                .copyWith(color: colors.ink900)),
                        const SizedBox(height: 12),
                        if (!_hasDates)
                          Text(
                            'Select check-in and check-out dates to see rate plans.',
                            style: AppTypography.body
                                .copyWith(color: colors.ink600),
                          )
                        else
                          plansAsync.when(
                            loading: () => const Center(
                                child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            )),
                            error: (_, __) => Text(
                              'Could not load rate plans. Please try again.',
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.error),
                            ),
                            data: (plans) {
                              if (plans.isEmpty) {
                                return Text(
                                  'No rate plans available for these dates. Try different dates.',
                                  style: AppTypography.body
                                      .copyWith(color: colors.ink600),
                                );
                              }
                              return Column(
                                children: plans.map((plan) {
                                  final selected = _selectedPlan?.id == plan.id;
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedPlan = plan),
                                    child: _RatePlanCard(
                                      plan: plan,
                                      selected: selected,
                                      colors: colors,
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),

                        const SizedBox(height: 20),

                        // Guest details
                        Text('Guest Details',
                            style: AppTypography.heading
                                .copyWith(color: colors.ink900)),
                        const SizedBox(height: 12),
                        _FormField(
                          controller: _nameCtrl,
                          label: 'Full Name',
                          colors: colors,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        _FormField(
                          controller: _emailCtrl,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          colors: colors,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        _FormField(
                          controller: _phoneCtrl,
                          label: 'Phone',
                          keyboardType: TextInputType.phone,
                          colors: colors,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),

                        const SizedBox(height: 24),

                        // Payment button
                        FilledButton(
                          onPressed: _loading ? null : _proceedToPayment,
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.goldPrimary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  _selectedPlan != null
                                      ? 'Pay ${widget.rate.currency} ${_selectedPlan!.netAfterTax.toStringAsFixed(0)} & Confirm'
                                      : 'Select a Rate Plan to Continue',
                                  style: AppTypography.heading
                                      .copyWith(color: Colors.white),
                                ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RatePlanCard extends StatelessWidget {
  const _RatePlanCard(
      {required this.plan, required this.selected, required this.colors});
  final VillaRatePlanModel plan;
  final bool selected;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected
            ? colors.goldPrimary.withValues(alpha: 0.06)
            : colors.surfacePrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? colors.goldPrimary : colors.lineSoft,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? colors.goldPrimary : colors.ink400,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  plan.displayName.isNotEmpty
                      ? plan.displayName
                      : plan.ratePlanCode,
                  style: AppTypography.heading.copyWith(color: colors.ink900),
                ),
              ),
              Text(
                '₹ ${plan.netAfterTax.toStringAsFixed(0)}',
                style: AppTypography.heading.copyWith(
                  color: colors.goldPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (plan.numberOfNights > 0 || plan.numberOfGuests > 0) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                [
                  if (plan.numberOfNights > 0) '${plan.numberOfNights} night${plan.numberOfNights > 1 ? 's' : ''}',
                  if (plan.numberOfGuests > 0) '${plan.numberOfGuests} guest${plan.numberOfGuests > 1 ? 's' : ''}',
                ].join(' · '),
                style: AppTypography.caption.copyWith(color: colors.ink400),
              ),
            ),
          ],
          if (selected) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            _PriceLine(label: 'Base amount',
                value: plan.netBeforeTax, colors: colors),
            _PriceLine(label: 'GST',
                value: plan.gstAmount, colors: colors),
            if (plan.securityDeposit > 0)
              _PriceLine(label: 'Security deposit (at property)',
                  value: plan.securityDeposit, colors: colors),
            const Divider(height: 16),
            _PriceLine(
              label: 'Total payable',
              value: plan.netAfterTax,
              colors: colors,
              isBold: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine(
      {required this.label,
      required this.value,
      required this.colors,
      this.isBold = false});
  final String label;
  final double value;
  final AppColorScheme colors;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? AppTypography.heading.copyWith(color: colors.ink900)
        : AppTypography.body.copyWith(color: colors.ink600);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('₹ ${value.toStringAsFixed(0)}', style: style),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.colors,
      required this.icon,
      required this.label,
      required this.value,
      this.onTap});
  final AppColorScheme colors;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.ink400),
          const SizedBox(width: 8),
          Text('$label: ',
              style: AppTypography.caption.copyWith(color: colors.ink400)),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : (onTap != null ? 'Select date' : '—'),
              style: AppTypography.body.copyWith(
                color: value.isNotEmpty ? colors.ink900 : colors.goldPrimary,
                fontWeight:
                    value.isEmpty && onTap != null ? FontWeight.w600 : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onTap != null)
            Icon(Icons.edit_calendar_outlined,
                size: 16, color: colors.goldPrimary),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.colors,
    this.keyboardType,
    this.validator,
  });
  final TextEditingController controller;
  final String label;
  final AppColorScheme colors;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTypography.body.copyWith(color: colors.ink900),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.caption.copyWith(color: colors.ink400),
        filled: true,
        fillColor: colors.surfacePrimary,
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
      ),
    );
  }
}
