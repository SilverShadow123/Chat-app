import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final ValueChanged<String> onSearchTextChanged;

  const SearchWidget({
    Key? key,
    required this.onSearchTextChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: onSearchTextChanged,
        decoration: InputDecoration(
          hintText: 'Search users...',
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
