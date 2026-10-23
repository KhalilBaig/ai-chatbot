//
// class GeminiResponse {
//   final String message;
//
//   GeminiResponse(this.message);
//
//   static String parseData(Map<String, dynamic> serverData) {
//     final steps = serverData['steps'];
//
//     if (steps is List) {
//       for (final step in steps) {
//         if (step is! Map) continue;
//
//         final content = step['content'];
//
//         if (content is! List) continue;
//
//         for (final part in content) {
//           if (part is Map &&
//               part['type'] == 'text' &&
//               part['text'] is String) {
//             return part['text'] as String;
//           }
//         }
//       }
//     }
//
//     throw const FormatException(
//       'No text response was found in the Gemini response.',
//     );
//   }
// }


class GeminiResponse {
  String message;

  GeminiResponse(this.message);

  static String parseData(Map<String, dynamic> serverData) {
    return serverData["steps"][1]["content"][0]["text"];
  }
}

