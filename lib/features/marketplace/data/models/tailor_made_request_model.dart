/// A tailor-made package request submitted by the member.
/// Mirrors the old app's TailorMadeRequest model — same backend contract.
class TailorMadeRequest {
  const TailorMadeRequest({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.destination,
    this.travelDate,
    this.duration,
    this.adult,
    this.child,
    this.childAge,
    this.budget,
    this.hotelCategory,
    this.roomSharing,
    this.mealPlan,
    this.message,
    this.memberId,
    this.status,
    this.createdAt,
  });

  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? destination;
  final String? travelDate;
  final String? duration;
  final String? adult;
  final String? child;
  final String? childAge;
  final String? budget;
  final String? hotelCategory;
  final String? roomSharing;
  final String? mealPlan;
  final String? message;
  final String? memberId;
  final String? status;
  final DateTime? createdAt;

  factory TailorMadeRequest.fromJson(Map<String, dynamic> json) =>
      TailorMadeRequest(
        id: json['_id'] as String?,
        name: json['name'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        destination: json['destination'] as String?,
        travelDate: json['travelDate'] as String?,
        duration: json['duration'] as String?,
        adult: json['adult']?.toString(),
        child: json['child']?.toString(),
        childAge: json['childAge']?.toString(),
        budget: json['budget']?.toString(),
        hotelCategory: json['hotelCategory'] as String?,
        roomSharing: json['roomSharing'] as String?,
        mealPlan: json['mealPlan'] as String?,
        message: json['message'] as String?,
        memberId: json['memberId']?.toString(),
        status: json['status'] as String?,
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      );
}
