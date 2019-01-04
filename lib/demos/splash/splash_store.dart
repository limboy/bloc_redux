import '../../bloc_redux/bloc_redux.dart';
import './splash_model.dart';
import 'package:rxdart/rxdart.dart';

/// Actioins
class ActionLoadInit extends BRAction {}

class ActionLoadConfig extends BRAction {}

class ActionLoadContent extends BRAction {}

class ActionLoadComplete extends BRAction {}

/// State
class SplashStateInput extends BRStateInput {
  final items = BehaviorSubject<List<LoadItem>>();
  final loadComplete = BehaviorSubject<bool>(seedValue: false);

  SplashStateInput() {
    var loadInit =
        LoadItem(LoadingStatus.notLoading, LoadingPhase.init, "App Init");
    var loadConfig = LoadItem(
        LoadingStatus.notLoading, LoadingPhase.config, "App Loading Config");
    var loadContent = LoadItem(
        LoadingStatus.notLoading, LoadingPhase.content, "App Loading Content");

    final loadItems = List.of([loadInit, loadConfig, loadContent]);
    items.add(loadItems);
  }

  dispose() {
    items.close();
    loadComplete.close();
  }
}

class SplashStateOutput extends BRStateOutput {
  StreamWithInitialData<List<LoadItem>> items;
  StreamWithInitialData<bool> loadComplete;
  SplashStateOutput(SplashStateInput input) {
    items = StreamWithInitialData(input.items.stream, input.items.value);
    loadComplete = StreamWithInitialData(
        input.loadComplete.stream, input.loadComplete.value);
  }
}

class SplashState extends BRState<SplashStateInput, SplashStateOutput> {
  SplashState() {
    input = SplashStateInput();
    output = SplashStateOutput(input);
  }
}

/// Blocs
final Bloc<SplashStateInput> initHandler = (action, input) {
  if (action is ActionLoadInit) {
    // change state to loading
    var initItem =
        input.items.value.firstWhere((item) => item.phase == LoadingPhase.init);
    initItem.status = LoadingStatus.loading;
    input.items.add(List.unmodifiable(input.items.value));

    // assume we have finished loading
    Future.delayed(Duration(milliseconds: 1000)).then((_) {
      var initItem = input.items.value
          .firstWhere((item) => item.phase == LoadingPhase.init);
      initItem.status = LoadingStatus.loaded;
      input.items.add(List.unmodifiable(input.items.value));

      // dispatch next task
      _storeInstance.dispatch(ActionLoadConfig());
    });
  }
};

final Bloc<SplashStateInput> configHandler = (action, input) {
  if (action is ActionLoadConfig) {
    // change state to loading
    var configItem = input.items.value
        .firstWhere((item) => item.phase == LoadingPhase.config);
    configItem.status = LoadingStatus.loading;
    input.items.add(List.unmodifiable(input.items.value));

    // assume we have finished loading
    Future.delayed(Duration(milliseconds: 1000)).then((_) {
      var configItem = input.items.value
          .firstWhere((item) => item.phase == LoadingPhase.config);
      configItem.status = LoadingStatus.loaded;
      input.items.add(List.unmodifiable(input.items.value));

      // dispatch next task
      _storeInstance.dispatch(ActionLoadContent());
    });
  }
};

final Bloc<SplashStateInput> contentHandler = (action, input) {
  if (action is ActionLoadContent) {
    // change state to loading
    var contentItem = input.items.value
        .firstWhere((item) => item.phase == LoadingPhase.content);
    contentItem.status = LoadingStatus.loading;
    input.items.add(List.unmodifiable(input.items.value));

    // assume we have finished loading
    Future.delayed(Duration(milliseconds: 1000)).then((_) {
      var contentItem = input.items.value
          .firstWhere((item) => item.phase == LoadingPhase.content);
      contentItem.status = LoadingStatus.loaded;
      input.items.add(List.unmodifiable(input.items.value));

      // dispatch next task
      _storeInstance.dispatch(ActionLoadComplete());
    });
  }
};

final Bloc<SplashStateInput> completeHandler = (action, input) {
  if (action is ActionLoadComplete) {
    input.loadComplete.add(true);
  }
};

/// Store
class SplashStore extends BRStore<SplashStateInput, SplashState> {
  SplashStore() {
    _storeInstance = this;
    state = SplashState();
    blocs = [initHandler, configHandler, contentHandler, completeHandler];

    // let's go!
    this.dispatch(ActionLoadInit());
  }
}

/// Save last created store
/// because we can't access store w/out context
SplashStore _storeInstance;
