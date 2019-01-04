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

  dispose() {
    state.input.dispose();
  }
}
