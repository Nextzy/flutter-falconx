import 'package:faltool/lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FalconToolMapExtension', () {
    group('removeNullOrEmptyString', () {
      test('should remove null values', () {
        final map = {
          'name': 'John',
          'age': null,
          'city': 'NYC',
        };
        final cleaned = map.removeNullOrEmptyString();
        expect(cleaned, {'name': 'John', 'city': 'NYC'});
      });

      test('should remove empty strings', () {
        final map = {
          'name': 'John',
          'email': '',
          'phone': '123456',
        };
        final cleaned = map.removeNullOrEmptyString();
        expect(cleaned, {'name': 'John', 'phone': '123456'});
      });

      test('should recursively clean nested maps', () {
        final map = {
          'name': 'John',
          'age': null,
          'address': {
            'street': '',
            'city': 'NYC',
            'zip': null,
          },
        };
        final cleaned = map.removeNullOrEmptyString();
        expect(cleaned, {
          'name': 'John',
          'address': {'city': 'NYC'},
        });
      });

      test('should clean nested lists', () {
        final map = {
          'name': 'John',
          'hobbies': ['reading', null, '', 'gaming'],
          'scores': [10, null, 20],
        };
        final cleaned = map.removeNullOrEmptyString();
        expect(cleaned, {
          'name': 'John',
          'hobbies': ['reading', 'gaming'],
          'scores': [10, 20],
        });
      });

      test('should handle empty map', () {
        final map = <String, dynamic>{};
        final cleaned = map.removeNullOrEmptyString();
        expect(cleaned, {});
      });

      test('should handle deeply nested structures', () {
        final map = <String, dynamic>{
          'level1': {
            'level2': {
              'level3': {
                'value': 'deep',
                'empty': '',
                'null': null,
              },
            },
          },
        };
        final cleaned = map.removeNullOrEmptyString();
        expect(cleaned, {
          'level1': {
            'level2': {
              'level3': {'value': 'deep'},
            },
          },
        });
      });
    });

    group('getOrDefault', () {
      test('should return value when key exists', () {
        final map = {'a': 1, 'b': 2, 'c': 3};
        expect(map.getOrDefault('b', 0), 2);
      });

      test('should return default when key does not exist', () {
        final map = {'a': 1, 'b': 2, 'c': 3};
        expect(map.getOrDefault('d', 0), 0);
      });

      test('should handle null values correctly', () {
        final map = {'a': 1, 'b': null, 'c': 3};
        expect(map.getOrDefault('b', 0), 0);
      });
    });

    group('where', () {
      test('should filter entries based on predicate', () {
        final scores = {'alice': 95, 'bob': 87, 'charlie': 92};
        final highScores = scores.where((k, v) => v >= 90);
        expect(highScores, {'alice': 95, 'charlie': 92});
      });

      test('should filter by key', () {
        final data = {'name': 'John', '_id': '123', '_temp': 'value', 'age': '30'};
        final public = data.where((k, v) => !k.startsWith('_'));
        expect(public, {'name': 'John', 'age': '30'});
      });

      test('should handle empty map', () {
        final empty = <String, int>{};
        final filtered = empty.where((k, v) => v > 0);
        expect(filtered, {});
      });

      test('should return empty map when no matches', () {
        final scores = {'alice': 95, 'bob': 87, 'charlie': 92};
        final filtered = scores.where((k, v) => v > 100);
        expect(filtered, {});
      });
    });

    group('merge', () {
      test('should merge two maps', () {
        final map1 = {'a': 1, 'b': 2};
        final map2 = {'c': 3, 'd': 4};
        final merged = map1.merge(map2, null);
        expect(merged, {'a': 1, 'b': 2, 'c': 3, 'd': 4});
      });

      test('should use resolver for conflicts', () {
        final defaults = <String, dynamic>{'timeout': 30, 'retries': 3};
        final custom = <String, dynamic>{'timeout': 60, 'debug': true};
        final config = defaults.merge(custom, (a, b) => b);
        expect(config, {'timeout': 60, 'retries': 3, 'debug': true});
      });

      test('should keep first value when no resolver', () {
        final map1 = {'a': 1, 'b': 2};
        final map2 = {'b': 3, 'c': 4};
        final merged = map1.merge(map2, null);
        expect(merged, {'a': 1, 'b': 3, 'c': 4});
      });

      test('should handle empty maps', () {
        final map1 = <String, int>{};
        final map2 = {'a': 1, 'b': 2};
        final merged = map1.merge(map2, null);
        expect(merged, {'a': 1, 'b': 2});
      });

      test('should use custom conflict resolution', () {
        final map1 = {'a': 10, 'b': 20};
        final map2 = {'b': 30, 'c': 40};
        final merged = map1.merge(map2, (a, b) => a + b);
        expect(merged, {'a': 10, 'b': 50, 'c': 40});
      });
    });

    group('invert', () {
      test('should invert map keys and values', () {
        final codes = {'US': 'United States', 'UK': 'United Kingdom'};
        final countries = codes.invert();
        expect(countries, {'United States': 'US', 'United Kingdom': 'UK'});
      });

      test('should handle duplicate values by keeping last', () {
        final map = {'a': 1, 'b': 2, 'c': 1};
        final inverted = map.invert();
        expect(inverted[1], 'c');
        expect(inverted[2], 'b');
      });

      test('should handle empty map', () {
        final empty = <String, int>{};
        final inverted = empty.invert();
        expect(inverted, {});
      });
    });

    group('groupByKey', () {
      test('should group values by extracted key', () {
        final data = {'a1': 10, 'a2': 20, 'b1': 30, 'b2': 40};
        final grouped = data.groupByKey((k, v) => k[0]);
        expect(grouped, {
          'a': [10, 20],
          'b': [30, 40],
        });
      });

      test('should group by value ranges', () {
        final scores = {'alice': 95, 'bob': 87, 'charlie': 92, 'david': 78};
        final grouped = scores.groupByKey((k, v) => v >= 90 ? 'A' : 'B');
        expect(grouped, {
          'A': [95, 92],
          'B': [87, 78],
        });
      });

      test('should handle empty map', () {
        final empty = <String, int>{};
        final grouped = empty.groupByKey((k, v) => k);
        expect(grouped, {});
      });
    });

    group('sortByKey', () {
      test('should sort map by keys', () {
        final scores = {'charlie': 92, 'alice': 95, 'bob': 87};
        final sorted = scores.sortByKey();
        expect(sorted.keys.toList(), ['alice', 'bob', 'charlie']);
      });

      test('should sort with custom comparator', () {
        final map = {'b': 1, 'aa': 2, 'ccc': 3};
        final sorted = map.sortByKey((a, b) => a.length.compareTo(b.length));
        expect(sorted.keys.toList(), ['b', 'aa', 'ccc']);
      });

      test('should handle empty map', () {
        final empty = <String, int>{};
        final sorted = empty.sortByKey();
        expect(sorted, {});
      });

      test('should maintain values after sorting', () {
        final scores = {'charlie': 92, 'alice': 95, 'bob': 87};
        final sorted = scores.sortByKey();
        expect(sorted['alice'], 95);
        expect(sorted['bob'], 87);
        expect(sorted['charlie'], 92);
      });
    });

    group('sortByValue', () {
      test('should sort map by values', () {
        final scores = {'alice': 95, 'bob': 87, 'charlie': 92};
        final sorted = scores.sortByValue();
        expect(sorted.values.toList(), [87, 92, 95]);
        expect(sorted.keys.toList(), ['bob', 'charlie', 'alice']);
      });

      test('should sort with custom comparator', () {
        final scores = {'alice': 95, 'bob': 87, 'charlie': 92};
        final sorted = scores.sortByValue((a, b) => b.compareTo(a));
        expect(sorted.values.toList(), [95, 92, 87]);
      });

      test('should throw for non-comparable values without comparator', () {
        final map = {'a': Object(), 'b': Object()};
        expect(() => map.sortByValue(), throwsArgumentError);
      });
    });

    group('pick', () {
      test('should pick specified keys', () {
        final user = {
          'id': 1,
          'name': 'John',
          'email': 'john@example.com',
          'age': 30,
          'password': 'secret',
        };
        final publicInfo = user.pick(['name', 'email']);
        expect(publicInfo, {'name': 'John', 'email': 'john@example.com'});
      });

      test('should ignore non-existent keys', () {
        final map = {'a': 1, 'b': 2, 'c': 3};
        final picked = map.pick(['a', 'd', 'c']);
        expect(picked, {'a': 1, 'c': 3});
      });

      test('should handle empty key list', () {
        final map = {'a': 1, 'b': 2, 'c': 3};
        final picked = map.pick([]);
        expect(picked, {});
      });
    });

    group('omit', () {
      test('should omit specified keys', () {
        final user = {
          'id': 1,
          'name': 'John',
          'password': 'secret',
          'email': 'john@example.com',
        };
        final safe = user.omit(['password']);
        expect(safe, {'id': 1, 'name': 'John', 'email': 'john@example.com'});
      });

      test('should ignore non-existent keys', () {
        final map = {'a': 1, 'b': 2, 'c': 3};
        final omitted = map.omit(['d', 'e']);
        expect(omitted, {'a': 1, 'b': 2, 'c': 3});
      });

      test('should handle empty key list', () {
        final map = {'a': 1, 'b': 2, 'c': 3};
        final omitted = map.omit([]);
        expect(omitted, {'a': 1, 'b': 2, 'c': 3});
      });
    });

    group('setPath', () {
      test('should set value at nested path', () {
        final config = <String, dynamic>{};
        config.setPath(['database', 'host'], 'localhost');
        expect(config, {
          'database': {'host': 'localhost'}
        });
      });

      test('should create multiple nested levels', () {
        final config = <String, dynamic>{};
        config.setPath(['a', 'b', 'c'], 'value');
        expect(config, {
          'a': {
            'b': {'c': 'value'}
          }
        });
      });

      test('should overwrite existing values', () {
        final config = <String, dynamic>{
          'database': {'host': 'oldhost', 'port': 5432}
        };
        config.setPath(['database', 'host'], 'newhost');
        expect(config, {
          'database': {'host': 'newhost', 'port': 5432}
        });
      });

      test('should handle single-level path', () {
        final config = <String, dynamic>{};
        config.setPath(['key'], 'value');
        expect(config, {'key': 'value'});
      });

      test('should handle empty path', () {
        final config = <String, dynamic>{'existing': 'value'};
        config.setPath([], 'newvalue');
        expect(config, {'existing': 'value'});
      });
    });

    group('getPath', () {
      test('should get value from nested path', () {
        final config = {
          'database': {'host': 'localhost', 'port': 5432}
        };
        final host = config.getPath<String>(['database', 'host']);
        expect(host, 'localhost');
      });

      test('should return null for non-existent path', () {
        final config = {
          'database': {'host': 'localhost'}
        };
        final value = config.getPath<String>(['database', 'user']);
        expect(value, null);
      });

      test('should return null for partially valid path', () {
        final config = {
          'database': {'host': 'localhost'}
        };
        final value = config.getPath<String>(['database', 'host', 'invalid']);
        expect(value, null);
      });

      test('should handle single-level path', () {
        final config = {'key': 'value'};
        final value = config.getPath<String>(['key']);
        expect(value, 'value');
      });

      test('should handle empty path', () {
        final config = {'key': 'value'};
        final value = config.getPath<Map>([]);
        expect(value, config);
      });

      test('should work with different types', () {
        final config = {
          'settings': {
            'maxRetries': 3,
            'timeout': 30.5,
            'enabled': true,
          }
        };
        expect(config.getPath<int>(['settings', 'maxRetries']), 3);
        expect(config.getPath<double>(['settings', 'timeout']), 30.5);
        expect(config.getPath<bool>(['settings', 'enabled']), true);
      });
    });
  });

  group('FalconToolNullableMapExtension', () {
    group('isNullOrEmpty', () {
      test('should return true for null', () {
        Map<String, int>? map;
        expect(map.isNullOrEmpty, true);
      });

      test('should return true for empty map', () {
        Map<String, int>? map = {};
        expect(map.isNullOrEmpty, true);
      });

      test('should return false for non-empty map', () {
        Map<String, int>? map = {'a': 1};
        expect(map.isNullOrEmpty, false);
      });
    });

    group('isNotNullOrEmpty', () {
      test('should return false for null', () {
        Map<String, int>? map;
        expect(map.isNotNullOrEmpty, false);
      });

      test('should return false for empty map', () {
        Map<String, int>? map = {};
        expect(map.isNotNullOrEmpty, false);
      });

      test('should return true for non-empty map', () {
        Map<String, int>? map = {'a': 1};
        expect(map.isNotNullOrEmpty, true);
      });
    });

    group('orEmptyMap', () {
      test('should return map when not null', () {
        Map<String, int>? map = {'a': 1, 'b': 2};
        expect(map.orEmpty, {'a': 1, 'b': 2});
      });

      test('should return empty map when null', () {
        Map<String, int>? map;
        expect(map.orEmpty, {});
      });
    });

    group('ifNotEmpty', () {
      test('should execute action for non-empty map', () {
        var executed = false;
        Map<String, int>? receivedMap;
        Map<String, int>? map = {'a': 1, 'b': 2};
        
        map.ifNotEmpty((m) {
          executed = true;
          receivedMap = m;
        });
        
        expect(executed, true);
        expect(receivedMap, {'a': 1, 'b': 2});
      });

      test('should not execute action for null', () {
        var executed = false;
        Map<String, int>? map;
        
        map.ifNotEmpty((m) {
          executed = true;
        });
        
        expect(executed, false);
      });

      test('should not execute action for empty map', () {
        var executed = false;
        Map<String, int>? map = {};
        
        map.ifNotEmpty((m) {
          executed = true;
        });
        
        expect(executed, false);
      });
    });
  });

  group('removeNullsAndEmptyStrings function', () {
    test('should clean complex nested structure', () {
      final data = {
        'user': {
          'name': 'John',
          'email': '',
          'profile': {
            'bio': null,
            'avatar': 'avatar.jpg',
            'tags': ['dart', null, '', 'flutter'],
          },
        },
        'settings': {
          'theme': 'dark',
          'notifications': true,
          'advanced': {
            'debug': false,
            'logs': '',
            'metrics': null,
          },
        },
      };
      
      final cleaned = removeNullsAndEmptyStrings(data);
      
      expect(cleaned, {
        'user': {
          'name': 'John',
          'profile': {
            'avatar': 'avatar.jpg',
            'tags': ['dart', 'flutter'],
          },
        },
        'settings': {
          'theme': 'dark',
          'notifications': true,
          'advanced': {
            'debug': false,
          },
        },
      });
    });

    test('should handle list as top-level structure', () {
      final list = [
        'valid',
        null,
        '',
        {'key': 'value', 'empty': ''},
        [1, null, 2],
      ];
      
      final cleaned = removeNullsAndEmptyStrings(list);
      
      expect(cleaned, [
        'valid',
        {'key': 'value'},
        [1, 2],
      ]);
    });

    test('should preserve non-null, non-empty values', () {
      final data = {
        'string': 'hello',
        'number': 42,
        'boolean': true,
        'list': [1, 2, 3],
        'map': {'a': 1, 'b': 2},
      };
      
      final cleaned = removeNullsAndEmptyStrings(data);
      expect(cleaned, data);
    });
  });
}