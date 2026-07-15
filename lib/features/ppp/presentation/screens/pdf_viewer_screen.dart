import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// In-app viewer for a network PDF (e-brochures etc.).
class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key, required this.url, required this.title});
  final String url;
  final String title;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late Future<Uint8List> _pdfFuture = _fetch();
  int _currentPage = 0;
  int _totalPages = 0;

  Future<Uint8List> _fetch() async {
    // Public CDN URLs — plain Dio, no auth interceptor needed.
    final response = await Dio().get<List<int>>(
      widget.url,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        elevation: 0,
        leading: BackButton(color: colors.ink900),
        title: Text(
          widget.title,
          style: AppTypography.heading.copyWith(color: colors.ink900),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: FutureBuilder<Uint8List>(
        future: _pdfFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.picture_as_pdf_outlined,
                      size: 48, color: colors.ink400),
                  const SizedBox(height: 12),
                  Text('Could not load PDF',
                      style:
                          AppTypography.heading.copyWith(color: colors.ink900)),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        setState(() => _pdfFuture = _fetch()),
                    child: Text('Retry',
                        style: AppTypography.label
                            .copyWith(color: colors.goldPrimary)),
                  ),
                ],
              ),
            );
          }
          return Stack(
            children: [
              PDFView(
                pdfData: snapshot.data!,
                // onRender is unreliable on some devices — also read the
                // count straight from the controller once the view exists.
                onViewCreated: (controller) async {
                  final count = await controller.getPageCount();
                  if (mounted && count != null && count > 0) {
                    setState(() => _totalPages = count);
                  }
                },
                onRender: (pages) {
                  if ((pages ?? 0) > 0) {
                    setState(() => _totalPages = pages!);
                  }
                },
                onPageChanged: (page, total) => setState(() {
                  _currentPage = page ?? 0;
                  if ((total ?? 0) > 0) _totalPages = total!;
                }),
              ),
              // Page indicator — tells the user there's more to scroll.
              if (_totalPages > 0)
                Positioned(
                  bottom: MediaQuery.paddingOf(context).bottom + 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.navyDeep.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Page ${_currentPage + 1} of $_totalPages',
                        style: AppTypography.label.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
