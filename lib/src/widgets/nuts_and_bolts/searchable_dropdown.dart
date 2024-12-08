import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchableDropdown extends StatefulWidget {
  final List<String> items;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String labelText;
  final String hintText;

  const SearchableDropdown({
    Key? key,
    required this.items,
    this.initialValue,
    this.onChanged,
    this.labelText = 'Select an item',
    this.hintText = 'Type to search...',
  }) : super(key: key);

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _targetKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  List<String> _filteredItems = [];
  bool _isOpen = false;
  int _highlightedIndex = -1;
  final ScrollController _scrollController = ScrollController();

  static const double _itemHeight = 40.0;
  String _focusText = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _focusNode = FocusNode();

    _focusNode.onKeyEvent = _handleKeyEvent;

    _filteredItems = widget.items;
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _focusText = _controller.text;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _openOverlay(showAll: true);
          _selectAllTextIfUnchanged();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _overlayEntry?.remove();
    _scrollController.dispose();
    super.dispose();
  }

  void _selectAllTextIfUnchanged() {
    if (_controller.text == _focusText && _focusNode.hasFocus) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    }
  }

  void _filter(String input) {
    if (_overlayEntry == null) return;
    setState(() {
      _filteredItems = widget.items
          .where(
              (item) => item.toLowerCase().contains(input.toLowerCase().trim()))
          .toList();
      _highlightedIndex = _filteredItems.isEmpty ? -1 : 0;
    });
    _updateOverlay();
  }

  void _showAll() {
    if (_overlayEntry == null) return;
    setState(() {
      _filteredItems = widget.items;
      _highlightedIndex = _filteredItems.isEmpty ? -1 : 0;
    });
    _updateOverlay();
  }

  void _openOverlay({bool showAll = false}) {
    if (_overlayEntry != null) {
      _closeOverlay();
    }
    if (_targetKey.currentContext == null) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);

    if (showAll) {
      _showAll();
    } else {
      _filter(_controller.text);
    }
    _isOpen = true;
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
    _scrollToHighlighted();
  }

  void _scrollToHighlighted() {
    if (_highlightedIndex >= 0 && _highlightedIndex < _filteredItems.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _highlightedIndex * _itemHeight,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _selectItem(String item) {
    _closeOverlay();
    _controller.text = item;
    widget.onChanged?.call(item);
    _focusNode.unfocus();
  }

  OverlayEntry _createOverlayEntry() {
    if (_targetKey.currentContext == null) {
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }
    final renderBox =
        _targetKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final theme = Theme.of(context);
    final highlightColor = theme.colorScheme.primary.withOpacity(0.1);
    final defaultTextColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    final highlightTextColor = Colors.white;

    return OverlayEntry(
      builder: (context) {
        if (!_isOpen || _filteredItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: Offset(0, size.height),
            child: Material(
              elevation: 4.0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final isHighlighted = index == _highlightedIndex;
                    return InkWell(
                      onTap: () => _selectItem(_filteredItems[index]),
                      child: Container(
                        height: _itemHeight,
                        color: isHighlighted ? highlightColor : null,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          _filteredItems[index],
                          style: TextStyle(
                            color: isHighlighted
                                ? highlightTextColor
                                : defaultTextColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!_isOpen || _filteredItems.isEmpty) return KeyEventResult.ignored;
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _highlightedIndex = (_highlightedIndex + 1) % _filteredItems.length;
        });
        _updateOverlay();
        _selectAllTextIfUnchanged();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _highlightedIndex = (_highlightedIndex - 1 + _filteredItems.length) %
              _filteredItems.length;
        });
        _updateOverlay();
        _selectAllTextIfUnchanged();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_highlightedIndex >= 0 &&
            _highlightedIndex < _filteredItems.length) {
          _selectItem(_filteredItems[_highlightedIndex]);
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _closeOverlay();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      key: _targetKey,
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enableInteractiveSelection: true,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_drop_down),
            onPressed: () {
              if (_isOpen) {
                _closeOverlay();
              } else {
                // Ensure the TextField has focus and open the overlay
                _focusNode.requestFocus();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _openOverlay(showAll: true);
                });
              }
            },
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            _filter(value);
          } else {
            _showAll();
          }
        },
      ),
    );
  }
}
