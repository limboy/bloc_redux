import 'package:flutter/material.dart';
import './splash_store.dart';
import './splash_model.dart';
import '../../bloc_redux/lib/store_provider.dart';

class SplashWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: SplashStore(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Splash Widget'),
        ),
        body: Body(),
      ),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Loading(),
          LoadComplete(),
        ],
      ),
    );
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<SplashStore>(context);
    final items = store.state.output.items;
    return Flexible(
      flex: 2,
      child: Center(
        child: StreamBuilder<List<LoadItem>>(
          initialData: items.initialData,
          stream: items.stream,
          builder: (context, snapshot) {
            final items = snapshot.data;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: items.map((item) {
                var loadText = '';
                switch (item.status) {
                  case LoadingStatus.loading:
                    loadText = 'Loading...';
                    break;
                  case LoadingStatus.loaded:
                    loadText = '✔️';
                    break;
                  default:
                    loadText = '';
                }
                return Text('${item.description}: $loadText');
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class LoadComplete extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<SplashStore>(context);
    final loadComplete = store.state.output.loadComplete;
    return Flexible(
      flex: 1,
      child: Center(
        child: StreamBuilder(
          initialData: loadComplete.initialData,
          stream: loadComplete.stream,
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == true) {
              return Text('Load Complete');
            }
            return Container();
          },
        ),
      ),
    );
  }
}
