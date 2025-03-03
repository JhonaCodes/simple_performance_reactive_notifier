import 'dart:developer';

import 'package:app/model/action_order_model.dart';
import 'package:app/service/marketpalce_service.dart';
import 'package:app/ui/widget/order_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:reactive_notifier/reactive_notifier.dart';

final ReactiveNotifier<IconData> _iconReactive = ReactiveNotifier(
    () => Icons.account_circle_outlined,
    related: [_textRelated]);
final ReactiveNotifier<String> _textRelated = ReactiveNotifier(() => "Nothing");

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ReactiveBuilder(
          notifier: _iconReactive,
          builder: (state, keep) => Row(
            children: [
              Icon(state),
              Text(_iconReactive.from(_textRelated.keyNotifier)),
            ],
          ),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ReactiveAsyncBuilder<List<AuctionOrder>>(
            notifier: MarketplaceService.instance.notifier,
            onSuccess: (data) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    ...data.map((info) => OrderCardWidget(info)),
                  ],
                ),
              );
            },
            onError: (error, stackTrace) {
              log(error.toString());
              log(stackTrace.toString());

              return Text(error.toString());
            },
          )),
      bottomNavigationBar: Row(
        children: [
          OutlinedButton(
              onPressed: () {
                MarketplaceService.instance.notifier
                    .replaceData([AuctionOrder.mock()]);
              },
              child: Text('Eliminar')),
          OutlinedButton(
              onPressed: () async {
                _iconReactive.updateState(Icons.access_time_filled);
                _iconReactive.updateState(Icons.access_time_filled);

                _iconReactive.from(_textRelated.keyNotifier);
              },
              child: Text('Change Icon')),
        ],
      ),
    );
  }
}
