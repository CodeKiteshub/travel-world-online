import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/job_post_model.dart';
import '../providers/jobs_providers.dart';

void showJobApplySheet(BuildContext context, JobPost job) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => JobApplySheet(job: job),
  );
}

class JobApplySheet extends ConsumerStatefulWidget {
  const JobApplySheet({super.key, required this.job});
  final JobPost job;

  @override
  ConsumerState<JobApplySheet> createState() => _JobApplySheetState();
}

class _JobApplySheetState extends ConsumerState<JobApplySheet> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _currentCtc = TextEditingController();
  final _expectedCtc = TextEditingController();
  PlatformFile? _cvFile;
  bool _submitting = false;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _mobile.dispose();
    _currentCtc.dispose();
    _expectedCtc.dispose();
    super.dispose();
  }

  Future<void> _pickCv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _cvFile = result.files.single);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_cvFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please attach your CV (PDF)')));
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(jobsDatasourceProvider).applyToJob(
            jobPostId: widget.job.id,
            fullName: _fullName.text.trim(),
            email: _email.text.trim(),
            mobile: _mobile.text.trim(),
            currentCtc: _currentCtc.text.trim(),
            expectedCtc: _expectedCtc.text.trim(),
            cvFilePath: _cvFile!.path!,
            cvFileName: _cvFile!.name,
          );
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not submit application. Please try again.')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final job = widget.job;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colors.lineSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.jobTitle,
                    style: AppTypography.displayMd.copyWith(
                        color: colors.ink900,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, size: 20, color: colors.ink600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(job.companyLocation,
                style: AppTypography.body
                    .copyWith(color: colors.ink600, fontSize: 13)),
            if (job.jobDescription.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(job.jobDescription,
                  style: AppTypography.body
                      .copyWith(color: colors.ink600, fontSize: 12)),
            ],
            const SizedBox(height: 16),
            _Field(
                ctrl: _fullName,
                hint: 'Full Name *',
                colors: colors,
                validator: _required('full name')),
            _Field(
                ctrl: _email,
                hint: 'Email *',
                colors: colors,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!v.contains('@')) return 'Please enter a valid email';
                  return null;
                }),
            _Field(
                ctrl: _mobile,
                hint: 'Mobile Number *',
                colors: colors,
                keyboardType: TextInputType.phone,
                validator: _required('mobile number')),
            _Field(
                ctrl: _currentCtc,
                hint: 'Current CTC *',
                colors: colors,
                keyboardType: TextInputType.number,
                validator: _required('current CTC')),
            _Field(
                ctrl: _expectedCtc,
                hint: 'Expected CTC *',
                colors: colors,
                keyboardType: TextInputType.number,
                validator: _required('expected CTC')),
            GestureDetector(
              onTap: _pickCv,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  border: Border.all(color: colors.lineSoft),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                        _cvFile == null
                            ? Icons.attach_file
                            : Icons.picture_as_pdf,
                        size: 18,
                        color: _cvFile == null ? colors.ink400 : colors.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _cvFile?.name ?? 'Attach CV (PDF) *',
                        style: AppTypography.body.copyWith(
                            color: _cvFile == null
                                ? colors.ink400
                                : colors.ink900,
                            fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_cvFile != null)
                      GestureDetector(
                        onTap: () => setState(() => _cvFile = null),
                        child:
                            Icon(Icons.close, size: 18, color: colors.ink600),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
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
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2)))
                    : Text('Submit Application',
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
    );
  }

  String? Function(String?) _required(String label) =>
      (v) => (v == null || v.trim().isEmpty) ? 'Please enter your $label' : null;
}

class _Field extends StatelessWidget {
  const _Field({
    required this.ctrl,
    required this.hint,
    required this.colors,
    this.validator,
    this.keyboardType,
  });
  final TextEditingController ctrl;
  final String hint;
  final AppColorScheme colors;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: ctrl,
          validator: validator,
          keyboardType: keyboardType,
          style: AppTypography.body.copyWith(color: colors.ink900, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTypography.body.copyWith(color: colors.ink400, fontSize: 13),
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
        ),
      );
}
