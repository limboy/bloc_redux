import 'package:rxdart/rxdart.dart';
import 'package:random_color/random_color.dart';
import './shop_model.dart';
import '../../bloc_redux/lib/bloc_redux.dart';

/// Actions
class AddToBasketAction extends BRAction<ShoppingItem> {}

class RemoveFromBasketAction extends BRAction<ShoppingItem> {}

/// State
class ShopStateInput extends BRStateInput {
  final basket = BehaviorSubject<List<ShoppingItem>>(seedValue: []);
  final items = BehaviorSubject<List<ShoppingItem>>(seedValue: []);

  dispose() {
    basket.close();
    items.close();
  }
}

class ShopStateOutput extends BRStateOutput {
  StreamWithInitialData<List<ShoppingItem>> basket;
  StreamWithInitialData<List<ShoppingItem>> items;

  ShopStateOutput(ShopStateInput input) {
    basket = StreamWithInitialData(input.basket.stream, input.basket.value);
    items = StreamWithInitialData(input.items.stream, input.items.value);
  }
}

class ShopState extends BRState<ShopStateInput, ShopStateOutput> {
  ShopState() {
    input = ShopStateInput();
    output = ShopStateOutput(input);
  }
}

/// Blocs
final Bloc<ShopStateInput> addItemHandler = (action, input) {
  if (action is AddToBasketAction) {
    final item = action.payload;
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
    final item = action.payload;
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
class ShopStore extends BRStore<ShopStateInput, ShopState> {
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
