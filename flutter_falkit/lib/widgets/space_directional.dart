import 'package:flutter_falkit/lib.dart';

class SpaceDirectional {
  SpaceDirectional._();

  ///==============///

  static EdgeInsetsGeometry insetAll(double value) =>
      EdgeInsetsDirectional.all(value);

  static EdgeInsetsGeometry insetOnly({
    double start = 0.0,
    double top = 0.0,
    double end = 0.0,
    double bottom = 0.0,
  }) =>
      EdgeInsetsDirectional.only(
        start: start,
        top: top,
        end: end,
        bottom: bottom,
      );

  static EdgeInsetsGeometry insetSymmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) =>
      EdgeInsetsDirectional.symmetric(
          horizontal: horizontal, vertical: vertical);

  static EdgeInsetsGeometry get insetZero =>
      EdgeInsetsDirectional.zero;

  static EdgeInsetsGeometry get insetAll1 =>
      const EdgeInsetsDirectional.all(1.0);

  static EdgeInsetsGeometry get insetAll2 =>
      const EdgeInsetsDirectional.all(2.0);

  static EdgeInsetsGeometry get insetAll4 =>
      const EdgeInsetsDirectional.all(4.0);

  static EdgeInsetsGeometry get insetAll6 =>
      const EdgeInsetsDirectional.all(6.0);

  static EdgeInsetsGeometry get insetAll8 =>
      const EdgeInsetsDirectional.all(8.0);

  static EdgeInsetsGeometry get insetAll10 =>
      const EdgeInsetsDirectional.all(10.0);

  static EdgeInsetsGeometry get insetAll12 =>
      const EdgeInsetsDirectional.all(12.0);

  static EdgeInsetsGeometry get insetAll14 =>
      const EdgeInsetsDirectional.all(14.0);

  static EdgeInsetsGeometry get insetAll16 =>
      const EdgeInsetsDirectional.all(16.0);

  static EdgeInsetsGeometry get insetAll18 =>
      const EdgeInsetsDirectional.all(18.0);

  static EdgeInsetsGeometry get insetAll20 =>
      const EdgeInsetsDirectional.all(20.0);

  static EdgeInsetsGeometry get insetAll24 =>
      const EdgeInsetsDirectional.all(24.0);

  static EdgeInsetsGeometry get insetAll32 =>
      const EdgeInsetsDirectional.all(32.0);

  static EdgeInsetsGeometry get insetAll40 =>
      const EdgeInsetsDirectional.all(40.0);

  static EdgeInsetsGeometry get insetAll56 =>
      const EdgeInsetsDirectional.all(56.0);

  static EdgeInsetsGeometry get insetAll64 =>
      const EdgeInsetsDirectional.all(64.0);

  static EdgeInsetsGeometry get insetAll72 =>
      const EdgeInsetsDirectional.all(72.0);

  ///==============///

  static EdgeInsetsGeometry get insetVertical1 =>
      const EdgeInsetsDirectional.symmetric(vertical: 1.0);

  static EdgeInsetsGeometry get insetVertical2 =>
      const EdgeInsetsDirectional.symmetric(vertical: 2.0);

  static EdgeInsetsGeometry get insetVertical4 =>
      const EdgeInsetsDirectional.symmetric(vertical: 4.0);

  static EdgeInsetsGeometry get insetVertical6 =>
      const EdgeInsetsDirectional.symmetric(vertical: 6.0);

  static EdgeInsetsGeometry get insetVertical8 =>
      const EdgeInsetsDirectional.symmetric(vertical: 8.0);

  static EdgeInsetsGeometry get insetVertical10 =>
      const EdgeInsetsDirectional.symmetric(vertical: 10.0);

  static EdgeInsetsGeometry get insetVertical12 =>
      const EdgeInsetsDirectional.symmetric(vertical: 12.0);

  static EdgeInsetsGeometry get insetVertical14 =>
      const EdgeInsetsDirectional.symmetric(vertical: 14.0);

  static EdgeInsetsGeometry get insetVertical16 =>
      const EdgeInsetsDirectional.symmetric(vertical: 16.0);

  static EdgeInsetsGeometry get insetVertical18 =>
      const EdgeInsetsDirectional.symmetric(vertical: 18.0);

  static EdgeInsetsGeometry get insetVertical20 =>
      const EdgeInsetsDirectional.symmetric(vertical: 20.0);

  static EdgeInsetsGeometry get insetVertical24 =>
      const EdgeInsetsDirectional.symmetric(vertical: 24.0);

  static EdgeInsetsGeometry get insetVertical32 =>
      const EdgeInsetsDirectional.symmetric(vertical: 32.0);

  static EdgeInsetsGeometry get insetVertical40 =>
      const EdgeInsetsDirectional.symmetric(vertical: 40.0);

  static EdgeInsetsGeometry get insetVertical56 =>
      const EdgeInsetsDirectional.symmetric(vertical: 56.0);

  static EdgeInsetsGeometry get insetVertical64 =>
      const EdgeInsetsDirectional.symmetric(vertical: 64.0);

  static EdgeInsetsGeometry get insetVertical72 =>
      const EdgeInsetsDirectional.symmetric(vertical: 72.0);

  ///==============///

  static EdgeInsetsGeometry get insetHorizontal1 =>
      const EdgeInsetsDirectional.symmetric(horizontal: 1.0);

  static EdgeInsetsGeometry get insetHorizontal2 =>
      const EdgeInsetsDirectional.symmetric(horizontal: 2.0);

  static EdgeInsetsGeometry get insetHorizontal4 =>
      const EdgeInsetsDirectional.symmetric(horizontal: 4.0);

  static EdgeInsetsGeometry get insetHorizontal6 =>
      const EdgeInsetsDirectional.symmetric(horizontal: 6.0);

  static EdgeInsetsGeometry get insetHorizontal8 =>
      const EdgeInsetsDirectional.symmetric(horizontal: 8.0);

  static EdgeInsetsGeometry get insetHorizontal10 =>
      const EdgeInsetsDirectional.symmetric(horizontal: 10.0);

  static EdgeInsetsGeometry get insetHorizontal12 =>
      const EdgeInsetsDirectional.symmetric(horizontal: 12.0);

  static EdgeInsetsGeometry get insetHorizontal14 =>
      const EdgeInsetsDirectional.symmetric(horizontal: 14.0);

  static EdgeInsetsGeometry get insetHorizontal16 =>
      const EdgeInsetsDirectional.symmetric(horizontal: 16.0);

  static EdgeInsetsGeometry get insetHorizontal18 =>
      const EdgeInsetsDirectional.symmetric(horizontal: 18.0);

  static EdgeInsetsGeometry get insetHorizontal20 =>
      const EdgeInsetsDirectional.symmetric(horizontal: 20.0);

  static EdgeInsetsGeometry get insetHorizontal24 =>
      const EdgeInsetsDirectional.symmetric(horizontal: 24.0);

  static EdgeInsetsGeometry get insetHorizontal32 =>
      const EdgeInsetsDirectional.symmetric(horizontal: 32.0);

  static EdgeInsetsGeometry get insetHorizontal40 =>
      const EdgeInsetsDirectional.symmetric(horizontal: 40.0);

  static EdgeInsetsGeometry get insetHorizontal56 =>
      const EdgeInsetsDirectional.symmetric(horizontal: 56.0);

  static EdgeInsetsGeometry get insetHorizontal64 =>
      const EdgeInsetsDirectional.symmetric(horizontal: 64.0);

  static EdgeInsetsGeometry get insetHorizontal72 =>
      const EdgeInsetsDirectional.symmetric(horizontal: 72.0);

  ///==============///
  static EdgeInsetsGeometry get insetStart1 =>
      const EdgeInsetsDirectional.only(start: 1.0);

  static EdgeInsetsGeometry get insetStart2 =>
      const EdgeInsetsDirectional.only(start: 2.0);

  static EdgeInsetsGeometry get insetStart4 =>
      const EdgeInsetsDirectional.only(start: 4.0);

  static EdgeInsetsGeometry get insetStart6 =>
      const EdgeInsetsDirectional.only(start: 6.0);

  static EdgeInsetsGeometry get insetStart8 =>
      const EdgeInsetsDirectional.only(start: 8.0);

  static EdgeInsetsGeometry get insetStart10 =>
      const EdgeInsetsDirectional.only(start: 10.0);

  static EdgeInsetsGeometry get insetStart12 =>
      const EdgeInsetsDirectional.only(start: 12.0);

  static EdgeInsetsGeometry get insetStart14 =>
      const EdgeInsetsDirectional.only(start: 14.0);

  static EdgeInsetsGeometry get insetStart16 =>
      const EdgeInsetsDirectional.only(start: 16.0);

  static EdgeInsetsGeometry get insetStart18 =>
      const EdgeInsetsDirectional.only(start: 18.0);

  static EdgeInsetsGeometry get insetStart20 =>
      const EdgeInsetsDirectional.only(start: 20.0);

  static EdgeInsetsGeometry get insetStart24 =>
      const EdgeInsetsDirectional.only(start: 24.0);

  static EdgeInsetsGeometry get insetStart32 =>
      const EdgeInsetsDirectional.only(start: 32.0);

  static EdgeInsetsGeometry get insetStart40 =>
      const EdgeInsetsDirectional.only(start: 40.0);

  static EdgeInsetsGeometry get insetStart56 =>
      const EdgeInsetsDirectional.only(start: 56.0);

  static EdgeInsetsGeometry get insetStart64 =>
      const EdgeInsetsDirectional.only(start: 64.0);

  static EdgeInsetsGeometry get insetStart72 =>
      const EdgeInsetsDirectional.only(start: 72.0);

  ///==============///
  ///
  static EdgeInsetsGeometry get insetEnd1 =>
      const EdgeInsetsDirectional.only(end: 1.0);

  static EdgeInsetsGeometry get insetEnd2 =>
      const EdgeInsetsDirectional.only(end: 2.0);

  static EdgeInsetsGeometry get insetEnd4 =>
      const EdgeInsetsDirectional.only(end: 4.0);

  static EdgeInsetsGeometry get insetEnd6 =>
      const EdgeInsetsDirectional.only(end: 6.0);

  static EdgeInsetsGeometry get insetEnd8 =>
      const EdgeInsetsDirectional.only(end: 8.0);

  static EdgeInsetsGeometry get insetEnd10 =>
      const EdgeInsetsDirectional.only(end: 10.0);

  static EdgeInsetsGeometry get insetEnd12 =>
      const EdgeInsetsDirectional.only(end: 12.0);

  static EdgeInsetsGeometry get insetEnd14 =>
      const EdgeInsetsDirectional.only(end: 14.0);

  static EdgeInsetsGeometry get insetEnd16 =>
      const EdgeInsetsDirectional.only(end: 16.0);

  static EdgeInsetsGeometry get insetEnd18 =>
      const EdgeInsetsDirectional.only(end: 18.0);

  static EdgeInsetsGeometry get insetEnd20 =>
      const EdgeInsetsDirectional.only(end: 20.0);

  static EdgeInsetsGeometry get insetEnd24 =>
      const EdgeInsetsDirectional.only(end: 24.0);

  static EdgeInsetsGeometry get insetEnd32 =>
      const EdgeInsetsDirectional.only(end: 32.0);

  static EdgeInsetsGeometry get insetEnd40 =>
      const EdgeInsetsDirectional.only(end: 40.0);

  static EdgeInsetsGeometry get insetEnd56 =>
      const EdgeInsetsDirectional.only(end: 56.0);

  static EdgeInsetsGeometry get insetEnd64 =>
      const EdgeInsetsDirectional.only(end: 64.0);

  static EdgeInsetsGeometry get insetEnd72 =>
      const EdgeInsetsDirectional.only(end: 72.0);

  ///==============///
  static EdgeInsetsGeometry get insetTop1 =>
      const EdgeInsetsDirectional.only(top: 1.0);

  static EdgeInsetsGeometry get insetTop2 =>
      const EdgeInsetsDirectional.only(top: 2.0);

  static EdgeInsetsGeometry get insetTop4 =>
      const EdgeInsetsDirectional.only(top: 4.0);

  static EdgeInsetsGeometry get insetTop6 =>
      const EdgeInsetsDirectional.only(top: 6.0);

  static EdgeInsetsGeometry get insetTop8 =>
      const EdgeInsetsDirectional.only(top: 8.0);

  static EdgeInsetsGeometry get insetTop10 =>
      const EdgeInsetsDirectional.only(top: 10.0);

  static EdgeInsetsGeometry get insetTop12 =>
      const EdgeInsetsDirectional.only(top: 12.0);

  static EdgeInsetsGeometry get insetTop14 =>
      const EdgeInsetsDirectional.only(top: 14.0);

  static EdgeInsetsGeometry get insetTop16 =>
      const EdgeInsetsDirectional.only(top: 16.0);

  static EdgeInsetsGeometry get insetTop18 =>
      const EdgeInsetsDirectional.only(top: 18.0);

  static EdgeInsetsGeometry get insetTop20 =>
      const EdgeInsetsDirectional.only(top: 20.0);

  static EdgeInsetsGeometry get insetTop24 =>
      const EdgeInsetsDirectional.only(top: 24.0);

  static EdgeInsetsGeometry get insetTop32 =>
      const EdgeInsetsDirectional.only(top: 32.0);

  static EdgeInsetsGeometry get insetTop40 =>
      const EdgeInsetsDirectional.only(top: 40.0);

  static EdgeInsetsGeometry get insetTop56 =>
      const EdgeInsetsDirectional.only(top: 56.0);

  static EdgeInsetsGeometry get insetTop64 =>
      const EdgeInsetsDirectional.only(top: 64.0);

  static EdgeInsetsGeometry get insetTop72 =>
      const EdgeInsetsDirectional.only(top: 72.0);

  ///==============///

  static EdgeInsetsGeometry get insetBottom1 =>
      const EdgeInsetsDirectional.only(bottom: 1.0);

  static EdgeInsetsGeometry get insetBottom2 =>
      const EdgeInsetsDirectional.only(bottom: 2.0);

  static EdgeInsetsGeometry get insetBottom4 =>
      const EdgeInsetsDirectional.only(bottom: 4.0);

  static EdgeInsetsGeometry get insetBottom6 =>
      const EdgeInsetsDirectional.only(bottom: 6.0);

  static EdgeInsetsGeometry get insetBottom8 =>
      const EdgeInsetsDirectional.only(bottom: 8.0);

  static EdgeInsetsGeometry get insetBottom10 =>
      const EdgeInsetsDirectional.only(bottom: 10.0);

  static EdgeInsetsGeometry get insetBottom12 =>
      const EdgeInsetsDirectional.only(bottom: 12.0);

  static EdgeInsetsGeometry get insetBottom14 =>
      const EdgeInsetsDirectional.only(bottom: 14.0);

  static EdgeInsetsGeometry get insetBottom16 =>
      const EdgeInsetsDirectional.only(bottom: 16.0);

  static EdgeInsetsGeometry get insetBottom18 =>
      const EdgeInsetsDirectional.only(bottom: 18.0);

  static EdgeInsetsGeometry get insetBottom20 =>
      const EdgeInsetsDirectional.only(bottom: 20.0);

  static EdgeInsetsGeometry get insetBottom24 =>
      const EdgeInsetsDirectional.only(bottom: 24.0);

  static EdgeInsetsGeometry get insetBottom32 =>
      const EdgeInsetsDirectional.only(bottom: 32.0);

  static EdgeInsetsGeometry get insetBottom40 =>
      const EdgeInsetsDirectional.only(bottom: 40.0);

  static EdgeInsetsGeometry get insetBottom56 =>
      const EdgeInsetsDirectional.only(bottom: 56.0);

  static EdgeInsetsGeometry get insetBottom64 =>
      const EdgeInsetsDirectional.only(bottom: 64.0);

  static EdgeInsetsGeometry get insetBottom72 =>
      const EdgeInsetsDirectional.only(bottom: 72.0);
}
