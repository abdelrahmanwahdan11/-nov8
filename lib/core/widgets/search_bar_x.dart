import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../localization/app_localizations.dart';

class SearchBarX extends StatefulWidget {
  const SearchBarX({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onFilters,
    required this.suggestionsBuilder,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onFilters;
  final List<String> Function(String text) suggestionsBuilder;

  @override
  State<SearchBarX> createState() => _SearchBarXState();
}

class _SearchBarXState extends State<SearchBarX> {
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _suggestions = widget.suggestionsBuilder(widget.controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: l10n.t('search_hint'),
                  prefixIcon: const Icon(IconlyLight.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged('');
                    },
                  ),
                ),
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: widget.onFilters,
              icon: const Icon(IconlyLight.filter),
              label: Text(l10n.t('filters')),
            ),
          ],
        ),
        if (_focusNode.hasFocus && widget.controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Card(
              elevation: 4,
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    title: Text(suggestion),
                    onTap: () {
                      widget.controller.text = suggestion;
                      widget.onSubmitted(suggestion);
                      _focusNode.unfocus();
                    },
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemCount: _suggestions.length,
              ),
            ),
          ),
      ],
    );
  }
}
