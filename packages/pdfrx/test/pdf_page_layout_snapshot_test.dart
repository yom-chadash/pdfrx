import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  test('immutable layout owns its list, rectangle values and document dimensions', () {
    final rectangle = _ChangingRect(10, 20, 30, 40);
    final dimensions = _ChangingSize(300, 400);
    final source = <Rect>[rectangle];
    final snapshot = PdfPageLayout.immutable(pageLayouts: source, documentSize: dimensions);

    rectangle
      ..x = 100
      ..y = 200
      ..w = 300
      ..h = 400;
    dimensions
      ..w = 800
      ..h = 900;
    source
      ..clear()
      ..add(const Rect.fromLTWH(50, 60, 70, 80));

    expect(snapshot.pageLayouts, [const Rect.fromLTWH(10, 20, 30, 40)]);
    expect(snapshot.documentSize, const Size(300, 400));
    expect(() => snapshot.pageLayouts[0] = Rect.zero, throwsUnsupportedError);
    expect(() => snapshot.pageLayouts.add(Rect.zero), throwsUnsupportedError);
  });

  test('ordinary layout keeps its existing mutable-list contract', () {
    final source = [const Rect.fromLTWH(0, 0, 100, 200)];
    final layout = PdfPageLayout(pageLayouts: source, documentSize: const Size(300, 400));
    source[0] = const Rect.fromLTWH(50, 60, 100, 200);
    expect(layout.pageLayouts, same(source));
    expect(layout.pageLayouts.single, const Rect.fromLTWH(50, 60, 100, 200));
  });

  test('equal immutable layouts retain value equality and independent revisions', () {
    final first = PdfPageLayout.immutable(
      pageLayouts: [const Rect.fromLTWH(0, 0, 100, 200)],
      documentSize: const Size(300, 400),
    );
    final second = PdfPageLayout.immutable(pageLayouts: first.pageLayouts, documentSize: first.documentSize);
    expect(second, first);
    expect(second, isNot(same(first)));
    expect(second.pageLayouts, isNot(same(first.pageLayouts)));
  });
}

class _ChangingRect extends Rect {
  _ChangingRect(this.x, this.y, this.w, this.h) : super.fromLTRB(0, 0, 0, 0);

  double x;
  double y;
  double w;
  double h;

  @override
  double get left => x;
  @override
  double get top => y;
  @override
  double get right => x + w;
  @override
  double get bottom => y + h;
}

class _ChangingSize extends Size {
  _ChangingSize(this.w, this.h) : super(0, 0);

  double w;
  double h;

  @override
  double get width => w;
  @override
  double get height => h;
}
