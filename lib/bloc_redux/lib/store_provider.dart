import 'package:flutter/material.dart';
import './bloc_redux.dart';

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
