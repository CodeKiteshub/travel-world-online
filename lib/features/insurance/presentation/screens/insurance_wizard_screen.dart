import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../providers/insurance_providers.dart';
import '../../data/models/insurance_models.dart';

// ── Design constants ──────────────────────────────────────────────────────────

const _gold = Color(0xFFC9A84C);
const _goldLight = Color(0xFFF5EDD5);
const _green = Color(0xFF2D7A4F);
const _greenLight = Color(0xFFE8F5EE);
const _blueDeep = Color(0xFF2A4A6B);
const _blueLight = Color(0xFFE8EEF5);
const _cardShadow = [
  BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 4)),
];

// ─────────────────────────────────────────────────────────────────────────────

class InsuranceWizardScreen extends ConsumerStatefulWidget {
  const InsuranceWizardScreen({super.key});

  @override
  ConsumerState<InsuranceWizardScreen> createState() =>
      _InsuranceWizardScreenState();
}

class _InsuranceWizardScreenState extends ConsumerState<InsuranceWizardScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final step = ref.watch(insuranceBookingProvider.select((s) => s.currentStep));

    ref.listen(insuranceBookingProvider.select((s) => s.currentStep), (_, next) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(next,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    });

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Column(
        children: [
          _Header(
            step: step,
            stepLabels: const ['Trip', 'Plan', 'Traveller', 'Pay'],
            colors: colors,
            onBack: () {
              if (step == 0) {
                context.pop();
              } else {
                ref.read(insuranceBookingProvider.notifier).previousStep();
              }
            },
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step1TripDetails(colors: colors),
                _Step2ChoosePlan(colors: colors),
                _Step3TravellerDetails(colors: colors),
                _Step4ReviewPay(
                  colors: colors,
                  onPaid: () => context.go(RouteNames.insuranceConfirmation),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header with segmented progress ───────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.step,
    required this.stepLabels,
    required this.colors,
    required this.onBack,
  });
  final int step;
  final List<String> stepLabels;
  final AppColorScheme colors;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      color: colors.surfaceCard,
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.surfacePrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 14, color: colors.ink900),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Travel Insurance',
                  style: AppTypography.displayMd.copyWith(
                      color: colors.ink900,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _goldLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Step ${step + 1} of 4',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: _gold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Segmented progress bar
          Row(
            children: List.generate(stepLabels.length, (i) {
              final done = i < step;
              final active = i == step;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: done
                          ? _green
                          : active
                              ? _gold
                              : colors.lineSoft,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(stepLabels.length, (i) {
              final done = i < step;
              final active = i == step;
              return Expanded(
                child: Text(
                  stepLabels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: done ? _green : active ? _gold : colors.ink400,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Trip Details ──────────────────────────────────────────────────────

class _Step1TripDetails extends ConsumerWidget {
  const _Step1TripDetails({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insuranceBookingProvider);
    final notifier = ref.read(insuranceBookingProvider.notifier);

    final canProceed = state.travelCategory.isNotEmpty &&
        state.country.isNotEmpty &&
        state.startDate != null &&
        state.endDate != null;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepHero(
                icon: Icons.flight_takeoff_rounded,
                iconBg: _blueLight,
                iconColor: _blueDeep,
                title: 'Trip Details',
                subtitle: 'Tell us about the trip you\'re insuring',
              ),
              const SizedBox(height: 24),

              _FieldLabel('Travel Category', colors),
              const SizedBox(height: 8),
              _ChipSelector(
                options: InsuranceBookingNotifier.travelCategories,
                selected: state.travelCategory,
                colors: colors,
                onSelect: notifier.setTravelCategory,
              ),
              const SizedBox(height: 20),

              _FieldLabel('Country / Region', colors),
              const SizedBox(height: 8),
              _DropdownField(
                value: state.country.isEmpty ? null : state.country,
                hint: 'Select country or region',
                items: InsuranceBookingNotifier.countries,
                colors: colors,
                onChanged: notifier.setCountry,
              ),
              const SizedBox(height: 20),

              _FieldLabel('Travel Dates', colors),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DateCard(
                      label: 'Departure',
                      value: state.startDate,
                      colors: colors,
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) notifier.setStartDate(d);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child:
                        Icon(Icons.arrow_forward, size: 16, color: colors.ink400),
                  ),
                  Expanded(
                    child: _DateCard(
                      label: 'Return',
                      value: state.endDate,
                      colors: colors,
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: state.startDate ?? DateTime.now(),
                          firstDate: state.startDate ?? DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) notifier.setEndDate(d);
                      },
                    ),
                  ),
                ],
              ),

              if (state.startDate != null && state.endDate != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _blueLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 13, color: _blueDeep),
                      const SizedBox(width: 6),
                      Text(
                        '${state.durationDays} day${state.durationDays == 1 ? '' : 's'} of coverage',
                        style: const TextStyle(
                            fontSize: 12,
                            color: _blueDeep,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              _FieldLabel('Number of Travellers', colors),
              const SizedBox(height: 8),
              _StepperTile(
                value: state.numberOfTravellers,
                colors: colors,
                onDecrement: () {
                  if (state.numberOfTravellers > 1) {
                    notifier.setNumberOfTravellers(state.numberOfTravellers - 1);
                  }
                },
                onIncrement: () =>
                    notifier.setNumberOfTravellers(state.numberOfTravellers + 1),
              ),

              const SizedBox(height: 20),
              ...List.generate(state.numberOfTravellers, (i) {
                final dob = state.travellerDOBs.length > i
                    ? state.travellerDOBs[i]
                    : null;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(
                        'Traveller ${i + 1} — Date of Birth', colors),
                    const SizedBox(height: 8),
                    _DateCard(
                      label: dob == null ? 'Select date of birth' : '',
                      value: dob,
                      colors: colors,
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime(1990),
                          firstDate: DateTime(1930),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) notifier.setTravellerDOB(i, d);
                      },
                    ),
                    if (dob != null) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(
                          'Age: ${InsuranceBookingNotifier.calcAge(dob)} years',
                          style: TextStyle(
                              fontSize: 11,
                              color: colors.ink400,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                );
              }),
            ],
          ),
        ),
        _PrimaryButton(
          label: 'View Available Plans',
          icon: Icons.shield_outlined,
          enabled: canProceed,
          onTap: () async {
            await ref.read(insuranceBookingProvider.notifier).fetchPlans();
            ref.read(insuranceBookingProvider.notifier).nextStep();
          },
        ),
      ],
    );
  }
}

// ── Step 2: Choose Plan ───────────────────────────────────────────────────────

class _Step2ChoosePlan extends ConsumerWidget {
  const _Step2ChoosePlan({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insuranceBookingProvider);
    final notifier = ref.read(insuranceBookingProvider.notifier);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepHero(
                icon: Icons.local_offer_outlined,
                iconBg: _goldLight,
                iconColor: _gold,
                title: 'Choose Your Plan',
                subtitle:
                    '${state.country} · ${state.durationDays} days · ${state.numberOfTravellers} traveller${state.numberOfTravellers > 1 ? 's' : ''}',
              ),
              const SizedBox(height: 24),

              if (state.isLoadingPlans)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Column(children: [
                      CircularProgressIndicator(color: _gold),
                      SizedBox(height: 14),
                      Text('Loading plans…',
                          style: TextStyle(
                              color: _blueDeep,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ]),
                  ),
                )
              else if (state.availablePlans.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colors.surfaceTertiary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.search_off_rounded,
                            size: 32, color: colors.ink400),
                      ),
                      const SizedBox(height: 16),
                      Text('No plans found',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: colors.ink900)),
                      const SizedBox(height: 6),
                      Text(
                        'Please go back and verify your trip details.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: colors.ink600,
                            height: 1.5),
                      ),
                    ]),
                  ),
                )
              else
                ...state.availablePlans.map((plan) => _PlanCard(
                      plan: plan,
                      isSelected: state.selectedPlan?.id == plan.id,
                      numberOfTravellers: state.numberOfTravellers,
                      colors: colors,
                      onTap: () => notifier.selectPlan(plan),
                    )),
            ],
          ),
        ),
        _PrimaryButton(
          label: 'Continue with Selected Plan',
          icon: Icons.arrow_forward_rounded,
          enabled: state.selectedPlan != null,
          onTap: notifier.nextStep,
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.numberOfTravellers,
    required this.colors,
    required this.onTap,
  });
  final InsurancePlan plan;
  final bool isSelected;
  final int numberOfTravellers;
  final AppColorScheme colors;
  final VoidCallback onTap;

  static const _coverageMap = {
    '3 lac': '₹3,00,000 Medical Cover',
    '6 lac': '₹6,00,000 Medical Cover',
    '10 lac': '₹10,00,000 Medical Cover',
    '250k': 'USD 2,50,000 Medical Cover',
    '5 lac': '₹5,00,000 Medical Cover',
    'domestic': 'Domestic Travel Cover',
    'annual': 'Annual Multi-Trip Cover',
  };

  String _coverage() {
    final n = plan.name.toLowerCase();
    for (final entry in _coverageMap.entries) {
      if (n.contains(entry.key)) return entry.value;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final coverage = _coverage();
    final totalPremium = plan.premium * numberOfTravellers;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isSelected ? _goldLight : colors.surfaceCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isSelected ? _gold : colors.lineSoft,
              width: isSelected ? 1.5 : 1),
          boxShadow: isSelected ? [] : _cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : _blueLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.shield_rounded,
                        size: 22,
                        color: isSelected ? _gold : _blueDeep),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.name,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: colors.ink900,
                                height: 1.3)),
                        if (coverage.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(coverage,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: _blueDeep,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${plan.premium.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _gold)),
                      Text('per person',
                          style: TextStyle(
                              fontSize: 10, color: colors.ink400)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFEEEBE3)),
              const SizedBox(height: 12),

              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    plan.features.map((f) => _FeatureChip(label: f)).toList(),
              ),

              if (numberOfTravellers > 1) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$numberOfTravellers travellers total',
                          style: TextStyle(
                              fontSize: 12, color: colors.ink600)),
                      Text('₹${totalPremium.toStringAsFixed(0)} total',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _gold)),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: isSelected ? _green : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isSelected ? _green : _gold, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.check_circle_rounded,
                          size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      const Text('Selected',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ] else
                      Text('Select Plan',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colors.ink900)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});
  final String label;

  static IconData _icon(String label) {
    final l = label.toLowerCase();
    if (l.contains('medical')) return Icons.favorite_border_rounded;
    if (l.contains('evacuation')) return Icons.local_hospital_outlined;
    if (l.contains('accident')) return Icons.shield_outlined;
    if (l.contains('baggage') || l.contains('loss')) return Icons.luggage_outlined;
    if (l.contains('cancel')) return Icons.cancel_outlined;
    if (l.contains('roadside')) return Icons.directions_car_outlined;
    if (l.contains('annual')) return Icons.calendar_month_outlined;
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F2EC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(label), size: 11, color: _blueDeep),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: _blueDeep,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Step 3: Traveller Details ─────────────────────────────────────────────────

class _Step3TravellerDetails extends ConsumerStatefulWidget {
  const _Step3TravellerDetails({required this.colors});
  final AppColorScheme colors;

  @override
  ConsumerState<_Step3TravellerDetails> createState() =>
      _Step3State();
}

class _Step3State extends ConsumerState<_Step3TravellerDetails> {
  int _current = 0;
  final _cMap = <int, Map<String, TextEditingController>>{};

  Map<String, TextEditingController> _ctrls(int i) =>
      _cMap.putIfAbsent(i, () => {
            'fullName': TextEditingController(),
            'passportNo': TextEditingController(),
            'nationality': TextEditingController(text: 'Indian'),
            'email': TextEditingController(),
            'phone': TextEditingController(),
          });

  @override
  void dispose() {
    for (final m in _cMap.values) {
      for (final c in m.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _save() {
    final ctrl = _ctrls(_current);
    final list = ref.read(insuranceBookingProvider).travellerInfoList;
    final existing = list.length > _current ? list[_current] : TravellerInfo();
    ref.read(insuranceBookingProvider.notifier).updateTravellerInfo(
          _current,
          TravellerInfo(
            fullName: ctrl['fullName']!.text,
            passportNo: ctrl['passportNo']!.text,
            nationality: ctrl['nationality']!.text,
            email: ctrl['email']!.text,
            phone: ctrl['phone']!.text,
            dateOfBirth: existing.dateOfBirth,
            medicalConditions: existing.medicalConditions,
            address: existing.address,
            district: existing.district,
            state: existing.state,
            city: existing.city,
            country: existing.country,
            pincode: existing.pincode,
            nominee: existing.nominee,
            relationship: existing.relationship,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(insuranceBookingProvider);
    final notifier = ref.read(insuranceBookingProvider.notifier);
    final colors = widget.colors;
    final ctrl = _ctrls(_current);
    final total = state.numberOfTravellers;
    final dob = state.travellerDOBs.length > _current
        ? state.travellerDOBs[_current]
        : null;
    final dobText = dob != null
        ? '${dob.day.toString().padLeft(2, '0')} / ${dob.month.toString().padLeft(2, '0')} / ${dob.year}'
        : 'Not set';
    final medCond = state.travellerInfoList.length > _current
        ? state.travellerInfoList[_current].medicalConditions
        : 'No';

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepHero(
                icon: Icons.person_outline_rounded,
                iconBg: _greenLight,
                iconColor: _green,
                title: 'Traveller Details',
                subtitle:
                    '${state.selectedPlan?.name ?? ''} · ₹${state.selectedPlan?.premium.toStringAsFixed(0) ?? ''}/person',
              ),

              if (total > 1) ...[
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(total, (i) {
                      final active = i == _current;
                      return GestureDetector(
                        onTap: () {
                          _save();
                          setState(() => _current = i);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: active ? _gold : colors.surfaceCard,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                                color: active ? _gold : colors.lineSoft),
                          ),
                          child: Text('Traveller ${i + 1}',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: active
                                      ? Colors.white
                                      : colors.ink600)),
                        ),
                      );
                    }),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              _InputCard(children: [
                _InputRow(
                    label: 'Full Name',
                    hint: 'As on passport',
                    controller: ctrl['fullName']!,
                    colors: colors),
                _Divider(),
                _InputRow(
                    label: 'Passport No.',
                    hint: 'e.g. P1234567',
                    controller: ctrl['passportNo']!,
                    colors: colors),
                _Divider(),
                _ReadOnlyRow(
                    label: 'Date of Birth', value: dobText, colors: colors),
                _Divider(),
                _InputRow(
                    label: 'Nationality',
                    hint: 'Indian',
                    controller: ctrl['nationality']!,
                    colors: colors),
              ]),
              const SizedBox(height: 14),

              _InputCard(children: [
                _InputRow(
                    label: 'Email',
                    hint: 'traveller@email.com',
                    controller: ctrl['email']!,
                    colors: colors,
                    keyboardType: TextInputType.emailAddress),
                _Divider(),
                _InputRow(
                    label: 'Phone',
                    hint: '+91 XXXXX XXXXX',
                    controller: ctrl['phone']!,
                    colors: colors,
                    keyboardType: TextInputType.phone),
              ]),
              const SizedBox(height: 14),

              _InputCard(children: [
                _DropdownRow(
                  label: 'Pre-existing Conditions',
                  value: medCond,
                  items: const ['No', 'Yes'],
                  colors: colors,
                  onChanged: (v) {
                    _save();
                    final list =
                        List<TravellerInfo>.from(state.travellerInfoList);
                    if (list.length > _current) {
                      list[_current].medicalConditions = v;
                      notifier.updateTravellerInfo(_current, list[_current]);
                    }
                  },
                ),
              ]),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _blueLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 16, color: _blueDeep),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Traveller ${_current + 1} of $total. Ensure details match the passport exactly.',
                        style: const TextStyle(
                            fontSize: 12,
                            color: _blueDeep,
                            height: 1.5,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _PrimaryButton(
          label: _current < total - 1 ? 'Next Traveller' : 'Review & Pay',
          icon: _current < total - 1
              ? Icons.person_add_outlined
              : Icons.payment_rounded,
          enabled: true,
          onTap: () {
            _save();
            if (_current < total - 1) {
              setState(() => _current++);
            } else {
              notifier.nextStep();
            }
          },
        ),
      ],
    );
  }
}

// ── Step 4: Review & Pay ──────────────────────────────────────────────────────

class _Step4ReviewPay extends ConsumerWidget {
  const _Step4ReviewPay({required this.colors, required this.onPaid});
  final AppColorScheme colors;
  final VoidCallback onPaid;

  static const _months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _fmt(DateTime? d) =>
      d == null ? '—' : '${d.day} ${_months[d.month]} ${d.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insuranceBookingProvider);
    final notifier = ref.read(insuranceBookingProvider.notifier);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepHero(
                icon: Icons.receipt_long_outlined,
                iconBg: _goldLight,
                iconColor: _gold,
                title: 'Review & Pay',
                subtitle: 'Confirm everything before making payment',
              ),
              const SizedBox(height: 24),

              _SummaryCard(
                title: 'TRIP SUMMARY',
                rows: [
                  _SRow('Plan', state.selectedPlan?.name ?? '—'),
                  _SRow('Destination', state.country),
                  _SRow('Departure', _fmt(state.startDate)),
                  _SRow('Return', _fmt(state.endDate)),
                  _SRow('Duration', '${state.durationDays} days'),
                  _SRow('Travellers', '${state.numberOfTravellers}'),
                ],
                colors: colors,
              ),
              const SizedBox(height: 12),

              _SummaryCard(
                title: 'PRICE BREAKDOWN',
                rows: [
                  _SRow('Premium × ${state.numberOfTravellers}',
                      '₹${state.totalPremium.toStringAsFixed(0)}'),
                  _SRow('GST (18%)',
                      '₹${state.gst.toStringAsFixed(0)}'),
                ],
                footer: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.ink900)),
                    Text('₹${state.grandTotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _gold)),
                  ],
                ),
                colors: colors,
              ),
              const SizedBox(height: 20),

              // Secure payment badge — Razorpay handles method selection natively
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _greenLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.lock_rounded,
                          size: 20, color: _green),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Secured by Razorpay',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _green)),
                          Text(
                            'Pay with Card, UPI, Net Banking or Wallet',
                            style: TextStyle(
                                fontSize: 11,
                                color: _green,
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _PrimaryButton(
          label: state.isLoading
              ? 'Processing…'
              : 'Pay ₹${state.grandTotal.toStringAsFixed(0)}',
          icon: Icons.lock_outline_rounded,
          enabled: !state.isLoading,
          onTap: () => notifier.openRazorpay(
            onSuccess: (_) => onPaid(),
            onError: (msg) => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg))),
          ),
        ),
      ],
    );
  }
}

class _SRow {
  const _SRow(this.label, this.value);
  final String label, value;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.rows,
    required this.colors,
    this.footer,
  });
  final String title;
  final List<_SRow> rows;
  final AppColorScheme colors;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _cardShadow,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: colors.ink400,
                  letterSpacing: 0.8)),
          const SizedBox(height: 12),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.label,
                        style: TextStyle(
                            fontSize: 13, color: colors.ink600)),
                    Flexible(
                      child: Text(r.value,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.ink900)),
                    ),
                  ],
                ),
              )),
          if (footer != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFEEEBE3)),
            ),
            footer!,
          ],
        ],
      ),
    );
  }
}

// ── Shared private helpers ────────────────────────────────────────────────────

class _StepHero extends StatelessWidget {
  const _StepHero({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, size: 24, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A))),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF5E5E5E))),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label, this.colors);
  final String label;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) => Text(label,
      style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colors.ink600,
          letterSpacing: 0.2));
}

class _ChipSelector extends StatelessWidget {
  const _ChipSelector({
    required this.options,
    required this.selected,
    required this.colors,
    required this.onSelect,
  });
  final List<String> options;
  final String selected;
  final AppColorScheme colors;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final isSelected = o == selected;
        return GestureDetector(
          onTap: () => onSelect(o),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? _gold : colors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isSelected ? _gold : colors.lineSoft),
              boxShadow: isSelected ? [] : _cardShadow,
            ),
            child: Text(o,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color:
                        isSelected ? Colors.white : colors.ink900)),
          ),
        );
      }).toList(),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    this.value,
    required this.hint,
    required this.items,
    required this.colors,
    required this.onChanged,
  });
  final String? value;
  final String hint;
  final List<String> items;
  final AppColorScheme colors;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.lineSoft),
        boxShadow: _cardShadow,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint,
              style: TextStyle(color: colors.ink400, fontSize: 13)),
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: TextStyle(
                            color: colors.ink900, fontSize: 13)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.label,
    required this.value,
    required this.colors,
    required this.onTap,
  });
  final String label;
  final DateTime? value;
  final AppColorScheme colors;
  final VoidCallback onTap;

  static const _months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasValue ? _goldLight : colors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: hasValue ? _gold : colors.lineSoft),
          boxShadow: hasValue ? [] : _cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 11,
                    color: hasValue ? _gold : colors.ink400),
                const SizedBox(width: 4),
                Text(
                  label.isEmpty
                      ? (hasValue ? 'Selected' : 'Select')
                      : label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: hasValue ? _gold : colors.ink400,
                      letterSpacing: 0.3),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              hasValue
                  ? '${value!.day} ${_months[value!.month]} ${value!.year}'
                  : '—',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: hasValue ? colors.ink900 : colors.ink400),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperTile extends StatelessWidget {
  const _StepperTile({
    required this.value,
    required this.colors,
    required this.onDecrement,
    required this.onIncrement,
  });
  final int value;
  final AppColorScheme colors;
  final VoidCallback onDecrement, onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.lineSoft),
        boxShadow: _cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$value traveller${value == 1 ? '' : 's'}',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.ink900),
          ),
          Row(
            children: [
              _StepBtn(
                  icon: Icons.remove,
                  enabled: value > 1,
                  colors: colors,
                  onTap: onDecrement),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('$value',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _gold)),
              ),
              _StepBtn(
                  icon: Icons.add,
                  enabled: true,
                  colors: colors,
                  onTap: onIncrement),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({
    required this.icon,
    required this.enabled,
    required this.colors,
    required this.onTap,
  });
  final IconData icon;
  final bool enabled;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled ? _goldLight : colors.surfaceTertiary,
          shape: BoxShape.circle,
          border: Border.all(
              color: enabled ? _gold : colors.lineSoft),
        ),
        child: Icon(icon,
            size: 14, color: enabled ? _gold : colors.ink400),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: Color(0xFFF0EDE6));
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.label,
    required this.hint,
    required this.controller,
    required this.colors,
    this.keyboardType,
  });
  final String label, hint;
  final TextEditingController controller;
  final AppColorScheme colors;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.ink600)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.ink900),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    TextStyle(color: colors.ink400, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow(
      {required this.label, required this.value, required this.colors});
  final String label, value;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.ink600)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.ink900)),
        ],
      ),
    );
  }
}

class _DropdownRow extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.colors,
    required this.onChanged,
  });
  final String label, value;
  final List<String> items;
  final AppColorScheme colors;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.ink600)),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                alignment: AlignmentDirectional.centerEnd,
                items: items
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: colors.ink900,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: enabled ? _gold : const Color(0xFFE0DDD5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled
                ? [
                    BoxShadow(
                        color: _gold.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color:
                      enabled ? Colors.white : const Color(0xFFAEAB9F)),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: enabled
                          ? Colors.white
                          : const Color(0xFFAEAB9F))),
            ],
          ),
        ),
      ),
    );
  }
}
