import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../providers/visa_providers.dart';

class VisaConfirmationScreen extends ConsumerWidget {
  const VisaConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final state = ref.read(visaApplicationProvider);

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2A4A6B),
                ),
                child: const Icon(Icons.assignment_turned_in_outlined,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                'Application Submitted!',
                style: AppTypography.displayMd.copyWith(
                    color: colors.ink900,
                    fontSize: 24,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Your visa application has been submitted successfully. Our team will review it shortly.',
                textAlign: TextAlign.center,
                style: AppTypography.caption
                    .copyWith(color: colors.ink600, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.lineSoft),
                ),
                child: Column(
                  children: [
                    _Row('Applicant', state.fullName, colors),
                    _Row('Destination', state.country, colors),
                    _Row('Visa Type', state.visaType, colors),
                    _Row('Travel Date', state.travelDate, colors),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  ref.read(visaApplicationProvider.notifier).reset();
                  context.go(RouteNames.services);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: colors.goldPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: colors.ink900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, this.colors);
  final String label, value;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: colors.ink600)),
          Flexible(
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 12,
                  color: colors.ink900,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
