import 'dart:convert';

import 'package:app/api/api_service.dart';
import 'package:app/api/hanlder.dart';
import 'package:app/model/action_order_model.dart';
import 'package:reactive_notifier/reactive_notifier.dart';

class MarketplaceRepository
    implements RepositoryImpl<Result<List<AuctionOrder>>> {
  Future<Result<List<AuctionOrder>>> getAllOrders() async {
    final response = await ApiService.get();

    if (!response.isSuccess) return Result.error(response.error);

    List<Map<String, dynamic>> responseListMap =
        List<Map<String, dynamic>>.from(json.decode(response.data));
    List<AuctionOrder> auctionOrderList =
        responseListMap.map(AuctionOrder.fromJson).toList();

    return Result.success(auctionOrderList);
  }
}
