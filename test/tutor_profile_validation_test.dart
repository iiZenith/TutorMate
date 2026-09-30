import 'package:flutter_test/flutter_test.dart';
import 'package:tutormate/features/tutor_profile/domain/tutor_profile_validation.dart';

void main() {
  group('TutorProfileValidation experience', () {
    test('rejects blank experience', () {
      expect(TutorProfileValidation.validateExperience(''), isNotNull);
      expect(TutorProfileValidation.parseExperience(''), isNull);
    });

    test('rejects non-numeric experience', () {
      expect(TutorProfileValidation.validateExperience('abc'), isNotNull);
      expect(TutorProfileValidation.parseExperience('abc'), isNull);
    });

    test('rejects negative experience', () {
      expect(TutorProfileValidation.validateExperience('-1'), isNotNull);
      expect(TutorProfileValidation.parseExperience('-1'), isNull);
    });

    test('accepts zero and valid experience', () {
      expect(TutorProfileValidation.parseExperience('0'), 0);
      expect(TutorProfileValidation.parseExperience('5'), 5);
      expect(TutorProfileValidation.parseExperience('80'), 80);
    });

    test('rejects experience above the supported boundary', () {
      expect(TutorProfileValidation.validateExperience('81'), isNotNull);
      expect(TutorProfileValidation.parseExperience('81'), isNull);
    });
  });

  group('TutorProfileValidation pricing', () {
    test('rejects blank, malformed, zero, and negative rates', () {
      expect(TutorProfileValidation.parseRate('', label: 'Monthly fee'), isNull);
      expect(TutorProfileValidation.parseRate('abc', label: 'Monthly fee'), isNull);
      expect(TutorProfileValidation.parseRate('0', label: 'Monthly fee'), isNull);
      expect(TutorProfileValidation.parseRate('-10', label: 'Monthly fee'), isNull);
    });

    test('accepts valid pricing boundaries', () {
      expect(TutorProfileValidation.parseRate('1', label: 'Monthly fee'), 1);
      expect(TutorProfileValidation.parseRate('10000', label: 'Monthly fee'), 10000);
      expect(
        TutorProfileValidation.parseRate('1000000', label: 'Monthly fee'),
        1000000,
      );
    });

    test('rejects pricing above the supported boundary', () {
      expect(
        TutorProfileValidation.validateRate('1000001', label: 'Monthly fee'),
        isNotNull,
      );
      expect(
        TutorProfileValidation.parseRate('1000001', label: 'Monthly fee'),
        isNull,
      );
    });
  });

  group('TutorProfileValidation professional fields', () {
    test('requires a headline and bio', () {
      expect(TutorProfileValidation.validateHeadline(''), isNotNull);
      expect(TutorProfileValidation.validateBio(''), isNotNull);
      expect(TutorProfileValidation.validateHeadline('Physics Tutor'), isNull);
      expect(TutorProfileValidation.validateBio('Experienced tutor.'), isNull);
    });

    test('requires at least one teaching level', () {
      expect(TutorProfileValidation.validateTeachingLevels([]), isNotNull);
      expect(TutorProfileValidation.validateTeachingLevels(['Secondary (SEE)']), isNull);
    });
  });
}
