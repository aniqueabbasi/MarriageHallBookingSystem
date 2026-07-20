/// Structured CNIC fields, whether OCR-extracted or user-edited. Every
/// field is nullable/empty until the user has confirmed it — nothing here
/// is ever guessed or auto-filled with a default.
class CnicDetails {
  final String cnicNumber;
  final String fullName;
  final String fatherOrHusbandName;
  final DateTime? dateOfBirth;
  final DateTime? dateOfIssue;
  final DateTime? dateOfExpiry;
  final String? gender;

  const CnicDetails({
    this.cnicNumber = '',
    this.fullName = '',
    this.fatherOrHusbandName = '',
    this.dateOfBirth,
    this.dateOfIssue,
    this.dateOfExpiry,
    this.gender,
  });

  static final _validCnicPattern = RegExp(r'^[0-9]{5}-[0-9]{7}-[0-9]$');

  bool get hasValidCnicNumber => _validCnicPattern.hasMatch(cnicNumber);

  /// "12345-1234567-1" -> "*****-*******-1". Falls back to a fully masked
  /// placeholder for anything that isn't the exact expected shape — never
  /// display the real digits outside of the edit form.
  String get maskedCnicNumber {
    if (!hasValidCnicNumber) return '*****-*******-*';
    return '*****-*******-${cnicNumber[cnicNumber.length - 1]}';
  }

  CnicDetails copyWith({
    String? cnicNumber,
    String? fullName,
    String? fatherOrHusbandName,
    DateTime? dateOfBirth,
    DateTime? dateOfIssue,
    DateTime? dateOfExpiry,
    String? gender,
  }) {
    return CnicDetails(
      cnicNumber: cnicNumber ?? this.cnicNumber,
      fullName: fullName ?? this.fullName,
      fatherOrHusbandName: fatherOrHusbandName ?? this.fatherOrHusbandName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      dateOfIssue: dateOfIssue ?? this.dateOfIssue,
      dateOfExpiry: dateOfExpiry ?? this.dateOfExpiry,
      gender: gender ?? this.gender,
    );
  }
}
