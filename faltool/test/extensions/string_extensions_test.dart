import 'package:faltool/lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FalconToolStringExtension', () {
    group('Whitespace and Formatting', () {
      test('removeWhiteSpace removes all whitespace', () {
        expect('hello world'.removeWhiteSpace, 'helloworld');
        expect('  tab\tspace\n '.removeWhiteSpace, 'tabspace');
        expect('no space'.removeWhiteSpace, 'nospace');
        expect('   '.removeWhiteSpace, '');
      });

      test('normalizeWhitespace trims and collapses whitespace', () {
        expect('  hello   world  '.normalizeWhitespace, 'hello world');
        expect('  multiple   spaces   between  '.normalizeWhitespace, 'multiple spaces between');
        expect('\t\ttabs\t\tand\t\tspaces\t\t'.normalizeWhitespace, 'tabs and spaces');
        expect('already normal'.normalizeWhitespace, 'already normal');
      });
    });

    group('Validation Methods', () {
      test('isUrl validates URLs correctly', () {
        // Valid URLs
        expect('https://example.com'.isUrl, true);
        expect('http://example.com'.isUrl, true);
        expect('https://sub.example.com'.isUrl, true);
        expect('https://example.com/path'.isUrl, true);
        expect('https://example.com/path?query=value'.isUrl, true);
        expect('https://example.com:8080'.isUrl, true);
        
        // Invalid URLs
        expect('not a url'.isUrl, false);
        expect('example.com'.isUrl, false);
        expect('ftp://example.com'.isUrl, false);
        expect('https://'.isUrl, false);
        expect(''.isUrl, false);
      });

      test('isNotUrl is opposite of isUrl', () {
        expect('https://example.com'.isNotUrl, false);
        expect('not a url'.isNotUrl, true);
      });

      test('isEmail validates email addresses correctly', () {
        // Valid emails
        expect('user@example.com'.isEmail, true);
        expect('user.name@example.com'.isEmail, true);
        expect('user+tag@example.co.uk'.isEmail, true);
        expect('user123@sub.example.com'.isEmail, true);
        
        // Invalid emails
        expect('invalid.email'.isEmail, false);
        expect('@example.com'.isEmail, false);
        expect('user@'.isEmail, false);
        expect('user@example'.isEmail, false);
        expect('user example@com'.isEmail, false);
        expect(''.isEmail, false);
      });

      test('isNotEmail is opposite of isEmail', () {
        expect('user@example.com'.isNotEmail, false);
        expect('invalid email'.isNotEmail, true);
      });

      test('isNumeric validates numeric strings', () {
        // Valid numeric strings
        expect('123'.isNumeric, true);
        expect('-123'.isNumeric, true);
        expect('123.45'.isNumeric, true);
        expect('-123.45'.isNumeric, true);
        expect('0'.isNumeric, true);
        expect('0.0'.isNumeric, true);
        
        // Invalid numeric strings
        expect('abc'.isNumeric, false);
        expect('123abc'.isNumeric, false);
        expect('1.2.3'.isNumeric, false);
        expect(''.isNumeric, false);
        expect(' 123 '.isNumeric, false);
      });

      test('isJson validates JSON strings', () {
        // Valid JSON
        expect('{"key": "value"}'.isJson, true);
        expect('[]'.isJson, true);
        expect('[1, 2, 3]'.isJson, true);
        expect('"string"'.isJson, true);
        expect('123'.isJson, true);
        expect('true'.isJson, true);
        expect('null'.isJson, true);
        
        // Invalid JSON
        expect('not json'.isJson, false);
        expect('{key: value}'.isJson, false);
        expect("{'key': 'value'}".isJson, false);
        expect(''.isJson, false);
      });

      test('isNotJson is opposite of isJson', () {
        expect('{"key": "value"}'.isNotJson, false);
        expect('not json'.isNotJson, true);
      });
    });

    group('Conversion Methods', () {
      test('toIntOrZero converts strings to integers', () {
        expect('123'.toIntOrZero(), 123);
        expect(' 123 '.toIntOrZero(), 123);
        expect('-456'.toIntOrZero(), -456);
        expect('abc'.toIntOrZero(), 0);
        expect(''.toIntOrZero(), 0);
        expect('12.34'.toIntOrZero(), 0); // Decimal not valid for int
      });

      test('toDoubleOrZero converts strings to doubles', () {
        expect('123.45'.toDoubleOrZero(), 123.45);
        expect('123'.toDoubleOrZero(), 123.0);
        expect('-456.78'.toDoubleOrZero(), -456.78);
        expect('abc'.toDoubleOrZero(), 0.0);
        expect(''.toDoubleOrZero(), 0.0);
      });

      test('toBoolean converts strings to booleans', () {
        expect('true'.toBoolean(), true);
        expect('TRUE'.toBoolean(), true);
        expect('1'.toBoolean(), true);
        expect('false'.toBoolean(), false);
        expect('FALSE'.toBoolean(), false);
        expect('0'.toBoolean(), false);
        
        expect(() => 'maybe'.toBoolean(), throwsUnsupportedError);
        expect(() => ''.toBoolean(), throwsUnsupportedError);
      });

      test('toBooleanOrNull converts strings to booleans with null safety', () {
        expect('true'.toBooleanOrNull(), true);
        expect('TRUE'.toBooleanOrNull(), true);
        expect('1'.toBooleanOrNull(), true);
        expect('false'.toBooleanOrNull(), false);
        expect('FALSE'.toBooleanOrNull(), false);
        expect('0'.toBooleanOrNull(), false);
        expect('maybe'.toBooleanOrNull(), null);
        expect(''.toBooleanOrNull(), null);
      });

      test('toMap parses JSON to Map', () {
        final map = '{"key": "value", "number": 123}'.toMap();
        expect(map['key'], 'value');
        expect(map['number'], 123);
        
        expect(() => 'not json'.toMap(), throwsFormatException);
        expect(() => '[]'.toMap(), throwsFormatException); // Array, not object
      });

      test('toMapOrNull safely parses JSON to Map', () {
        final map = '{"key": "value"}'.toMapOrNull();
        expect(map?['key'], 'value');
        
        expect('not json'.toMapOrNull(), null);
        expect('[]'.toMapOrNull(), null);
        expect(''.toMapOrNull(), null);
      });

      test('toMapOrEmpty returns empty map on failure', () {
        final map = '{"key": "value"}'.toMapOrEmpty();
        expect(map['key'], 'value');
        
        expect('not json'.toMapOrEmpty(), {});
        expect('[]'.toMapOrEmpty(), {});
        expect(''.toMapOrEmpty(), {});
      });

      test('toBase64 encodes string to base64', () {
        expect('Hello'.toBase64(), 'SGVsbG8=');
        expect('Hello World!'.toBase64(), 'SGVsbG8gV29ybGQh');
        expect(''.toBase64(), '');
      });

      test('fromBase64 decodes base64 to string', () {
        expect('SGVsbG8='.fromBase64(), 'Hello');
        expect('SGVsbG8gV29ybGQh'.fromBase64(), 'Hello World!');
        expect(''.fromBase64(), '');
      });

      test('toBytes converts string to UTF-8 bytes', () {
        final bytes = 'Hello'.toBytes();
        expect(bytes, isA<Uint8List>());
        expect(bytes.length, 5);
        expect(bytes[0], 72); // 'H'
        expect(bytes[1], 101); // 'e'
      });
    });

    group('Case Conversions', () {
      test('toCamelCase converts to camelCase', () {
        expect('hello_world'.toCamelCase(), 'helloWorld');
        expect('HELLO-WORLD'.toCamelCase(), 'helloWorld');
        expect('hello world'.toCamelCase(), 'helloWorld');
        expect('Hello_World'.toCamelCase(), 'helloWorld');
        expect('helloWorld'.toCamelCase(), 'helloWorld');
        expect(''.toCamelCase(), '');
      });

      test('toSnakeCase converts to snake_case', () {
        expect('helloWorld'.toSnakeCase(), 'hello_world');
        expect('HelloWorld'.toSnakeCase(), 'hello_world');
        expect('hello-world'.toSnakeCase(), 'hello_world');
        expect('hello world'.toSnakeCase(), 'hello_world');
        expect('hello_world'.toSnakeCase(), 'hello_world');
        expect(''.toSnakeCase(), '');
      });

      test('toPascalCase converts to PascalCase', () {
        expect('hello_world'.toPascalCase(), 'HelloWorld');
        expect('hello-world'.toPascalCase(), 'HelloWorld');
        expect('hello world'.toPascalCase(), 'HelloWorld');
        expect('helloWorld'.toPascalCase(), 'HelloWorld');
        expect(''.toPascalCase(), '');
      });

      test('toKebabCase converts to kebab-case', () {
        expect('helloWorld'.toKebabCase(), 'hello-world');
        expect('HelloWorld'.toKebabCase(), 'hello-world');
        expect('hello_world'.toKebabCase(), 'hello-world');
        expect('hello world'.toKebabCase(), 'hello-world');
        expect(''.toKebabCase(), '');
      });
    });

    group('String Manipulation', () {
      test('capitalizeWords capitalizes first letter of each word', () {
        expect('hello world'.capitalizeWords(), 'Hello World');
        expect('HELLO WORLD'.capitalizeWords(), 'HELLO WORLD');
        expect('hello   world'.capitalizeWords(), 'Hello   World');
        expect(''.capitalizeWords(), '');
        expect('a'.capitalizeWords(), 'A');
      });

      test('reverse reverses the string', () {
        // Using dartx's reversed property
        expect('hello'.reversed, 'olleh');
        expect('Hello World'.reversed, 'dlroW olleH');
        expect('12345'.reversed, '54321');
        expect(''.reversed, '');
        expect('a'.reversed, 'a');
      });

      test('truncate truncates string to specified length', () {
        expect('Hello World'.truncate(8), 'Hello...');
        expect('Hello World'.truncate(8, ellipsis: '~'), 'Hello W~');
        expect('Hello'.truncate(10), 'Hello'); // No truncation needed
        expect('Hello World'.truncate(3), '...'); // Length <= ellipsis length
        expect('Hello World'.truncate(null), 'Hello World'); // Null length
      });

      test('removeHttp removes protocol from URL', () {
        expect('https://example.com'.removeHttp, 'example.com');
        expect('http://example.com'.removeHttp, 'example.com');
        expect('example.com'.removeHttp, 'example.com');
        expect('https://https://example.com'.removeHttp, 'https://example.com'); // Only first
      });

      test('containsIgnoreCase performs case-insensitive contains', () {
        expect('Hello World'.containsIgnoreCase('WORLD'), true);
        expect('Hello World'.containsIgnoreCase('world'), true);
        expect('Hello World'.containsIgnoreCase('HELLO'), true);
        expect('Hello World'.containsIgnoreCase('xyz'), false);
      });

      test('countOccurrences counts pattern occurrences', () {
        expect('hello hello world'.countOccurrences('hello'), 2);
        expect('aaaa'.countOccurrences('aa'), 2);
        expect('abcdef'.countOccurrences('xyz'), 0);
        expect('hello world'.countOccurrences(''), 0);
      });

      test('escapeHtml escapes HTML characters', () {
        expect('<div>Hello</div>'.escapeHtml(), '&lt;div&gt;Hello&lt;/div&gt;');
        expect('Hello & "World"'.escapeHtml(), 'Hello &amp; &quot;World&quot;');
        expect("It's <great>".escapeHtml(), "It&#39;s &lt;great&gt;");
        expect('No special chars'.escapeHtml(), 'No special chars');
      });

      test('unescapeHtml unescapes HTML characters', () {
        expect('&lt;div&gt;'.unescapeHtml(), '<div>');
        expect('Hello &amp; &quot;World&quot;'.unescapeHtml(), 'Hello & "World"');
        expect('It&#39;s &lt;great&gt;'.unescapeHtml(), "It's <great>");
        expect('No special chars'.unescapeHtml(), 'No special chars');
      });
    });
  });

  group('FalconStringNullExtension', () {
    test('orEmpty returns empty string for null', () {
      String? nullString;
      String? emptyString = '';
      String? nonEmptyString = 'hello';
      
      expect(nullString.orEmpty(), '');
      expect(emptyString.orEmpty(), '');
      expect(nonEmptyString.orEmpty(), 'hello');
    });

    test('or returns default value for null', () {
      String? nullString;
      String? nonEmptyString = 'hello';
      
      expect(nullString.or('default'), 'default');
      expect(nonEmptyString.or('default'), 'hello');
    });

    test('toIntOrNull safely converts to int', () {
      String? nullString;
      String? validInt = '123';
      String? invalidInt = 'abc';
      
      expect(nullString.toIntOrNull(), null);
      expect(validInt.toIntOrNull(), 123);
      expect(invalidInt.toIntOrNull(), null);
    });

    test('toIntOrZero safely converts to int with zero default', () {
      String? nullString;
      String? validInt = '123';
      String? invalidInt = 'abc';
      
      expect(nullString.toIntOrZero(), 0);
      expect(validInt.toIntOrZero(), 123);
      expect(invalidInt.toIntOrZero(), 0);
    });

    test('toDoubleOrNull safely converts to double', () {
      String? nullString;
      String? validDouble = '123.45';
      String? invalidDouble = 'abc';
      
      expect(nullString.toDoubleOrNull(), null);
      expect(validDouble.toDoubleOrNull(), 123.45);
      expect(invalidDouble.toDoubleOrNull(), null);
    });

    test('toDoubleOrZero safely converts to double with zero default', () {
      String? nullString;
      String? validDouble = '123.45';
      String? invalidDouble = 'abc';
      
      expect(nullString.toDoubleOrZero(), 0.0);
      expect(validDouble.toDoubleOrZero(), 123.45);
      expect(invalidDouble.toDoubleOrZero(), 0.0);
    });

    test('isUrl safely checks URL validity', () {
      String? nullString;
      String? validUrl = 'https://example.com';
      String? invalidUrl = 'not a url';
      
      expect(nullString.isUrl, false);
      expect(validUrl.isUrl, true);
      expect(invalidUrl.isUrl, false);
    });

    test('isEmail safely checks email validity', () {
      String? nullString;
      String? validEmail = 'user@example.com';
      String? invalidEmail = 'not an email';
      
      expect(nullString.isEmail, false);
      expect(validEmail.isEmail, true);
      expect(invalidEmail.isEmail, false);
    });

    test('isJson safely checks JSON validity', () {
      String? nullString;
      String? validJson = '{"key": "value"}';
      String? invalidJson = 'not json';
      
      expect(nullString.isJson, false);
      expect(validJson.isJson, true);
      expect(invalidJson.isJson, false);
    });

    test('toBooleanOrNull safely converts to boolean', () {
      String? nullString;
      String? trueString = 'true';
      String? invalidBool = 'maybe';
      
      expect(nullString.toBooleanOrNull(), null);
      expect(trueString.toBooleanOrNull(), true);
      expect(invalidBool.toBooleanOrNull(), null);
    });

    test('toMapOrNull safely converts to Map', () {
      String? nullString;
      String? validJson = '{"key": "value"}';
      String? invalidJson = 'not json';
      
      expect(nullString.toMapOrNull(), null);
      expect(validJson.toMapOrNull()?['key'], 'value');
      expect(invalidJson.toMapOrNull(), null);
    });

    test('toMapOrEmpty safely converts to Map with empty default', () {
      String? nullString;
      String? validJson = '{"key": "value"}';
      String? invalidJson = 'not json';
      
      expect(nullString.toMapOrEmpty(), {});
      expect(validJson.toMapOrEmpty()['key'], 'value');
      expect(invalidJson.toMapOrEmpty(), {});
    });

    test('removeWhiteSpace safely removes whitespace', () {
      String? nullString;
      String? withSpaces = 'hello world';
      
      expect(nullString.removeWhiteSpace, null);
      expect(withSpaces.removeWhiteSpace, 'helloworld');
    });

    test('normalizeWhitespace safely normalizes whitespace', () {
      String? nullString;
      String? withSpaces = '  hello   world  ';
      
      expect(nullString.normalizeWhitespace, null);
      expect(withSpaces.normalizeWhitespace, 'hello world');
    });

    test('capitalize safely capitalizes string', () {
      String? nullString;
      String? emptyString = '';
      String? lowerString = 'hello';
      String? upperString = 'HELLO';
      
      expect(nullString.capitalize, null);
      expect(emptyString.capitalize, '');
      expect(lowerString.capitalize, 'Hello');
      expect(upperString.capitalize, 'HELLO');
    });

    test('truncate safely truncates string', () {
      String? nullString;
      String? longString = 'Hello World';
      
      expect(nullString.truncate(5), null);
      expect(longString.truncate(5), 'He...');
    });
  });
}