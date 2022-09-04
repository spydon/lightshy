import 'dart:math';

final Random random = Random();

extension RandomExtension on Random {
  T fromList<T>(List<T> list) => list[nextInt(list.length)];
}
