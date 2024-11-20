import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class MyDropdown extends StatefulWidget {
  final List items;
  final Function(dynamic) onChanged;
  final TextEditingController controller;
  final String placeholder;
  final bool showSearch;
  final Function(String)? onSearch;
  final dynamic selectedItem;

  const MyDropdown({
    required this.items,
    required this.onChanged,
    required this.controller,
    required this.placeholder,
    this.selectedItem,
    this.showSearch = false,
    this.onSearch,
    super.key,
  });

  @override
  State<MyDropdown> createState() => _MyDropdownState();
}

class _MyDropdownState extends State<MyDropdown> {
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownSearch(
          items: (filter, infiniteScrollProps) => widget.items,
          itemAsString: (item) => item['name'],
          selectedItem: widget.selectedItem,
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: widget.placeholder,
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ),
          onChanged: (value) => {widget.onChanged(value)},
          compareFn: (item1, item2) => item1 < item2,
          popupProps: PopupProps.menu(
            fit: FlexFit.loose,
            showSearchBox: widget.showSearch,
            searchFieldProps: TextFieldProps(
              controller: widget.showSearch == true ? widget.controller : null,
              decoration: InputDecoration(
                hintText: 'Type to Search',
                suffixIcon: widget.controller.text.isEmpty
                    ? null
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.controller.clear();
                            widget.controller.text = '';
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 11, 0),
                          child: const Icon(Icons.clear),
                        )),
              ),
              onChanged: (query) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  widget.onSearch!(query);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
