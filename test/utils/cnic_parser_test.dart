import 'package:flutter_test/flutter_test.dart';
import 'package:marriage_hall_app/utils/cnic_parser.dart';

void main() {
  group('normalizeCnicNumber', () {
    test('accepts a CNIC already in the correct hyphenated format', () {
      expect(normalizeCnicNumber('12345-1234567-1'), '12345-1234567-1');
    });

    test('normalizes a plain 13-digit number with no hyphens', () {
      expect(normalizeCnicNumber('1234512345671'), '12345-1234567-1');
    });

    test('normalizes a CNIC containing spaces instead of/around hyphens', () {
      expect(normalizeCnicNumber('12345 1234567 1'), '12345-1234567-1');
      expect(normalizeCnicNumber('12345 - 1234567 - 1'), '12345-1234567-1');
    });

    test('normalizes a CNIC split across a line break', () {
      expect(normalizeCnicNumber('12345-1234567-\n1'), '12345-1234567-1');
    });

    test('rejects a value with the wrong digit count', () {
      expect(normalizeCnicNumber('1234-1234567-1'), isNull); // 12 digits
      expect(normalizeCnicNumber('12345-1234567-12'), isNull); // 14 digits
      expect(normalizeCnicNumber('123456789'), isNull); // 9 digits
    });

    test('rejects non-numeric noise', () {
      expect(normalizeCnicNumber('not a cnic at all'), isNull);
      expect(normalizeCnicNumber(''), isNull);
    });

    test(
      'corrects common digit lookalikes within a CNIC-shaped token',
      () {
        // O -> 0, I -> 1, S -> 5, B -> 8
        expect(normalizeCnicNumber('1234O-123456I-8'), '12340-1234561-8');
      },
    );
  });

  group('isValidCnicFormat', () {
    test('matches the exact required regex', () {
      expect(isValidCnicFormat('12345-1234567-1'), isTrue);
      expect(isValidCnicFormat('12345-1234567-12'), isFalse);
      expect(isValidCnicFormat('1234-1234567-1'), isFalse);
      expect(isValidCnicFormat('12345123456 71'), isFalse);
    });
  });

  group('findCnicCandidates', () {
    test('finds a single CNIC embedded in surrounding text', () {
      const text = 'National Identity Card\n12345-1234567-1\nName\nAli Khan';
      expect(findCnicCandidates(text), ['12345-1234567-1']);
    });

    test('finds multiple distinct 13-digit numbers without merging them', () {
      const text = '12345-1234567-1 some other text 98765-9876543-2';
      final candidates = findCnicCandidates(text);
      expect(candidates, containsAll(['12345-1234567-1', '98765-9876543-2']));
      expect(candidates.length, 2);
    });

    test('does not duplicate the same number printed twice', () {
      const text = '12345-1234567-1 ... 12345-1234567-1';
      expect(findCnicCandidates(text), ['12345-1234567-1']);
    });

    test('returns an empty list when nothing CNIC-shaped is present', () {
      expect(findCnicCandidates('just some random text'), isEmpty);
    });
  });

  group('parseCnicDate', () {
    test('parses DD.MM.YYYY', () {
      expect(parseCnicDate('05.04.2000'), DateTime(2000, 4, 5));
    });

    test('parses DD-MM-YYYY', () {
      expect(parseCnicDate('05-04-2000'), DateTime(2000, 4, 5));
    });

    test('parses DD/MM/YYYY', () {
      expect(parseCnicDate('05/04/2000'), DateTime(2000, 4, 5));
    });

    test('rejects an impossible calendar date', () {
      expect(parseCnicDate('30.02.2000'), isNull); // Feb 30 doesn't exist
      expect(parseCnicDate('32.01.2000'), isNull); // no day 32
      expect(parseCnicDate('01.13.2000'), isNull); // no month 13
    });

    test('rejects an implausible year', () {
      expect(parseCnicDate('01.01.1800'), isNull);
    });

    test('returns null for text with no date-like token', () {
      expect(parseCnicDate('not a date'), isNull);
    });
  });

  group('findAllDates', () {
    test('finds all three CNIC dates in print order', () {
      const text = '''
        Date of Birth
        05.04.2000
        Date of Issue
        01.01.2020
        Date of Expiry
        01.01.2030
      ''';
      expect(findAllDates(text), [
        DateTime(2000, 4, 5),
        DateTime(2020, 1, 1),
        DateTime(2030, 1, 1),
      ]);
    });

    test('skips malformed dates but keeps the valid ones', () {
      const text = '05.04.2000 and then 30.02.1999 and then 01.01.2030';
      expect(findAllDates(text), [DateTime(2000, 4, 5), DateTime(2030, 1, 1)]);
    });
  });

  group('extractCnicDetails', () {
    test('extracts a complete, well-formed CNIC text block', () {
      const text = '''
        Islamic Republic of Pakistan
        National Identity Card
        Name
        Ali Raza
        Father Name
        Muhammad Raza
        Gender
        Male
        12345-1234567-1
        Date of Birth
        05.04.2000
        Date of Issue
        01.01.2020
        Date of Expiry
        01.01.2030
      ''';

      final result = extractCnicDetails(text);

      expect(result.cnicNumber, '12345-1234567-1');
      expect(result.fullName, 'Ali Raza');
      expect(result.fatherOrHusbandName, 'Muhammad Raza');
      expect(result.gender, 'Male');
      expect(result.dateOfBirth, DateTime(2000, 4, 5));
      expect(result.dateOfIssue, DateTime(2020, 1, 1));
      expect(result.dateOfExpiry, DateTime(2030, 1, 1));
    });

    test('leaves fields null/empty rather than guessing when missing', () {
      const text = 'Some unrelated scanned text with no recognizable fields.';

      final result = extractCnicDetails(text);

      expect(result.cnicNumber, isEmpty);
      expect(result.fullName, isEmpty);
      expect(result.fatherOrHusbandName, isEmpty);
      expect(result.gender, isNull);
      expect(result.dateOfBirth, isNull);
      expect(result.dateOfIssue, isNull);
      expect(result.dateOfExpiry, isNull);
    });

    test('picks the first candidate when multiple 13-digit numbers exist', () {
      const text = '12345-1234567-1\nsome other number 98765-9876543-2';
      final result = extractCnicDetails(text);
      expect(result.cnicNumber, '12345-1234567-1');
    });

    test('extracts partially when only some fields are present', () {
      const text = '''
        Name
        Ali Raza
        05.04.2000
      ''';
      final result = extractCnicDetails(text);
      expect(result.fullName, 'Ali Raza');
      expect(result.cnicNumber, isEmpty);
      expect(result.dateOfBirth, DateTime(2000, 4, 5));
      expect(result.dateOfIssue, isNull);
    });
  });
}
