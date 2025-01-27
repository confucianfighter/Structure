import 'package:flutter/material.dart';
import 'package:Structure/src/utils/surrealdb/surrealdb_client.dart';
import 'package:flutter/services.dart';

class SurrealDBWidget extends StatefulWidget {
  static const routeName = '/surrealdb';
  @override
  _SurrealDBWidgetState createState() => _SurrealDBWidgetState();
}

class _SurrealDBWidgetState extends State<SurrealDBWidget> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SurrealDB Widget'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RawKeyboardListener(
              focusNode: _focusNode,
              onKey: (event) {
                if (event.isControlPressed &&
                    event.logicalKey == LogicalKeyboardKey.enter) {
                  if (event.isControlPressed) {
                    _submitQuery();
                  }
                }
              },
              child: TextFormField(
                controller: _inputController,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: 'Input',
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (value) async {
                  _submitQuery();
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: TextFormField(
              controller: _outputController,
              maxLines: null,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Output',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitQuery() async {
    final result = await DB().query(query: _inputController.text);
    
    setState(() {
      _outputController.text = result.toString();
    });
  }
}
