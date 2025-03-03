import 'package:app/model/action_order_model.dart';
import 'package:app/service/marketpalce_service.dart';
import 'package:app/ui/view/order_details_view.dart';
import 'package:flutter/material.dart';

class OrderCardWidget extends StatelessWidget {
  final AuctionOrder order;

  const OrderCardWidget(this.order, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: double.infinity,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.product.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        order.status.name,
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  Text(order.product.description),
                  Divider(),
                  Text("${order.currentBidder?.name}"),
                  Text("${order.currentBidder?.email}"),
                  Divider(),
                  Text("Current bid: ${order.currentBid}"),
                  Text("Minimum price: ${order.basePrice}"),
                  Divider(),
                  Row(
                    spacing: 10,
                    children: [
                      Text("Last bid: "),
                      Text("${order.currentBidder?.lastBid}"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        onTap: () {
          MarketplaceService.elementInstance.updateState(order);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const OrderDetailsView()));
        });
  }
}
