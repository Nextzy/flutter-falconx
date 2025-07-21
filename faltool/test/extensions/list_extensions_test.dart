import 'package:dartx/dartx.dart';
import 'package:faltool/lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FalconToolListExtensions', () {
    test('removeNulls removes all null values', () {
      final items = [1, null, 2, null, 3];
      final cleaned = items.removeNulls();
      expect(cleaned, [1, 2, 3]);
      
      final noNulls = [1, 2, 3];
      expect(noNulls.removeNulls(), [1, 2, 3]);
      
      final allNulls = [null, null, null];
      expect(allNulls.removeNulls(), isEmpty);
    });

    test('mapAsync maps elements to futures', () async {
      final numbers = [1, 2, 3];
      final results = await numbers.mapAsync((n) async {
        await Future.delayed(Duration(milliseconds: 10));
        return n * 2;
      });
      expect(results, [2, 4, 6]);
    });

    test('copy creates shallow copy', () {
      final original = [1, 2, 3];
      final copy = original.copy();
      
      expect(copy, [1, 2, 3]);
      expect(identical(original, copy), false);
      
      copy.add(4);
      expect(original, [1, 2, 3]);
      expect(copy, [1, 2, 3, 4]);
    });

    test('deepCopy creates deep copy using copy function', () {
      final users = [
        {'name': 'Alice', 'age': 25},
        {'name': 'Bob', 'age': 30},
      ];
      
      final deepCopy = users.deepCopy((user) => Map<String, Object>.from(user));
      
      expect(deepCopy, users);
      expect(identical(users[0], deepCopy[0]), false);
      
      deepCopy[0]['age'] = 26;
      expect(users[0]['age'], 25);
      expect(deepCopy[0]['age'], 26);
    });

    test('edit modifies first matching element', () {
      final numbers = [1, 2, 3, 4, 5];
      final edited = numbers.edit(
        (n) => n > 3,
        (n) => n * 10,
      );
      
      expect(edited, true);
      expect(numbers, [1, 2, 3, 40, 5]);
      
      final notEdited = numbers.edit(
        (n) => n > 100,
        (n) => n * 10,
      );
      expect(notEdited, false);
    });

    test('editAll modifies all matching elements', () {
      final scores = [80, 90, 75, 95, 70];
      final count = scores.editAll(
        (score) => score < 80,
        (score) => 80,
      );
      
      expect(count, 2);
      expect(scores, [80, 90, 80, 95, 80]);
    });

    test('getOrDefault returns element or default value', () {
      final list = [1, 2, 3];
      
      expect(list.getOrDefault(1, -1), 2);
      expect(list.getOrDefault(5, -1), -1);
      expect(list.getOrDefault(-1, -1), -1);
    });

    test('removeFirst removes first matching element', () {
      final numbers = [1, 2, 3, 4, 5];
      final removed = numbers.removeFirst((n) => n > 3);
      
      expect(removed, true);
      expect(numbers, [1, 2, 3, 5]);
      
      final notRemoved = numbers.removeFirst((n) => n > 10);
      expect(notRemoved, false);
      expect(numbers, [1, 2, 3, 5]);
    });

    test('removeAll removes all matching elements', () {
      final numbers = [1, 2, 3, 4, 5, 6];
      final count = numbers.removeAll((n) => n % 2 == 0);
      
      expect(count, 3);
      expect(numbers, [1, 3, 5]);
    });

    test('removeDuplicates removes duplicate elements', () {
      final numbers = [1, 2, 2, 3, 1, 4, 3, 5];
      final unique = numbers.removeDuplicates();
      
      expect(unique, [1, 2, 3, 4, 5]);
      
      final empty = <int>[];
      expect(empty.removeDuplicates(), isEmpty);
    });

    test('removeDuplicatesBy removes duplicates by key function', () {
      final users = [
        {'name': 'Alice', 'age': 25},
        {'name': 'Bob', 'age': 30},
        {'name': 'Alice', 'age': 35},
        {'name': 'Charlie', 'age': 40},
      ];
      
      final unique = users.removeDuplicatesBy((u) => u['name']);
      expect(unique.length, 3);
      expect(unique[0]['name'], 'Alice');
      expect(unique[0]['age'], 25); // Keeps first occurrence
      expect(unique[1]['name'], 'Bob');
      expect(unique[2]['name'], 'Charlie');
    });

    test('move moves element from one index to another', () {
      final list = ['a', 'b', 'c', 'd'];
      list.move(0, 2);
      expect(list, ['b', 'c', 'a', 'd']);
      
      final list2 = ['a', 'b', 'c', 'd'];
      list2.move(3, 1);
      expect(list2, ['a', 'd', 'b', 'c']);
      
      // Same index should not change
      final list3 = ['a', 'b', 'c'];
      list3.move(1, 1);
      expect(list3, ['a', 'b', 'c']);
      
      // Out of bounds should throw
      expect(() => list.move(-1, 2), throwsRangeError);
      expect(() => list.move(0, 10), throwsRangeError);
    });

    test('rotate rotates list by specified positions', () {
      final list = [1, 2, 3, 4, 5];
      
      // Rotate right
      expect(list.rotate(2), [4, 5, 1, 2, 3]);
      
      // Rotate left
      expect(list.rotate(-2), [3, 4, 5, 1, 2]);
      
      // No rotation
      expect(list.rotate(0), [1, 2, 3, 4, 5]);
      expect(list.rotate(5), [1, 2, 3, 4, 5]); // Full rotation
      
      // Large rotation
      expect(list.rotate(7), [4, 5, 1, 2, 3]); // Same as rotate(2)
      
      // Empty list
      expect(<int>[].rotate(2), isEmpty);
    });

    test('splitAt splits list at index', () {
      final list = [1, 2, 3, 4, 5];
      
      final (left1, right1) = list.splitAt(3);
      expect(left1, [1, 2, 3]);
      expect(right1, [4, 5]);
      
      final (left2, right2) = list.splitAt(0);
      expect(left2, isEmpty);
      expect(right2, [1, 2, 3, 4, 5]);
      
      final (left3, right3) = list.splitAt(5);
      expect(left3, [1, 2, 3, 4, 5]);
      expect(right3, isEmpty);
      
      // Out of bounds
      expect(() => list.splitAt(-1), throwsRangeError);
      expect(() => list.splitAt(6), throwsRangeError);
    });

    test('indicesWhere returns indices of matching elements', () {
      final numbers = [1, 2, 3, 2, 4, 2, 5];
      final indices = numbers.indicesWhere((n) => n == 2);
      expect(indices, [1, 3, 5]);
      
      final noMatch = numbers.indicesWhere((n) => n > 10);
      expect(noMatch, isEmpty);
      
      final allMatch = numbers.indicesWhere((n) => n > 0);
      expect(allMatch, [0, 1, 2, 3, 4, 5, 6]);
    });

    test('insertUnique inserts element if not exists', () {
      final set = [1, 2, 3];
      
      final inserted = set.insertUnique(4);
      expect(inserted, true);
      expect(set, [1, 2, 3, 4]);
      
      final notInserted = set.insertUnique(2);
      expect(notInserted, false);
      expect(set, [1, 2, 3, 4]);
    });

    test('binarySearch finds element in sorted list', () {
      final sorted = [1, 3, 5, 7, 9, 11];
      
      // Using dartx's binarySearch
      expect(sorted.binarySearch(5, compare: (a, b) => a.compareTo(b)), 2);
      expect(sorted.binarySearch(1, compare: (a, b) => a.compareTo(b)), 0);
      expect(sorted.binarySearch(11, compare: (a, b) => a.compareTo(b)), 5);
      expect(sorted.binarySearch(6, compare: (a, b) => a.compareTo(b)), isNegative); // Not found
      expect(sorted.binarySearch(0, compare: (a, b) => a.compareTo(b)), isNegative); // Too small
      expect(sorted.binarySearch(12, compare: (a, b) => a.compareTo(b)), isNegative); // Too large
      
      // Empty list
      expect(<int>[].binarySearch(5, compare: (a, b) => a.compareTo(b)), isNegative);
      
      // Single element
      expect([5].binarySearch(5, compare: (a, b) => a.compareTo(b)), 0);
      expect([5].binarySearch(3, compare: (a, b) => a.compareTo(b)), isNegative);
    });

    test('binarySearch with custom comparator', () {
      final users = [
        {'name': 'Alice', 'age': 25},
        {'name': 'Bob', 'age': 30},
        {'name': 'Charlie', 'age': 35},
      ];
      
      // Using dartx's binarySearch with custom comparator
      final index = users.binarySearch(
        {'name': 'Bob', 'age': 30},
        compare: (a, b) => (a['name'] as String).compareTo(b['name'] as String),
      );
      expect(index, 1);
    });

    test('insertSorted maintains sorted order', () {
      final sorted = [1, 3, 5, 7];
      
      sorted.insertSorted(4);
      expect(sorted, [1, 3, 4, 5, 7]);
      
      sorted.insertSorted(0);
      expect(sorted, [0, 1, 3, 4, 5, 7]);
      
      sorted.insertSorted(10);
      expect(sorted, [0, 1, 3, 4, 5, 7, 10]);
      
      // Empty list
      final empty = <int>[];
      empty.insertSorted(5);
      expect(empty, [5]);
    });

    test('insertSorted with custom comparator', () {
      final users = [
        {'name': 'Alice', 'age': 25},
        {'name': 'Charlie', 'age': 35},
      ];
      
      users.insertSorted(
        {'name': 'Bob', 'age': 30},
        (a, b) => (a['name'] as String).compareTo(b['name'] as String),
      );
      
      expect(users[1]['name'], 'Bob');
    });

    test('padRight pads list to minimum length', () {
      final list = [1, 2, 3];
      
      expect(list.padRight(5, 0), [1, 2, 3, 0, 0]);
      expect(list.padRight(3, 0), [1, 2, 3]); // No padding needed
      expect(list.padRight(1, 0), [1, 2, 3]); // Already longer
      
      expect(<int>[].padRight(3, 5), [5, 5, 5]);
    });

    test('padLeft pads list at beginning', () {
      final list = [1, 2, 3];
      
      expect(list.padLeft(5, 0), [0, 0, 1, 2, 3]);
      expect(list.padLeft(3, 0), [1, 2, 3]); // No padding needed
      expect(list.padLeft(1, 0), [1, 2, 3]); // Already longer
      
      expect(<int>[].padLeft(3, 5), [5, 5, 5]);
    });

    test('countBy counts occurrences of elements', () {
      final items = ['a', 'b', 'a', 'c', 'b', 'a'];
      final counts = items.countBy();
      
      expect(counts['a'], 3);
      expect(counts['b'], 2);
      expect(counts['c'], 1);
      expect(counts['d'], null);
      
      expect(<String>[].countBy(), isEmpty);
    });

    test('mode finds most common elements', () {
      final items = ['a', 'b', 'a', 'c', 'b', 'a'];
      expect(items.mode(), ['a']);
      
      final items2 = ['a', 'b', 'a', 'b', 'c'];
      final modes = items2.mode();
      expect(modes.length, 2);
      expect(modes.contains('a'), true);
      expect(modes.contains('b'), true);
      
      expect(<String>[].mode(), isEmpty);
      
      final single = ['a'];
      expect(single.mode(), ['a']);
    });
  });

  group('FalconToolListNullableExtensions', () {
    test('futureAsyncMap maps elements asynchronously', () async {
      List<int>? numbers = [1, 2, 3];
      final results = await numbers.futureAsyncMap((n) async {
        await Future.delayed(Duration(milliseconds: 10));
        return n * 2;
      });
      expect(results, [2, 4, 6]);
      
      // Null list
      List<int>? nullList;
      final nullResults = await nullList.futureAsyncMap((n) => n * 2);
      expect(nullResults, isEmpty);
    });

    test('orEmpty returns list or empty list', () {
      List<int>? numbers = [1, 2, 3];
      expect(numbers.orEmpty, [1, 2, 3]);
      
      List<int>? nullList;
      expect(nullList.orEmpty, isEmpty);
      
      List<int>? emptyList = [];
      expect(emptyList.orEmpty, isEmpty);
    });

    test('getOrNull safely gets element at index', () {
      List<int>? numbers = [1, 2, 3];
      expect(numbers.getOrNull(1), 2);
      expect(numbers.getOrNull(5), null);
      expect(numbers.getOrNull(-1), null);
      
      List<int>? nullList;
      expect(nullList.getOrNull(0), null);
    });

    test('ifNotEmpty executes action for non-empty lists', () {
      List<int>? numbers = [1, 2, 3];
      var executed = false;
      numbers.ifNotEmpty((list) {
        executed = true;
        expect(list, [1, 2, 3]);
      });
      expect(executed, true);
      
      // Null list
      List<int>? nullList;
      var nullExecuted = false;
      nullList.ifNotEmpty((list) {
        nullExecuted = true;
      });
      expect(nullExecuted, false);
      
      // Empty list
      List<int>? emptyList = [];
      var emptyExecuted = false;
      emptyList.ifNotEmpty((list) {
        emptyExecuted = true;
      });
      expect(emptyExecuted, false);
    });
  });
}