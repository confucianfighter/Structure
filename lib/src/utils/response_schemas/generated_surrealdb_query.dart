import 'dart:convert';
import 'schemas.dart';

class GeneratedSurrealDBQueryResponse
    extends StructuredResponse<GeneratedSurrealDBQuery> {
  @override
  final responseFormat = {
    "type": "json_schema",
    "json_schema": {
      "name": "GeneratedSurrealDBQueryResponse",
      "strict": true,
      "schema": {
        "type": "object",
        "properties": {
          "query": {"type": "string"},
          "parameters": {
            "type": "object",
            "additionalProperties": {"type": "string"}
          }
        },
        "required": ["query"],
        "additionalProperties": false
      }
    }
  };

  @override
  Future<GeneratedSurrealDBQuery?> decode(
      String response, Future<void> Function(String)? onError) async {
    late Map<String, dynamic> jsonResponse;
    try {
      try {
        jsonResponse = jsonDecode(response);
      } catch (e) {
        await onError?.call(
            'Error decoding SurrealDB query with jsonDecode function: $e, response: $response');
      }
      return GeneratedSurrealDBQuery(
          query: jsonResponse['query'],
          parameters: jsonResponse['parameters'] ?? {});
    } catch (e) {
      await onError
          ?.call('Error decoding SurrealDB query: $e, response: $response');
    }
    return null;
  }
}

class GeneratedSurrealDBQuery {
  final String query;
  final Map<String, String> parameters;

  GeneratedSurrealDBQuery({required this.query, required this.parameters});
}
