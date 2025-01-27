import 'assistant_actions.dart';
import 'package:Structure/src/widgets/chat/chat_bubbles/query_bubble.dart';
import 'package:Structure/src/data_store.dart';
class GeneratedSurrealDBQueryResponse
    extends AssistantAction<GeneratedSurrealDBQuery> {
  GeneratedSurrealDBQueryResponse({super.shortcutKey, super.buttonText, super.addChatWidgetCallback, super.onResultGenerated});
  GeneratedSurrealDBQuery? generatedQuery;
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
          "explanation": {"type": "string"}
        },
        "required": ["query", "explanation"],
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
      generatedQuery = GeneratedSurrealDBQuery(
          query: jsonResponse['query'],
          explanation: jsonResponse['explanation']);
      if (addChatWidgetCallback != null) {
        //addChatWidgetCallback?.call(generatedQuery!);
      }
    } catch (e) {
    } catch (e) {
      await onError
          ?.call('Error decoding SurrealDB query: $e, response: $response');
    }
    // seems there should be a simpler way. If main chat handled message type and content, there would be less stuff to pass around.
    // If type were stored in the role, then it would know what kind of parsing to do on a message.
    // however, do I want to make major changes?
    onResultGenerated?.call(generatedQuery!);
    return generatedQuery;
  }

  @override
  String systemPrompt() {
    return '''You are a helpful assistant that can generate SurrealDB queries. The user will be particularly interested in help following data driven design principles so that the entire app along with ui state is represented in database tables, functions, relationships, etc. Use ns and use db will already pre prepended to your query, so don't worry about including them.''';
  }

  @override
  Future<void> processResponseObject(GeneratedSurrealDBQuery response) async {}
}

class GeneratedSurrealDBQuery {
  final String query;
  final String explanation;
  GeneratedSurrealDBQuery({required this.query, required this.explanation});
}
