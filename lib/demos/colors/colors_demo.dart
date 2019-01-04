import 'package:flutter/material.dart';
import '../../stores/color_store.dart';
import '../../semi_redux/store_provider.dart';
import '../../models/color_model.dart';
import 'package:random_color/random_color.dart';

class ColorsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<ColorStore>(context);
    final colors = store.state.output.colors;
    return StreamBuilder<List<ColorModel>>(
      stream: colors.stream,
      initialData: colors.initialData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SliverToBoxAdapter(child: Container());
        }

        final colors = snapshot.data;
        return SliverGrid.count(
            crossAxisCount: 6,
            children: colors.map((colorModel) {
              return GestureDetector(
                onTap: () {
                  store.dispatch(
                      ColorActionSelect()..playload = colorModel.color);
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: colorModel.color,
                      border: Border.all(width: colorModel.isSelected ? 4 : 0)),
                ),
              );
            }).toList());
      },
    );
  }
}

class ColorDisplayWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<ColorStore>(context);
    final selectedColor = store.state.output.selectedColor;
    return Container(
      height: 100,
      child: StreamBuilder<Color>(
        stream: selectedColor.stream,
        initialData: selectedColor.initialData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          return Center(
              child: Text(getColorNameFromColor(snapshot.data).getName));
        },
      ),
    );
  }
}

class ColorsDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: ColorStore(),
      child: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              title: Text("Colors Demo"),
            ),
            SliverToBoxAdapter(
              child: ColorDisplayWidget(),
            ),
            ColorsWidget(),
          ],
        ),
      ),
    );
  }
}
