import 'package:app/model/action_order_model.dart';
import 'package:app/repository/marketplace_repository.dart';
import 'package:app/viewmodel/marketplace_viewmodel.dart';
import 'package:reactive_notifier/reactive_notifier.dart';

mixin MarketplaceService {
  static final ReactiveNotifier<MarketpalceVM> _instance =
      ReactiveNotifier<MarketpalceVM>(() {
    MarketplaceRepository repo = MarketplaceRepository();
    return MarketpalceVM(repo);
  }, related: [_elementSelected]);

  static final ReactiveNotifier<AuctionOrder> _elementSelected =
      ReactiveNotifier<AuctionOrder>(() {
    return AuctionOrder.mock();
  });

  static ReactiveNotifier<MarketpalceVM> get instance => _instance;

  static ReactiveNotifier<AuctionOrder> get elementInstance => _elementSelected;
}
