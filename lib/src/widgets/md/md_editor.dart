import 'package:flutter/material.dart';
import 'md_viewer.dart';

class MdEditor extends StatelessWidget {
  final String initialValue;
  final Function(String) onChanged;
  final String labelText;

  const MdEditor({
    Key? key,
    required this.initialValue,
    required this.onChanged,
    required this.labelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Input Field
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: TextFormField(
                  initialValue: initialValue,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: labelText,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: onChanged,
                ),
              ),
            ),
            // Markdown Preview
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: MdViewer(content: initialValue),
              ),
            ),
          ],
        );
      },
    );
  }
}
