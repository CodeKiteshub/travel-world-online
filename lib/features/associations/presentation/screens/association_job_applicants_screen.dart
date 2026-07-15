import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../ppp/presentation/screens/pdf_viewer_screen.dart';
import '../../data/models/association_content_model.dart';
import '../providers/association_content_providers.dart';

/// Applicants for one posted job — search + CV viewing (old app parity).
class AssociationJobApplicantsScreen extends ConsumerStatefulWidget {
  const AssociationJobApplicantsScreen(
      {super.key, required this.assocId, required this.job});
  final String assocId;
  final AssociationJobModel job;

  @override
  ConsumerState<AssociationJobApplicantsScreen> createState() =>
      _AssociationJobApplicantsScreenState();
}

class _AssociationJobApplicantsScreenState
    extends ConsumerState<AssociationJobApplicantsScreen> {
  String _query = '';

  List<AssociationJobApplicantModel> _filtered(
      List<AssociationJobApplicantModel> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((a) =>
            a.fullname.toLowerCase().contains(q) ||
            a.email.toLowerCase().contains(q) ||
            a.mobile.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;
    final params = (assocId: widget.assocId, jobId: widget.job.id);
    final async = ref.watch(associationJobApplicantsProvider(params));

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Column(
        children: [
          Container(
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
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Applicants',
                      style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 18, fontWeight: FontWeight.w700)),
                  Text(widget.job.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 12)),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: AppTypography.body.copyWith(color: colors.ink900, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by name, email or mobile',
                hintStyle: AppTypography.body.copyWith(color: colors.ink400, fontSize: 13),
                prefixIcon: Icon(Icons.search, size: 18, color: colors.ink400),
                filled: true,
                fillColor: colors.surfaceCard,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.lineSoft)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.lineSoft)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.ink900)),
              ),
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: 3,
                itemBuilder: (_, __) => _ShimmerCard(colors: colors),
              ),
              error: (_, __) => Center(
                child: GestureDetector(
                  onTap: () =>
                      ref.invalidate(associationJobApplicantsProvider(params)),
                  child: Text('Retry',
                      style: AppTypography.label.copyWith(
                          color: colors.goldPrimary, fontWeight: FontWeight.w600)),
                ),
              ),
              data: (all) {
                final visible = _filtered(all);
                if (visible.isEmpty) {
                  return Center(
                    child: Text(
                        _query.isEmpty
                            ? 'No applicants yet'
                            : 'No applicants match your search',
                        style: AppTypography.body.copyWith(color: colors.ink600)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: visible.length,
                  itemBuilder: (_, i) =>
                      _ApplicantCard(applicant: visible[i], colors: colors),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  const _ApplicantCard({required this.applicant, required this.colors});
  final AssociationJobApplicantModel applicant;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(applicant.fullname,
              style: AppTypography.body.copyWith(
                  color: colors.ink900, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _InfoRow(label: 'Email', value: applicant.email, colors: colors),
          _InfoRow(label: 'Mobile', value: applicant.mobile, colors: colors),
          Row(children: [
            Expanded(
                child: _InfoRow(
                    label: 'Current CTC',
                    value: applicant.currentCtc,
                    colors: colors)),
            Expanded(
                child: _InfoRow(
                    label: 'Expected CTC',
                    value: applicant.expectedCtc,
                    colors: colors)),
          ]),
          const SizedBox(height: 6),
          Divider(color: colors.lineSoft, height: 1),
          const SizedBox(height: 10),
          if (applicant.cvUrls.isEmpty)
            Text('No CV uploaded',
                style: AppTypography.caption
                    .copyWith(color: colors.ink400, fontSize: 12))
          else
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => PdfViewerScreen(
                  url: applicant.cvUrls.first,
                  title: '${applicant.fullname} — CV',
                ),
              )),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.picture_as_pdf_outlined,
                    size: 16, color: colors.goldPrimary),
                const SizedBox(width: 6),
                Text('View CV',
                    style: AppTypography.label.copyWith(
                        color: colors.goldPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, required this.colors});
  final String label;
  final String value;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: AppTypography.caption
                  .copyWith(color: colors.ink400, fontSize: 11)),
          Text(value.isEmpty ? '—' : value,
              style: AppTypography.body
                  .copyWith(color: colors.ink900, fontSize: 13)),
        ]),
      );
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.colors});
  final AppColorScheme colors;
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: colors.surfaceTertiary,
        highlightColor: colors.surfaceCard,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          height: 140,
          decoration: BoxDecoration(color: colors.surfaceCard, borderRadius: BorderRadius.circular(16)),
        ),
      );
}
