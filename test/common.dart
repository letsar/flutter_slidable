import 'package:flutter/foundation.dart';
import 'package:flutter_slidable/src/controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

typedef ValueOrNull = T Function<T>(int index);

class MockSlidableController extends Mock implements SlidableController {}

class FakeSlidableController extends Fake implements SlidableController {
  final List<String> logs = <String>[];

  @override
  double ratio = 0;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName;
    final namedArguments = invocation.namedArguments;
    final positionalArguments = invocation.positionalArguments;
    logs.add('m: $memberName, n: $namedArguments, p:$positionalArguments');
  }
}

void testConstructorAsserts({
  @required List<Object> values,
  @required Object Function(ValueOrNull valueOrNull) factory,
}) {
  for (var i = 0; i < values.length; i++) {
    T valueOrNull<T>(int index) {
      return index == i ? null : values[index] as T;
    }

    expect(() => factory(valueOrNull), throwsAssertionError);
  }
}

extension CommonFindersX on CommonFinders {
  Finder byTypeOf<T>() => byType(T);
}
