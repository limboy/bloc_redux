# Bloc_Redux

![](https://img.shields.io/pub/v/bloc_redux.svg)

Bloc_Redux is a combination of Bloc and Redux. OK, get it, but why?

Redux is an elegant pattern, which simplify the state management, and makes an unidirectional data flow. but it needs reducers return another state. by default it will make any widget using this state rebuild no matter if it has been modified. optimization can be made like diff to see the real changed properties, but not easy to do in flutter without reflection.

BLoC is a more general idea, UI trigger events using bloc's sink method, bloc handle it then change stream, UI receive latest stream value to reflect the change. it's vague on how to combine multi blocs or should there be only one per page? so it's more an idea than a spec.

so to get the most of both, here comes Bloc_Redux.

# Workflow

![](https://raw.githubusercontent.com/lzyy/bloc_redux/master/lib/bloc_redux/bloc_redux.png)

- actions are the only way to change state.
- blocs handle actions just like reducers but don't produce new states.
- widgets' data comes from state's stream, binded.

User trigger a button, it produces an action send to blocs, blocs which are interested in this action do some bussiness logic then change state by adding something new to stream, since streams are bind to widgets, UI are automatically updated.

# Detail

## bloc_redux.dart

```dart
import 'disposable.dart';

/// Useful when combined with StreamBuilder
class StreamWithInitialData<T> {
  final Stream<T> stream;
  final T initialData;

  StreamWithInitialData(this.stream, this.initialData);
}

/// Action
///
/// every action should extends this class
abstract class BRAction<T> {
  T playload;
}

/// State
///
/// Input are used to change state.
/// usually filled with StreamController / BehaviorSubject.
/// handled by blocs.
///
/// implements disposable because stream controllers needs to be disposed.
/// they will be called within store's dispose method.
abstract class BRStateInput implements Disposable {}

/// Output are streams.
/// followed by input. like someController.stream
/// UI will use it as data source.
abstract class BRStateOutput {}

/// State
///
/// Combine these two into one.
abstract class BRState<T extends BRStateInput, U extends BRStateOutput> {
  T input;
  U output;
}

/// Bloc
///
/// like reducers in redux, but don't return a new state.
/// when they found something needs to change, just update state's input
/// then state's output will change accordingly.
typedef Bloc<T extends BRStateInput> = void Function(BRAction action, T input);

/// Store
abstract class BRStore<T extends BRStateInput, U extends BRState>
    implements Disposable {
  List<Bloc<T>> blocs;
  U state;

  void dispatch(BRAction action) {
    blocs.forEach((f) => f(action, state.input));
  }

  // store will be disposed when provider disposed.
  dispose() {
    state.input.dispose();
  }
}
```

`StreamWithInitialData` is useful when consumed by `StreamBuilder` which needs `initialData`.

## store_provider.dart

borrowed from [here](https://www.didierboelens.com/2018/12/reactive-programming---streams---bloc---practical-use-cases/)

```dart
Type _typeOf<T>() => T;

class StoreProvider<T extends BRStore> extends StatefulWidget {
  StoreProvider({
    Key key,
    @required this.child,
    @required this.store,
  }) : super(key: key);

  final Widget child;
  final T store;

  @override
  _StoreProviderState<T> createState() => _StoreProviderState<T>();

  static T of<T extends BRStore>(BuildContext context) {
    final type = _typeOf<_StoreProviderInherited<T>>();
    _StoreProviderInherited<T> provider =
        context.ancestorInheritedElementForWidgetOfExactType(type)?.widget;
    return provider?.store;
  }
}

class _StoreProviderState<T extends BRStore> extends State<StoreProvider<T>> {
  @override
  void dispose() {
    widget.store?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new _StoreProviderInherited<T>(
      store: widget.store,
      child: widget.child,
    );
  }
}

class _StoreProviderInherited<T> extends InheritedWidget {
  _StoreProviderInherited({
    Key key,
    @required Widget child,
    @required this.store,
  }) : super(key: key, child: child);

  final T store;

  @override
  bool updateShouldNotify(_StoreProviderInherited oldWidget) => false;
}
```

# Demo

![](https://raw.githubusercontent.com/lzyy/bloc_redux/master/lib/bloc_redux/demo.gif)

## Color Demo

```dart
/// Actions
class ColorActionSelect extends BRAction<Color> {}

/// State
class ColorStateInput extends BRStateInput {
  final BehaviorSubject<Color> selectedColor = BehaviorSubject();
  final BehaviorSubject<List<ColorModel>> colors = BehaviorSubject();

  dispose() {
    selectedColor.close();
    colors.close();
  }
}

class ColorStateOutput extends BRStateOutput {
  StreamWithInitialData<Color> selectedColor;
  StreamWithInitialData<List<ColorModel>> colors;

  ColorStateOutput(ColorStateInput input) {
    selectedColor = StreamWithInitialData(
        input.selectedColor.stream, input.selectedColor.value);
    colors = StreamWithInitialData(input.colors.stream, input.colors.value);
  }
}

class ColorState extends BRState<ColorStateInput, ColorStateOutput> {
  ColorState() {
    input = ColorStateInput();

    var _colors = List<ColorModel>.generate(
        30, (int index) => ColorModel(RandomColor(index).randomColor()));
    _colors[0].isSelected = true;
    input.colors.add(_colors);

    input.selectedColor.add(_colors[0].color);
    output = ColorStateOutput(input);
  }
}

/// Blocs
Bloc<ColorStateInput> colorSelectHandler = (action, input) {
  if (action is ColorActionSelect) {
    input.selectedColor.add(action.playload);
    var colors = input.colors.value
        .map((colorModel) => colorModel
          ..isSelected = colorModel.color.value == action.playload.value)
        .toList();
    input.colors.add(colors);
  }
};

/// Store
class ColorStore extends BRStore<ColorStateInput, ColorState> {
  ColorStore() {
    state = ColorState();
    blocs = [colorSelectHandler];
  }
}
```

State is separated into `input` and `output`, `input` is used by `blocs`, if `bloc` find it's necessary to change state, it can add something new to stream. widgets will receive this change immediately by listening `output`.
