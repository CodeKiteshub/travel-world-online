import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../providers/visa_providers.dart';

// ── Design constants (same palette as insurance wizard) ───────────────────────

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

class VisaWizardScreen extends ConsumerStatefulWidget {
  const VisaWizardScreen({super.key});

  @override
  ConsumerState<VisaWizardScreen> createState() => _VisaWizardScreenState();
}

class _VisaWizardScreenState extends ConsumerState<VisaWizardScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final step = ref.watch(visaApplicationProvider.select((s) => s.currentStep));

    ref.listen(visaApplicationProvider.select((s) => s.currentStep), (_, next) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(next,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    });

    ref.listen(visaApplicationProvider.select((s) => s.isSubmitted), (_, ok) {
      if (ok) context.go(RouteNames.visaConfirmation);
    });

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Column(
        children: [
          _Header(
            step: step,
            stepLabels: const ['Personal', 'Travel', 'Docs', 'Review'],
            colors: colors,
            onBack: () {
              if (step == 0) {
                context.pop();
              } else {
                ref.read(visaApplicationProvider.notifier).previousStep();
              }
            },
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step1Personal(colors: colors),
                _Step2Travel(colors: colors),
                _Step3Documents(colors: colors),
                _Step4Review(colors: colors),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header with segmented progress (same as insurance) ────────────────────────

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
                  'Visa Application',
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

// ── Step 1: Personal Info ─────────────────────────────────────────────────────

class _Step1Personal extends ConsumerStatefulWidget {
  const _Step1Personal({required this.colors});
  final AppColorScheme colors;

  @override
  ConsumerState<_Step1Personal> createState() => _Step1PersonalState();
}

class _Step1PersonalState extends ConsumerState<_Step1Personal> {
  late final _fullName = TextEditingController();
  late final _passport = TextEditingController();
  late final _nationality = TextEditingController(text: 'Indian');
  late final _email = TextEditingController();
  late final _phone = TextEditingController();
  String _dob = '';

  @override
  void dispose() {
    _fullName.dispose();
    _passport.dispose();
    _nationality.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _canProceed =>
      _fullName.text.isNotEmpty &&
      _passport.text.isNotEmpty &&
      _dob.isNotEmpty &&
      _email.text.isNotEmpty &&
      _phone.text.isNotEmpty;

  void _next() {
    final n = ref.read(visaApplicationProvider.notifier);
    n.setFullName(_fullName.text);
    n.setPassportNo(_passport.text);
    n.setDateOfBirth(_dob);
    n.setNationality(_nationality.text);
    n.setEmail(_email.text);
    n.setPhone(_phone.text);
    n.nextStep();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
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
                title: 'Personal Info',
                subtitle: 'Enter the applicant\'s passport details',
              ),
              const SizedBox(height: 24),

              _InputCard(children: [
                _InputRow(
                    label: 'Full Name',
                    hint: 'As on passport',
                    controller: _fullName,
                    colors: colors,
                    onChanged: () => setState(() {})),
                _Divider(),
                _InputRow(
                    label: 'Passport No.',
                    hint: 'e.g. P1234567',
                    controller: _passport,
                    colors: colors,
                    onChanged: () => setState(() {})),
                _Divider(),
                _InputRow(
                    label: 'Nationality',
                    hint: 'Indian',
                    controller: _nationality,
                    colors: colors,
                    onChanged: () => setState(() {})),
              ]),
              const SizedBox(height: 14),

              _FieldLabel('Date of Birth', colors),
              const SizedBox(height: 8),
              _DateTile(
                value: _dob,
                hint: 'Tap to select',
                colors: colors,
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime(1990),
                    firstDate: DateTime(1930),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) {
                    setState(() {
                      _dob =
                          '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              _InputCard(children: [
                _InputRow(
                    label: 'Email',
                    hint: 'traveller@email.com',
                    controller: _email,
                    colors: colors,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: () => setState(() {})),
                _Divider(),
                _InputRow(
                    label: 'Phone',
                    hint: '+91 XXXXX XXXXX',
                    controller: _phone,
                    colors: colors,
                    keyboardType: TextInputType.phone,
                    onChanged: () => setState(() {})),
              ]),
            ],
          ),
        ),
        _PrimaryButton(
          label: 'Next: Travel Details',
          icon: Icons.flight_takeoff_rounded,
          enabled: _canProceed,
          onTap: _next,
        ),
      ],
    );
  }
}

// ── Step 2: Travel Details ────────────────────────────────────────────────────

class _Step2Travel extends ConsumerWidget {
  const _Step2Travel({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(visaApplicationProvider);
    final notifier = ref.read(visaApplicationProvider.notifier);

    final canProceed = state.country.isNotEmpty &&
        state.visaType.isNotEmpty &&
        state.travelDate.isNotEmpty &&
        state.purpose.isNotEmpty;

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
                title: 'Travel Details',
                subtitle: 'Destination, visa type and travel dates',
              ),
              const SizedBox(height: 24),

              _FieldLabel('Destination Country', colors),
              const SizedBox(height: 8),
              _DropdownField(
                value: state.country.isEmpty ? null : state.country,
                hint: 'Select destination country',
                items: VisaApplicationNotifier.countries,
                colors: colors,
                onChanged: notifier.setCountry,
              ),
              const SizedBox(height: 20),

              _FieldLabel('Visa Type', colors),
              const SizedBox(height: 8),
              _DropdownField(
                value: state.visaType.isEmpty ? null : state.visaType,
                hint: 'Select visa type',
                items: VisaApplicationNotifier.visaTypes,
                colors: colors,
                onChanged: notifier.setVisaType,
              ),
              const SizedBox(height: 20),

              _FieldLabel('Travel Dates', colors),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DateTile(
                      value: state.travelDate,
                      hint: 'Departure',
                      colors: colors,
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) notifier.setTravelDate(d);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.arrow_forward,
                        size: 16, color: colors.ink400),
                  ),
                  Expanded(
                    child: _DateTile(
                      value: state.returnDate,
                      hint: 'Return',
                      colors: colors,
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) notifier.setReturnDate(d);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _FieldLabel('Purpose of Visit', colors),
              const SizedBox(height: 8),
              _DropdownField(
                value: state.purpose.isEmpty ? null : state.purpose,
                hint: 'Select purpose',
                items: VisaApplicationNotifier.purposes,
                colors: colors,
                onChanged: notifier.setPurpose,
              ),
            ],
          ),
        ),
        _PrimaryButton(
          label: 'Next: Upload Documents',
          icon: Icons.upload_file_outlined,
          enabled: canProceed,
          onTap: notifier.nextStep,
        ),
      ],
    );
  }
}

// ── Step 3: Documents ─────────────────────────────────────────────────────────

class _Step3Documents extends ConsumerWidget {
  const _Step3Documents({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(visaApplicationProvider.select((s) => s.documents));
    final notifier = ref.read(visaApplicationProvider.notifier);
    final uploadedCount = docs.where((d) => d.file != null).length;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepHero(
                icon: Icons.folder_open_outlined,
                iconBg: _goldLight,
                iconColor: _gold,
                title: 'Upload Documents',
                subtitle: 'PDF, JPG or PNG · Max 5 MB each',
              ),
              const SizedBox(height: 16),

              if (uploadedCount > 0) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _greenLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          size: 13, color: _green),
                      const SizedBox(width: 6),
                      Text(
                        '$uploadedCount of ${docs.length} documents uploaded',
                        style: const TextStyle(
                            fontSize: 12,
                            color: _green,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],

              ...List.generate(docs.length, (i) {
                final doc = docs[i];
                final hasFile = doc.file != null;
                return GestureDetector(
                  onTap: () => notifier.pickDocument(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: hasFile ? _greenLight : colors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: hasFile ? _green : colors.lineSoft,
                        width: hasFile ? 1.5 : 1,
                      ),
                      boxShadow: hasFile ? [] : _cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: hasFile ? Colors.white : _blueLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            hasFile
                                ? Icons.check_circle_outline_rounded
                                : Icons.upload_file_outlined,
                            size: 22,
                            color: hasFile ? _green : _blueDeep,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.label,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colors.ink900,
                                    height: 1.3),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                hasFile
                                    ? doc.file!.path.split('/').last
                                    : 'Tap to upload',
                                style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        hasFile ? _green : colors.ink400),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          hasFile ? Icons.edit_outlined : Icons.chevron_right,
                          size: 16,
                          color: hasFile ? _green : colors.ink400,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _blueLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: _blueDeep),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'All documents must be clear and valid. You can proceed with partial uploads.',
                        style: TextStyle(
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
          label: 'Next: Review',
          icon: Icons.receipt_long_outlined,
          enabled: true,
          onTap: notifier.nextStep,
        ),
      ],
    );
  }
}

// ── Step 4: Review & Submit ───────────────────────────────────────────────────

class _Step4Review extends ConsumerWidget {
  const _Step4Review({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(visaApplicationProvider);
    final notifier = ref.read(visaApplicationProvider.notifier);
    final uploadedCount = state.documents.where((d) => d.file != null).length;

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
                title: 'Review & Submit',
                subtitle: 'Confirm details before submitting your application',
              ),
              const SizedBox(height: 24),

              _SummaryCard(
                title: 'PERSONAL DETAILS',
                rows: [
                  _SRow('Full Name', state.fullName),
                  _SRow('Passport', state.passportNo),
                  _SRow('Date of Birth', state.dateOfBirth),
                  _SRow('Nationality', state.nationality),
                  _SRow('Email', state.email),
                  _SRow('Phone', state.phone),
                ],
                colors: colors,
              ),
              const SizedBox(height: 12),

              _SummaryCard(
                title: 'TRAVEL DETAILS',
                rows: [
                  _SRow('Country', state.country),
                  _SRow('Visa Type', state.visaType),
                  _SRow('Travel Date', state.travelDate),
                  _SRow('Return Date',
                      state.returnDate.isEmpty ? '—' : state.returnDate),
                  _SRow('Purpose', state.purpose),
                ],
                colors: colors,
              ),
              const SizedBox(height: 12),

              _SummaryCard(
                title: 'DOCUMENTS',
                rows: [
                  _SRow('Uploaded',
                      '$uploadedCount / ${state.documents.length}'),
                ],
                colors: colors,
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _blueLight,
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
                      child: const Icon(Icons.verified_outlined,
                          size: 20, color: _blueDeep),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Official Submission',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _blueDeep)),
                          Text(
                            'Your application will be reviewed and processed by our visa team',
                            style: TextStyle(
                                fontSize: 11,
                                color: _blueDeep,
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (state.errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 16, color: Color(0xFFDC2626)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.errorMessage,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        _PrimaryButton(
          label: state.isLoading ? 'Submitting…' : 'Submit Application',
          icon: state.isLoading
              ? Icons.hourglass_empty_rounded
              : Icons.send_rounded,
          enabled: !state.isLoading,
          onTap: notifier.submit,
        ),
      ],
    );
  }
}

// ── Shared helpers (same design language as insurance wizard) ─────────────────

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
                        style:
                            TextStyle(color: colors.ink900, fontSize: 13)),
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

// Date tile — gold when a date is set, same feel as insurance _DateCard
class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.value,
    required this.hint,
    required this.colors,
    required this.onTap,
  });
  final String value;
  final String hint;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasValue ? _goldLight : colors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: hasValue ? _gold : colors.lineSoft),
          boxShadow: hasValue ? [] : _cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 11, color: hasValue ? _gold : colors.ink400),
                const SizedBox(width: 4),
                Text(
                  hint,
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
              hasValue ? value : '—',
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
    this.onChanged,
  });
  final String label, hint;
  final TextEditingController controller;
  final AppColorScheme colors;
  final TextInputType? keyboardType;
  final VoidCallback? onChanged;

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
              onChanged: onChanged != null ? (_) => onChanged!() : null,
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

class _SRow {
  const _SRow(this.label, this.value);
  final String label, value;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.rows,
    required this.colors,
  });
  final String title;
  final List<_SRow> rows;
  final AppColorScheme colors;

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
                        style:
                            TextStyle(fontSize: 13, color: colors.ink600)),
                    Flexible(
                      child: Text(
                          r.value.isEmpty ? '—' : r.value,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.ink900)),
                    ),
                  ],
                ),
              )),
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
                  color: enabled ? Colors.white : const Color(0xFFAEAB9F)),
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
