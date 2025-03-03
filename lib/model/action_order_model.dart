import 'package:app/enum/order_status_enum.dart';
import 'package:app/model/product_details_model.dart';

import 'bidder_info_model.dart';

class AuctionOrder {
  final String id;
  final DateTime createdAt;
  final double basePrice;
  final double currentBid;
  final OrderStatus status;
  final List<String> images;
  final ProductDetails product;
  final BidderInfo? currentBidder;
  final int totalBids;

  AuctionOrder({
    required this.id,
    required this.createdAt,
    required this.basePrice,
    required this.currentBid,
    required this.status,
    required this.images,
    required this.product,
    this.currentBidder,
    this.totalBids = 0,
  });

  factory AuctionOrder.fromJson(Map<String, dynamic> json) => AuctionOrder(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        basePrice: (json['base_price'] as num).toDouble(),
        currentBid: (json['current_bid'] as num).toDouble(),
        status: OrderStatus.values.firstWhere(
          (e) => e.name == json['status'] as String,
        ),
        images: List<String>.from(json['images'] as List),
        product:
            ProductDetails.fromJson(json['product'] as Map<String, dynamic>),
        currentBidder: json['current_bidder'] != null
            ? BidderInfo.fromJson(
                json['current_bidder'] as Map<String, dynamic>)
            : null,
        totalBids: json['total_bids'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'base_price': basePrice,
        'current_bid': currentBid,
        'status': status.name,
        'images': images,
        'product': product.toJson(),
        'current_bidder': currentBidder?.toJson(),
        'total_bids': totalBids,
      };

  AuctionOrder copyWith({
    String? id,
    DateTime? createdAt,
    double? basePrice,
    double? currentBid,
    OrderStatus? status,
    List<String>? images,
    ProductDetails? product,
    BidderInfo? currentBidder,
    int? totalBids,
  }) =>
      AuctionOrder(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        basePrice: basePrice ?? this.basePrice,
        currentBid: currentBid ?? this.currentBid,
        status: status ?? this.status,
        images: images ?? this.images,
        product: product ?? this.product,
        currentBidder: currentBidder ?? this.currentBidder,
        totalBids: totalBids ?? this.totalBids,
      );

  factory AuctionOrder.mock() => AuctionOrder.fromJson(_mock);
}

final _mock = {
  "id": "auction_123",
  "created_at": "2024-12-17T10:30:00Z",
  "base_price": 1000.00,
  "current_bid": 1500.50,
  "status": "active",
  "images": [
    "https://example.com/image1.jpg",
    "https://example.com/image2.jpg"
  ],
  "product": {
    "name": "Vintage Watch",
    "description": "Limited edition vintage watch from 1960",
    "category": "watches",
    "specifications": {
      "brand": "Omega",
      "year": "1960",
      "condition": "excellent",
      "material": "gold"
    }
  },
  "current_bidder": {
    "id": "user_456",
    "name": "John Doe",
    "email": "john@example.com",
    "last_bid": "2024-12-17T15:45:00Z"
  },
  "total_bids": 5
};

final listMock = [
  {
    "id": "auction_123",
    "created_at": "2024-12-17T10:30:00Z",
    "base_price": 1000.00,
    "current_bid": 1500.50,
    "status": "active",
    "images": [
      "https://example.com/image1.jpg",
      "https://example.com/image2.jpg"
    ],
    "product": {
      "name": "Vintage Watch",
      "description": "Limited edition vintage watch from 1960",
      "category": "watches",
      "specifications": {
        "brand": "Omega",
        "year": "1960",
        "condition": "excellent",
        "material": "gold"
      }
    },
    "current_bidder": {
      "id": "user_456",
      "name": "John Doe",
      "email": "john@example.com",
      "last_bid": "2024-12-17T15:45:00Z"
    },
    "total_bids": 5
  },
  {
    "id": "auction_124",
    "created_at": "2024-12-16T12:15:00Z",
    "base_price": 500.00,
    "current_bid": 750.00,
    "status": "active",
    "images": [
      "https://example.com/image3.jpg",
      "https://example.com/image4.jpg"
    ],
    "product": {
      "name": "Antique Vase",
      "description": "Beautiful antique vase from the Qing Dynasty",
      "category": "antiques",
      "specifications": {
        "brand": "Unknown",
        "year": "1800",
        "condition": "good",
        "material": "ceramic"
      }
    },
    "current_bidder": {
      "id": "user_457",
      "name": "Alice Smith",
      "email": "alice@example.com",
      "last_bid": "2024-12-16T14:00:00Z"
    },
    "total_bids": 3
  },
  {
    "id": "auction_125",
    "created_at": "2024-12-18T08:45:00Z",
    "base_price": 2000.00,
    "current_bid": 2200.00,
    "status": "active",
    "images": [
      "https://example.com/image5.jpg",
      "https://example.com/image6.jpg"
    ],
    "product": {
      "name": "Luxury Car",
      "description": "Limited edition sports car with custom features",
      "category": "cars",
      "specifications": {
        "brand": "Ferrari",
        "year": "2022",
        "condition": "new",
        "material": "carbon fiber"
      }
    },
    "current_bidder": {
      "id": "user_458",
      "name": "Bob Johnson",
      "email": "bob@example.com",
      "last_bid": "2024-12-18T09:00:00Z"
    },
    "total_bids": 8
  }
];
