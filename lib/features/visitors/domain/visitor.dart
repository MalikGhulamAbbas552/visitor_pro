class Visitor {
  const Visitor({
    required this.id,
    required this.fullName,
    required this.status,
    required this.visitDate,
    required this.createdAt,
    this.email,
    this.phone,
    this.company,
    this.purpose,
    this.checkInAt,
    this.checkOutAt,
  });

  final String id;
  final String fullName;
  final String status;

  final String? email;
  final String? phone;
  final String? company;
  final String? purpose;

  final DateTime visitDate;
  final DateTime createdAt;

  final DateTime? checkInAt;
  final DateTime? checkOutAt;

  factory Visitor.fromMap(
      Map<String, dynamic> map,
      ) {
    return Visitor(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      status: map['status'] as String,

      email: map['email'] as String?,
      phone: map['phone'] as String?,
      company: map['company'] as String?,
      purpose: map['purpose'] as String?,

      visitDate: DateTime.parse(
        map['visit_date'] as String,
      ),

      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),

      checkInAt: map['check_in_at'] == null
          ? null
          : DateTime.parse(
        map['check_in_at'] as String,
      ),

      checkOutAt: map['check_out_at'] == null
          ? null
          : DateTime.parse(
        map['check_out_at'] as String,
      ),
    );
  }
}