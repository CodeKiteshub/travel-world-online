import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../data/datasources/association_content_datasource.dart';
import '../../data/models/association_model.dart';
import '../providers/association_content_providers.dart';
import '../providers/association_session_provider.dart';

/// Post a Job form — same fields as the old app's association Job Section.
class AssociationJobCreateScreen extends ConsumerStatefulWidget {
  const AssociationJobCreateScreen({super.key, required this.assoc});
  final AssociationModel assoc;

  @override
  ConsumerState<AssociationJobCreateScreen> createState() =>
      _AssociationJobCreateScreenState();
}

class _AssociationJobCreateScreenState
    extends ConsumerState<AssociationJobCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _company = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _website = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _company.dispose();
    _description.dispose();
    _location.dispose();
    _website.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) return;
    final session =
        ref.read(associationSessionProvider)[widget.assoc.id];
    if (session == null) return;

    setState(() => _submitting = true);
    try {
      final ds = AssociationContentDatasource(ref.read(dioProvider));
      await ds.postJob(
        associationId: widget.assoc.id,
        memberId: session.memberId,
        token: session.token,
        jobTitle: _title.text.trim(),
        companyName: _company.text.trim(),
        jobDescription: _description.text.trim(),
        location: _location.text.trim(),
        companyWebsite: _website.text.trim(),
      );
      ref.invalidate(associationJobsProvider(widget.assoc.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job posted successfully')));
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not post job. Please try again.')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;

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
              Text('Post a Job',
                  style: AppTypography.displayMd.copyWith(color: colors.ink900, fontSize: 18, fontWeight: FontWeight.w700)),
            ]),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _Field(ctrl: _title, hint: 'Job Title *', colors: colors,
                      validator: _required('job title')),
                  _Field(ctrl: _company, hint: 'Company Name *', colors: colors,
                      validator: _required('company name')),
                  _Field(ctrl: _description, hint: 'Job Description *', colors: colors,
                      maxLines: 6, validator: _required('job description')),
                  _Field(ctrl: _location, hint: 'Location *', colors: colors,
                      validator: _required('location')),
                  _Field(ctrl: _website, hint: 'Company Website (Optional)', colors: colors),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _submit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: colors.goldPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _submitting
                          ? const Center(
                              child: SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2)))
                          : Text('Post Job',
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
          ),
        ],
      ),
    );
  }

  String? Function(String?) _required(String label) =>
      (v) => (v == null || v.trim().isEmpty) ? 'Please enter the $label' : null;
}

class _Field extends StatelessWidget {
  const _Field({
    required this.ctrl,
    required this.hint,
    required this.colors,
    this.validator,
    this.maxLines = 1,
  });
  final TextEditingController ctrl;
  final String hint;
  final AppColorScheme colors;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: ctrl,
          validator: validator,
          maxLines: maxLines,
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
