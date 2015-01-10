import 'package:scheduled_test/scheduled_test.dart';
import 'dart:io';

void main() {
  test('writing to a file and reading it back should work', () {
    schedule(() {
      // The schedule won't proceed until the returned Future has
      // completed.
      return new File("output.txt").writeAsString("contents");
    });

    schedule(() {
      return new File("output.txt").readAsString().then((contents) {
        // The normal unittest matchers can still be used.
        expect(contents, equals("contents"));
      });
    });
  });
}
