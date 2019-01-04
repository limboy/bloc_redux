import 'package:flutter/material.dart';
import '../../bloc_redux/lib/store_provider.dart';
import './shop_store.dart';
import './shop_model.dart';

class ShopWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<ShopStore>(context);
    final items = store.state.output.items;
    final basket = store.state.output.basket;
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Demo'),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return _BasketWidget();
              }));
            },
            child: StreamBuilder<List<ShoppingItem>>(
              initialData: basket.initialData,
              stream: basket.stream,
              builder: (context, snapshot) {
                return Container(
                  width: 24,
                  height: 24,
                  margin: EdgeInsets.only(right: 20),
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                  child: Center(child: Text('${snapshot.data.length}')),
                );
              },
            ),
          )
        ],
      ),
      body: StreamBuilder<List<ShoppingItem>>(
          initialData: items.initialData,
          stream: items.stream,
          builder: (context, snapshot) {
            final items = snapshot.data;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () {
                    store.dispatch(AddToBasketAction()..playload = item);
                  },
                  child: Container(
                    decoration: BoxDecoration(color: item.color),
                    child: Center(
                      child: Text(item.addable == true ? "Add To Cart" : ""),
                    ),
                  ),
                );
              },
              itemCount: items.length,
            );
          }),
    );
  }
}

class _BasketWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<ShopStore>(context);
    final basket = store.state.output.basket;
    return Scaffold(
      appBar: AppBar(
        title: Text('Basket'),
        actions: <Widget>[
          GestureDetector(
            child: StreamBuilder<List<ShoppingItem>>(
              initialData: basket.initialData,
              stream: basket.stream,
              builder: (context, snapshot) {
                return Container(
                  width: 24,
                  height: 24,
                  margin: EdgeInsets.only(right: 20),
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                  child: Center(child: Text('${snapshot.data.length}')),
                );
              },
            ),
          )
        ],
      ),
      body: StreamBuilder<List<ShoppingItem>>(
          initialData: basket.initialData,
          stream: basket.stream,
          builder: (context, snapshot) {
            final items = snapshot.data;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () {
                    store.dispatch(RemoveFromBasketAction()..playload = item);
                  },
                  child: Container(
                    decoration: BoxDecoration(color: item.color),
                    child: Center(
                      child: Text("Put Back"),
                    ),
                  ),
                );
              },
              itemCount: items.length,
            );
          }),
    );
  }
}
