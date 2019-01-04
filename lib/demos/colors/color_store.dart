import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:random_color/random_color.dart';
import './color_model.dart';
import '../../semi_redux/semi_redux.dart';

/// Actions
class ColorActionSelect extends SRAction<Color> {}

/// State
class ColorStateInput extends SRStateInput {
  final BehaviorSubject<Color> selectedColor = BehaviorSubject();
  final BehaviorSubject<List<ColorModel>> colors = BehaviorSubject();

  dispose() {
    selectedColor.close();
    colors.close();
  }
}

class ColorStateOutput extends SRStateOutput {
  StreamWithInitialData<Color> selectedColor;
  StreamWithInitialData<List<ColorModel>> colors;

  ColorStateOutput(ColorStateInput input) {
    selectedColor = StreamWithInitialData(
        input.selectedColor.stream, input.selectedColor.value);
    colors = StreamWithInitialData(input.colors.stream, input.colors.value);
  }
}

class ColorState extends SRState<ColorStateInput, ColorStateOutput> {
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
class ColorStore extends SRStore<ColorStateInput, ColorState> {
  ColorStore() {
    state = ColorState();
    blocs = [colorSelectHandler];
  }
}
