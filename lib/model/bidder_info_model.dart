class BidderInfo {
  final String id;
  final String name;
  final String email;
  final DateTime lastBid;

  BidderInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.lastBid,
  });

  factory BidderInfo.fromJson(Map<String, dynamic> json) => BidderInfo(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        lastBid: DateTime.parse(json['last_bid'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'last_bid': lastBid.toIso8601String(),
      };

  BidderInfo copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? lastBid,
  }) =>
      BidderInfo(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        lastBid: lastBid ?? this.lastBid,
      );
}
