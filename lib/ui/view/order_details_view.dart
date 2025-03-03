import 'package:app/model/action_order_model.dart';
import 'package:app/service/marketpalce_service.dart';
import 'package:flutter/material.dart';
import 'package:reactive_notifier/reactive_notifier.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
      ),
      body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: ReactiveBuilder<AuctionOrder>(
                notifier: MarketplaceService.elementInstance,
                builder: (service, keep) {
                  return Column(
                    children: [
                      Text("${service.currentBidder?.name}"),
                      Text("${service.currentBid}"),
                      Text("${service.basePrice}"),
                      OutlinedButton(
                        onPressed: () {
                          MarketplaceService.elementInstance.transformState(
                              (dataB) => dataB.copyWith(basePrice: 1288777));
                        },
                        child: Text('Base price'),
                      )
                    ],
                  );
                }),
          )),
    );
  }
}

class ReactiveData extends ViewModelStateImpl<AuctionOrder> {
  ReactiveData() : super(AuctionOrder.mock());

  @override
  void init() {}
}
