import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/dmc_model.dart';

class DmcCard extends StatelessWidget {
  const DmcCard({super.key, required this.dmc, required this.colors});
  final DmcModel dmc;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.lineSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.goldPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.business, color: colors.goldPrimary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dmc.companyName,
                        style: AppTypography.body.copyWith(
                          color: colors.ink900,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (dmc.supplierType.isNotEmpty)
                        Text(
                          dmc.supplierType,
                          style: AppTypography.caption
                              .copyWith(color: colors.ink600, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dmc.contactName.isNotEmpty)
                  _InfoRow(icon: Icons.person_outline, text: dmc.contactName, colors: colors),
                if (dmc.destinations.isNotEmpty)
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    text: '${dmc.destinations}, ${dmc.state}, ${dmc.country}',
                    colors: colors,
                    iconColor: colors.goldPrimary,
                  ),
                if (dmc.email.isNotEmpty)
                  _InfoRow(icon: Icons.email_outlined, text: dmc.email, colors: colors),
                if (dmc.phone.isNotEmpty)
                  _InfoRow(icon: Icons.phone_outlined, text: dmc.phone, colors: colors),
              ],
            ),
          ),
          if (dmc.services.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: dmc.services
                    .map(
                      (s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.surfaceTertiary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          s,
                          style: AppTypography.caption.copyWith(
                            color: colors.ink600,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _showContactOptions(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: colors.ink900),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: colors.surfacePrimary, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${dmc.state}, ${dmc.country}',
                      style: TextStyle(
                        color: colors.surfacePrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.contact_phone_outlined, color: colors.goldAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Contact DMC',
                        style: TextStyle(
                          color: colors.goldAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.goldPrimary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.business, color: colors.goldPrimary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dmc.companyName,
                                style: AppTypography.body.copyWith(
                                    color: colors.ink900,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                            if (dmc.contactName.isNotEmpty)
                              Text(dmc.contactName,
                                  style: AppTypography.caption
                                      .copyWith(color: colors.ink600, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 24, color: colors.lineSoft),
                if (dmc.phone.isNotEmpty)
                  ListTile(
                    leading: Icon(Icons.phone, color: colors.success),
                    title: Text('Call', style: AppTypography.body.copyWith(color: colors.ink900)),
                    subtitle: Text(dmc.phone, style: AppTypography.caption.copyWith(color: colors.ink600)),
                    onTap: () {
                      Navigator.pop(ctx);
                      launchUrl(Uri.parse('tel:${dmc.phone}'));
                    },
                  ),
                if (dmc.phone.isNotEmpty)
                  ListTile(
                    leading: const Icon(CupertinoIcons.chat_bubble_fill, color: Color(0xFF25D366)),
                    title: Text('WhatsApp', style: AppTypography.body.copyWith(color: colors.ink900)),
                    subtitle: Text(dmc.phone, style: AppTypography.caption.copyWith(color: colors.ink600)),
                    onTap: () {
                      Navigator.pop(ctx);
                      launchUrl(
                        Uri.parse('https://wa.me/${dmc.phone.replaceAll(RegExp(r'[^0-9]'), '')}'),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                if (dmc.email.isNotEmpty)
                  ListTile(
                    leading: Icon(Icons.email, color: colors.goldPrimary),
                    title: Text('Email', style: AppTypography.body.copyWith(color: colors.ink900)),
                    subtitle: Text(dmc.email, style: AppTypography.caption.copyWith(color: colors.ink600)),
                    onTap: () {
                      Navigator.pop(ctx);
                      launchUrl(Uri.parse('mailto:${dmc.email}'));
                    },
                  ),
                if (dmc.website.isNotEmpty)
                  ListTile(
                    leading: Icon(Icons.language, color: colors.warning),
                    title: Text('Website', style: AppTypography.body.copyWith(color: colors.ink900)),
                    subtitle: Text(dmc.website, style: AppTypography.caption.copyWith(color: colors.ink600)),
                    onTap: () {
                      Navigator.pop(ctx);
                      final url =
                          dmc.website.startsWith('http') ? dmc.website : 'https://${dmc.website}';
                      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, required this.colors, this.iconColor});
  final IconData icon;
  final String text;
  final AppColorScheme colors;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor ?? colors.ink400),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
