import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../widgets/space_sub_appbar.dart';

enum _BookingStatus { confirmed, pending, cancelled }

class _Booking {
  const _Booking({
    required this.name,
    required this.meta,
    required this.imageUrl,
    required this.status,
  });
  final String name;
  final String meta;
  final String imageUrl;
  final _BookingStatus status;
}

const _kBookings = [
  _Booking(
    name: 'Goa Trip',
    meta: '2 Adults · 24 May 2025\nSunset Stays Pvt Ltd',
    imageUrl: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=300&q=80',
    status: _BookingStatus.confirmed,
  ),
  _Booking(
    name: 'Dubai Holiday',
    meta: '2 Adults · 10 Jun 2025\nAwaiting seller confirmation',
    imageUrl: 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=300&q=80',
    status: _BookingStatus.pending,
  ),
  _Booking(
    name: 'Manali Adventure',
    meta: '4 Adults · 15 Jun 2025\nHimalayan Trails DMC',
    imageUrl: 'https://images.unsplash.com/photo-1545158535-c3f7168c28b6?w=300&q=80',
    status: _BookingStatus.confirmed,
  ),
  _Booking(
    name: 'Kerala Backwaters',
    meta: '2 Adults · 20 Aug 2025\nRefund processed · 3 days ago',
    imageUrl: 'https://images.unsplash.com/photo-1602002418082-a4443e081dd1?w=300&q=80',
    status: _BookingStatus.cancelled,
  ),
  _Booking(
    name: 'Bali Paradise',
    meta: '2 Adults · 12 Sep 2025\nTropical Escapes Pvt Ltd',
    imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=300&q=80',
    status: _BookingStatus.confirmed,
  ),
];

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _filterIndex = 0;

  List<_Booking> get _filtered {
    switch (_filterIndex) {
      case 1:
        return _kBookings
            .where((b) =>
                b.status == _BookingStatus.confirmed ||
                b.status == _BookingStatus.pending)
            .toList();
      case 2:
        return _kBookings
            .where((b) => b.status == _BookingStatus.confirmed)
            .toList()
            .take(2)
            .toList();
      case 3:
        return _kBookings
            .where((b) => b.status == _BookingStatus.cancelled)
            .toList();
      default:
        return _kBookings;
    }
  }

  SpaceChipStyle _chipStyle(_BookingStatus status) {
    switch (status) {
      case _BookingStatus.confirmed:
        return SpaceChipStyle.success;
      case _BookingStatus.pending:
        return SpaceChipStyle.warning;
      case _BookingStatus.cancelled:
        return SpaceChipStyle.error;
    }
  }

  String _chipLabel(_BookingStatus status) {
    switch (status) {
      case _BookingStatus.confirmed:
        return 'Confirmed';
      case _BookingStatus.pending:
        return 'Pending';
      case _BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, topPad + 76, 0, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                SpaceFilterPills(
                  filters: const ['All', 'Upcoming', 'Completed', 'Cancelled'],
                  selectedIndex: _filterIndex,
                  onSelected: (i) => setState(() => _filterIndex = i),
                  colors: colors,
                ),
                const SizedBox(height: 16),
                ..._filtered.map((b) => _BookingCard(
                      booking: b,
                      chipStyle: _chipStyle(b.status),
                      chipLabel: _chipLabel(b.status),
                      colors: colors,
                    )),
              ],
            ),
          ),
          SpaceSubAppBar(
            title: 'Bookings',
            topPad: topPad,
            colors: colors,
            actionIcon: Icons.search_rounded,
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.chipStyle,
    required this.chipLabel,
    required this.colors,
  });

  final _Booking booking;
  final SpaceChipStyle chipStyle;
  final String chipLabel;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border.all(color: colors.lineSoft),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: booking.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 64,
                height: 64,
                color: colors.surfaceTertiary,
              ),
              errorWidget: (_, __, ___) => Container(
                width: 64,
                height: 64,
                color: colors.surfaceTertiary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        booking.name,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.ink900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SpaceStatusChip(
                      label: chipLabel,
                      style: chipStyle,
                      colors: colors,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  booking.meta,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    color: colors.ink600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
