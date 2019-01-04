import 'package:rxdart/rxdart.dart';
import 'package:random_color/random_color.dart';
import './shop_model.dart';
import '../../semi_redux/semi_redux.dart';

/// Actions
class AddToBasketAction extends SRAction<ShoppingItem> {}

class RemoveFromBasketAction extends SRAction<ShoppingItem> {}

/// State
class ShopStateInput extends SRStateInput {
  final basket = BehaviorSubject<List<ShoppingItem>>(seedValue: []);
  final items = BehaviorSubject<List<ShoppingItem>>(seedValue: []);

  dispose() {
    basket.close();
    items.close();
  }
}

class ShopStateOutput extends SRStateOutput {
  StreamWithInitialData<List<ShoppingItem>> basket;
  StreamWithInitialData<List<ShoppingItem>> items;

  ShopStateOutput(ShopStateInput input) {
    basket = StreamWithInitialData(input.basket.stream, input.basket.value);
    items = StreamWithInitialData(input.items.stream, input.items.value);
  }
}

class ShopState extends SRState<ShopStateInput, ShopStateOutput> {
  ShopState() {
    input = ShopStateInput();
    output = ShopStateOutput(input);
  }
}

/// Blocs
final Bloc<ShopStateInput> addItemHandler = (action, input) {
  if (action is AddToBasketAction) {
    final item = action.playload;
    final basket = input.basket.value;
    if (!basket.contains(item)) {
      item.addable = false;
      basket.add(item);
    }
    input.basket.add(List.of(basket));
    input.items.add(List.of(input.items.value));
  }
};

final Bloc<ShopStateInput> removeItemHandler = (action, input) {
  if (action is RemoveFromBasketAction) {
    final item = action.playload;
    final basket = input.basket.value;
    if (basket.contains(item)) {
      basket.remove(item);
      item.addable = true;
    }
    input.basket.add(List.of(basket));
    input.items.add(List.of(input.items.value));
  }
};

/// Store
class ShopStore extends SRStore<ShopStateInput, ShopState> {
  ShopStore() {
    state = ShopState();
    blocs = [addItemHandler, removeItemHandler];

    // init
    final items = List<ShoppingItem>.generate(18, (index) {
      return ShoppingItem(id: index, color: RandomColor(index).randomColor());
    });
    state.input.items.add(items);
  }
}
