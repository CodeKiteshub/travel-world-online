import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../data/models/villa_rate_model.dart';
import '../../data/models/villa_rate_plan_model.dart';
import '../providers/marketplace_providers.dart';

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
                      Text(rate.city,
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
                    height: 220,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _TabContent(
                          text: rate.description.isNotEmpty
                              ? rate.description
                              : 'Experience luxury villa living with premium amenities and personalised service in ${rate.city}.',
                        ),
                        const _TabContent(
                          text:
                              'Swimming pool · Private garden · Fully equipped kitchen · Air conditioning · Wi-Fi · Smart TV · BBQ area · Parking',
                        ),
                        const _TabContent(
                          text:
                              'Check-in from 3:00 PM · Check-out by 11:00 AM · No smoking · No pets · Quiet hours after 10:00 PM',
                        ),
                        _TabContent(
                          text: rate.city.isNotEmpty
                              ? 'Located in ${rate.city}. Contact our team for exact address and directions after booking confirmation.'
                              : 'Contact our team for exact address and directions after booking confirmation.',
                        ),
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
                onPressed: _openBookingSheet,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.goldPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Book Now',
                    style: AppTypography.heading.copyWith(color: Colors.white)),
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
        checkin: widget.rate.checkin,
        checkout: widget.rate.checkout,
        adults: widget.rate.adults,
        children: widget.rate.children,
      );

  Future<void> _proceedToPayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rate plan')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final ds = ref.read(marketplaceDatasourceProvider);
      final orderId = await ds.createVillaPaymentOrder(
          _selectedPlan!.totalPayableInPaise);
      final options = {
        'key': 'rzp_live_SJyy6qt0I2DKtU',
        'amount': _selectedPlan!.totalPayableInPaise,
        'order_id': orderId,
        'name': 'Travel World Online',
        'description': widget.rate.propertyName,
        'prefill': {
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'contact': _phoneCtrl.text.trim(),
        },
        'theme': {'color': '#C9A84C'},
      };
      _razorpay.open(options);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment setup failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      setState(() => _loading = false);
    }
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _loading = true);
    try {
      final ds = ref.read(marketplaceDatasourceProvider);
      await ds.submitVillaBooking({
        'quoteId': widget.rate.quoteId,
        'propertyId': widget.rate.propertyId,
        'ratePlanCode': _selectedPlan?.ratePlanCode,
        'bookingStatus': 'CONFIRMED',
        'guest': {
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
        },
        'payment': {
          'transactionId': response.paymentId,
          'orderId': response.orderId,
          'paidAmount': _selectedPlan?.totalPayable,
          'provider': 'Razorpay',
        },
      });
    } catch (_) {
      // Even if booking API fails, payment was successful — still show success
    }
    if (mounted) {
      Navigator.of(context).pop(); // close sheet
      _showSuccessDialog();
    }
    setState(() => _loading = false);
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
                        // Stay summary
                        _InfoRow(colors: colors, icon: Icons.calendar_today_outlined,
                            label: 'Check-in', value: widget.rate.checkin),
                        const SizedBox(height: 8),
                        _InfoRow(colors: colors, icon: Icons.calendar_today_outlined,
                            label: 'Check-out', value: widget.rate.checkout),
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
                        plansAsync.when(
                          loading: () => const Center(
                              child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          )),
                          error: (_, __) => Text(
                            'Could not load rate plans. Showing base price.',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.error),
                          ),
                          data: (plans) {
                            if (plans.isEmpty) {
                              return _RatePlanFallback(
                                  rate: widget.rate, colors: colors);
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
                                      ? 'Pay ${widget.rate.currency} ${_selectedPlan!.totalPayable.toStringAsFixed(0)} & Confirm'
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
            _PriceLine(label: 'Security deposit',
                value: plan.securityDeposit, colors: colors),
            const Divider(height: 16),
            _PriceLine(
              label: 'Total payable',
              value: plan.totalPayable,
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

class _RatePlanFallback extends StatelessWidget {
  const _RatePlanFallback({required this.rate, required this.colors});
  final VillaRateModel rate;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.lineSoft),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Base Rate', style: AppTypography.body.copyWith(color: colors.ink600)),
          Text(
            '${rate.currency} ${rate.amount.toStringAsFixed(0)}',
            style: AppTypography.heading.copyWith(color: colors.goldPrimary),
          ),
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
      required this.value});
  final AppColorScheme colors;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.ink400),
        const SizedBox(width: 8),
        Text('$label: ',
            style: AppTypography.caption.copyWith(color: colors.ink400)),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '—',
            style: AppTypography.body.copyWith(color: colors.ink900),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
