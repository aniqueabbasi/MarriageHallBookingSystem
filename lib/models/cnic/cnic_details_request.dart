import 'package:intl/intl.dart';

import 'package:marriage_hall_app/models/cnic/cnic_details.dart';

final _isoDate = DateFormat('yyyy-MM-dd');

/// Body for `PUT /api/users/me/cnic` — only the confirmed structured
/// fields ever go over the wire; the CNIC image itself is never sent or
/// stored.
class CnicDetailsRequest {
  final String cnicNumber;
  final String fullName;
  final String fatherOrHusbandName;
  final DateTime dateOfBirth;
  final DateTime dateOfIssue;
  final DateTime dateOfExpiry;
  final String? gender;

  const CnicDetailsRequest({
    required this.cnicNumber,
    required this.fullName,
    required this.fatherOrHusbandName,
    required this.dateOfBirth,
    required this.dateOfIssue,
    required this.dateOfExpiry,
    this.gender,
  });

  /// Only valid once every required field on [details] is present —
  /// callers should gate this behind form validation first.
  factory CnicDetailsRequest.fromDetails(CnicDetails details) {
    return CnicDetailsRequest(
      cnicNumber: details.cnicNumber,
      fullName: details.fullName,
      fatherOrHusbandName: details.fatherOrHusbandName,
      dateOfBirth: details.dateOfBirth!,
      dateOfIssue: details.dateOfIssue!,
      dateOfExpiry: details.dateOfExpiry!,
      gender: details.gender,
    );
  }

  Map<String, dynamic> toJson() => {
    'cnicNumber': cnicNumber,
    'fullName': fullName,
    'fatherOrHusbandName': fatherOrHusbandName,
    'dateOfBirth': _isoDate.format(dateOfBirth),
    'dateOfIssue': _isoDate.format(dateOfIssue),
    'dateOfExpiry': _isoDate.format(dateOfExpiry),
    if (gender != null && gender!.isNotEmpty) 'gender': gender,
  };
}

/// Response from `PUT /api/users/me/cnic` — [cnicNumber] always comes
/// back masked (e.g. "*****-*******-1"); the full number is never echoed
/// once saved.
class CnicDetailsResponse {
  final String maskedCnicNumber;
  final String fullName;

  const CnicDetailsResponse({
    required this.maskedCnicNumber,
    required this.fullName,
  });

  factory CnicDetailsResponse.fromJson(Map<String, dynamic> json) =>
      CnicDetailsResponse(
        maskedCnicNumber: json['cnicNumber'] as String? ?? '*****-*******-*',
        fullName: json['fullName'] as String? ?? '',
      );
}
