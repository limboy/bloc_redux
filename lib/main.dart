import 'package:flutter/material.dart';
import './bloc_redux/store_provider.dart';
import './demos/colors/color_widget.dart';
import './demos/splash/splash_widget.dart';
import './demos/shop/shop_widget.dart';
import './demos/shop/shop_store.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: ShopStore(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Semi Redux Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Semi Redux Demo'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.red),
              child: Center(
                child: FlatButton(
                  child: Text(
                    'Color Demo',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ColorWidget()));
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.yellow),
              child: Center(
                child: FlatButton(
                  child: Text(
                    'Splash Demo',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SplashWidget()));
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.green),
              child: Center(
                child: FlatButton(
                  child: Text(
                    'Shop Demo',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ShopWidget()));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
