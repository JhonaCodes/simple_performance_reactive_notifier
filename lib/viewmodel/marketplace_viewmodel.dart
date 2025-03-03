import 'dart:developer';

import 'package:app/model/action_order_model.dart';
import 'package:app/repository/marketplace_repository.dart';
import 'package:reactive_notifier/reactive_notifier.dart';

class MarketpalceVM extends AsyncViewModelImpl<List<AuctionOrder>> {
  final MarketplaceRepository _repository;
  MarketpalceVM(this._repository) : super(AsyncState.initial());

  @override
  Future<List<AuctionOrder>> loadData() async {
    final response = await _repository.getAllOrders();

    return response.when<List<AuctionOrder>>(
      success: (data) {
        updateState(data);
        return data;
      },
      failure: (error, stackTrace) {
        log(error.toString());
        log(stackTrace.toString());
        errorState(error, stackTrace);
        throw Exception(error.toString());
      },
    );
  }

  void clear() {
    cleanState();
  }

  Future<void> reloadData() async {
    await reload();
  }

  void replaceData(List<AuctionOrder> replace) {
    updateState(replace);
  }
}
