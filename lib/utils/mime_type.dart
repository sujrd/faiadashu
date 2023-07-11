import 'dart:core';

/// Converts a MIME type to a corresponding Uniform Type Identifier (UTI).
///
/// The [mimeType] parameter represents the MIME type to be converted.
/// Returns the UTI corresponding to the provided MIME type, or an empty string if no UTI is found.
///
/// Example usage:
/// ```dart
/// final mimeType = 'image/jpeg';
/// final uti = convertMIMETypeToUTI(mimeType);
/// print('The UTI for $mimeType is $uti');
/// ```
String? convertMIMETypeToUTI(String mimeType) {
  switch (mimeType) {
    // wildcard MIME types
    case 'image/*':
      return 'public.image';
    //  explicit MIME types
    case 'image/jpeg':
      return 'public.jpeg';
    case 'image/png':
      return 'public.png';
    case 'application/pdf':
      return 'com.adobe.pdf';
    case 'text/plain':
      return 'public.plain-text';
    case 'audio/mpeg':
      return 'public.mp3';
    case 'video/mp4':
      return 'public.mpeg-4';
    case 'application/zip':
      return 'public.zip-archive';
    case 'application/json':
      return 'public.json';
    case 'application/xml':
      return 'public.xml';
    case 'application/msword':
      return 'com.microsoft.word.doc';
    case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
      return 'org.openxmlformats.wordprocessingml.document';
    case 'application/vnd.ms-excel':
      return 'com.microsoft.excel.xls';
    case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
      return 'org.openxmlformats.spreadsheetml.sheet';
    case 'application/vnd.ms-powerpoint':
      return 'com.microsoft.powerpoint.ppt';
    case 'application/vnd.openxmlformats-officedocument.presentationml.presentation':
      return 'org.openxmlformats.presentationml.presentation';
    // Add more cases for other MIME types as needed
    default:
      return null;
  }
}

/// Converts a list of MIME types to their corresponding Uniform Type Identifiers (UTIs).
///
/// The [mimeTypes] parameter represents the list of MIME types to be converted.
/// Returns a list of UTIs corresponding to the provided MIME types.
///
/// Example usage:
/// ```dart
/// final mimeTypes = ['image/jpeg', 'video/mp4', 'audio/mpeg'];
/// final utis = convertMIMETypesToUTIs(mimeTypes);
/// print('UTIs: $utis');
/// ```
List<String> convertMIMETypesToUTIs(List<String?> mimeTypes) {
  final utis = <String>[];

  for (final mimeType in mimeTypes) {
    if (mimeType != null) {
      final uti = convertMIMETypeToUTI(mimeType);
      if (uti != null) {
        utis.add(uti);
      }
    }
  }

  return utis;
}
