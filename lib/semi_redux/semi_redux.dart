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
abstract class SRAction<T> {
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
abstract class SRStateInput implements Disposable {}

/// Output are streams.
/// followed by input. like someController.stream
/// UI will use it as data source.
abstract class SRStateOutput {}

/// State
///
/// Combine these two into one.
abstract class SRState<T extends SRStateInput, U extends SRStateOutput> {
  T input;
  U output;
}

/// Bloc
///
/// like reducers in redux, but don't return a new state.
/// when they found something needs to change, just update state's input
/// then state's output will change accordingly.
typedef Bloc<T extends SRAction, U extends SRState> = void Function(
    T action, U state);

/// Store
abstract class Store<T extends SRAction, U extends SRState>
    implements Disposable {
  List<Bloc<T, U>> blocs;
  U state;

  void dispatch(T action) {
    blocs.forEach((f) => f(action, state));
  }

  dispose() {
    state.input.dispose();
  }
}
