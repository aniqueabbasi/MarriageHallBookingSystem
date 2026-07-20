/// Best-effort parsing of raw OCR text from a Pakistani CNIC into
/// [CnicDetails]. Everything here is deliberately conservative: a field
/// that isn't confidently detected is left null/empty rather than guessed,
/// since the verification screen always lets the user fill in or correct
/// every value before it's submitted.
///
/// Scope note: this only targets the Latin/English text side of the card
/// (name, father/husband name, CNIC number, dates, gender as printed in
/// English). It does not attempt Urdu extraction.
library;

import 'package:marriage_hall_app/models/cnic/cnic_details.dart';

final _finalCnicPattern = RegExp(r'^[0-9]{5}-[0-9]{7}-[0-9]$');

/// Characters that are visually near-identical to a digit on a printed
/// CNIC. Applied ONLY inside [normalizeCnicNumber], i.e. only once a
/// substring has already been identified as a CNIC-number-shaped token —
/// this deliberately never touches free text such as names.
const Map<String, String> _digitLookalikes = {
  'O': '0',
  'o': '0',
  'I': '1',
  'i': '1',
  'l': '1',
  'S': '5',
  's': '5',
  'B': '8',
};

String _applyDigitLookalikes(String token) {
  final buffer = StringBuffer();
  for (final rune in token.runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(_digitLookalikes[ch] ?? ch);
  }
  return buffer.toString();
}

/// Normalizes a raw CNIC-shaped token — with or without hyphens, and
/// tolerant of stray whitespace/line breaks OCR tends to insert — into
/// "XXXXX-XXXXXXX-X". Returns null if the cleaned-up token isn't exactly
/// 13 digits, e.g. wrong length or containing non-digit-like characters.
String? normalizeCnicNumber(String raw) {
  var cleaned = raw.replaceAll(RegExp(r'\s+'), '');
  cleaned = _applyDigitLookalikes(cleaned);
  cleaned = cleaned.replaceAll(RegExp(r'[^0-9-]'), '');

  final digitsOnly = cleaned.replaceAll('-', '');
  if (!RegExp(r'^[0-9]{13}$').hasMatch(digitsOnly)) return null;

  final normalized =
      '${digitsOnly.substring(0, 5)}-${digitsOnly.substring(5, 12)}-${digitsOnly.substring(12)}';
  return _finalCnicPattern.hasMatch(normalized) ? normalized : null;
}

/// True final-format validation, post-normalization: `^[0-9]{5}-[0-9]{7}-[0-9]$`.
bool isValidCnicFormat(String value) => _finalCnicPattern.hasMatch(value);

/// A CNIC-shaped run of characters: 5, then 7, then 1 digit-or-lookalike
/// characters, each group optionally separated by whitespace/hyphens (to
/// tolerate OCR inserting a stray space or line break instead of, or in
/// addition to, the printed hyphen).
final _cnicCandidatePattern = RegExp(
  r'[0-9OoIiSsBl]{5}[\s-]{0,2}[0-9OoIiSsBl]{7}[\s-]{0,2}[0-9OoIiSsBl]{1}',
);

/// Scans raw OCR text for every substring that could plausibly be a CNIC
/// number and returns each one normalized to "XXXXX-XXXXXXX-X", in the
/// order they appear in the text. Cards that print the number more than
/// once (or contain another 13-digit number) will surface multiple
/// entries here — callers take the first as the initial guess and rely on
/// the user to correct it if it picked the wrong one, rather than this
/// function silently choosing.
List<String> findCnicCandidates(String rawText) {
  final candidates = <String>[];

  for (final match in _cnicCandidatePattern.allMatches(rawText)) {
    final normalized = normalizeCnicNumber(match.group(0)!);
    if (normalized != null && !candidates.contains(normalized)) {
      candidates.add(normalized);
    }
  }

  return candidates;
}

/// Parses a single `DD.MM.YYYY` / `DD-MM-YYYY` / `DD/MM/YYYY` token and
/// validates it's a real calendar date. Returns null for anything
/// malformed or out of a sane range — never guesses a corrected date.
DateTime? parseCnicDate(String raw) {
  final match = RegExp(
    r'(\d{1,2})\s*[.\-/]\s*(\d{1,2})\s*[.\-/]\s*(\d{4})',
  ).firstMatch(raw);
  if (match == null) return null;

  final day = int.tryParse(match.group(1)!);
  final month = int.tryParse(match.group(2)!);
  final year = int.tryParse(match.group(3)!);
  if (day == null || month == null || year == null) return null;
  if (month < 1 || month > 12) return null;
  if (year < 1900 || year > 2100) return null;

  final daysInMonth = DateTime(year, month + 1, 0).day;
  if (day < 1 || day > daysInMonth) return null;

  return DateTime(year, month, day);
}

/// Every valid date-like token in [rawText], in the order found. Tokens
/// that fail validation (bad day/month, implausible year) are skipped
/// rather than aborting the whole extraction.
List<DateTime> findAllDates(String rawText) {
  final matches = RegExp(
    r'\d{1,2}\s*[.\-/]\s*\d{1,2}\s*[.\-/]\s*\d{4}',
  ).allMatches(rawText);

  final dates = <DateTime>[];
  for (final match in matches) {
    final parsed = parseCnicDate(match.group(0)!);
    if (parsed != null) dates.add(parsed);
  }
  return dates;
}

final _nameLabelPattern = RegExp(r'^name$', caseSensitive: false);
final _fatherLabelPattern = RegExp(
  r"^(father|husband)('?s)?\s*name$",
  caseSensitive: false,
);
final _boilerplatePattern = RegExp(
  r'pakistan|identity|card|national|islamic|republic|government|gender|male|female',
  caseSensitive: false,
);

bool _looksLikePlausibleName(String candidate) {
  if (candidate.length < 2 || candidate.length > 60) return false;
  if (!RegExp(r"^[A-Za-z .'-]+$").hasMatch(candidate)) return false;
  if (_boilerplatePattern.hasMatch(candidate)) return false;
  if (_nameLabelPattern.hasMatch(candidate)) return false;
  if (_fatherLabelPattern.hasMatch(candidate)) return false;
  return true;
}

/// Finds a line matching [labelPattern] and returns the next non-empty
/// line if — and only if — it looks like a plausible name (letters and
/// simple punctuation only, not boilerplate card text, not another
/// label). Returns null rather than guessing when nothing plausible
/// follows the label.
String? _extractLineAfterLabel(
  String rawText,
  RegExp labelPattern, {
  RegExp? excludeLabelPattern,
}) {
  final lines = rawText.split(RegExp(r'\r?\n'));

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (excludeLabelPattern != null && excludeLabelPattern.hasMatch(line)) {
      continue;
    }
    if (!labelPattern.hasMatch(line)) continue;

    for (var j = i + 1; j < lines.length; j++) {
      final candidate = lines[j].trim();
      if (candidate.isEmpty) continue;
      return _looksLikePlausibleName(candidate) ? candidate : null;
    }
  }
  return null;
}

String? _extractGender(String rawText) {
  final match = RegExp(
    r'\b(Male|Female)\b',
    caseSensitive: false,
  ).firstMatch(rawText);
  if (match == null) return null;
  final value = match.group(0)!.toLowerCase();
  return value[0].toUpperCase() + value.substring(1);
}

/// Runs every extractor above over [rawText] and assembles the result.
/// Fields that can't be confidently detected come back null/empty for the
/// user to fill in on the verification screen.
CnicDetails extractCnicDetails(String rawText) {
  final cnicCandidates = findCnicCandidates(rawText);
  final dates = findAllDates(rawText);

  // Pakistani CNICs print Date of Birth, then Date of Issue, then Date of
  // Expiry, top to bottom — this assumes OCR read order roughly follows
  // print order, which holds for most single-column scans but isn't
  // guaranteed on every layout/lighting condition. Wrong assignments are
  // correctable on the verification screen like any other field.
  return CnicDetails(
    cnicNumber: cnicCandidates.isNotEmpty ? cnicCandidates.first : '',
    fullName:
        _extractLineAfterLabel(
          rawText,
          _nameLabelPattern,
          excludeLabelPattern: _fatherLabelPattern,
        ) ??
        '',
    fatherOrHusbandName:
        _extractLineAfterLabel(rawText, _fatherLabelPattern) ?? '',
    dateOfBirth: dates.isNotEmpty ? dates[0] : null,
    dateOfIssue: dates.length > 1 ? dates[1] : null,
    dateOfExpiry: dates.length > 2 ? dates[2] : null,
    gender: _extractGender(rawText),
  );
}
