import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/groceryitem.dart';
import 'package:shopping_list/widget/newitem.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Grocerylist extends StatefulWidget {
  const Grocerylist({super.key});

  @override
  State<Grocerylist> createState() => _GrocerylistState();
}

class _GrocerylistState extends State<Grocerylist> {
  List<GroceryItem> _groceryitem = [];
  var _isloading = true;
  @override
  void initState() {
    super.initState();
    _loaditem();
  }

  void _loaditem() async {
    final url = Uri.https(
        'course-a405f-default-rtdb.firebaseio.com', 'shopping_list.json');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic>? listdata = json.decode(response.body);
        // print('Response from Firebase: $listdata');

        if (listdata == null) {
          //print('No items found in the database.');
          setState(() {
            _groceryitem = [];
          });
          return;
        }

        final List<GroceryItem> loadeditems = [];

        listdata.forEach((key, value) {
          // Check that all expected fields are non-null and have the right type
          if (value != null &&
              value['name'] is String &&
              value['quantity'] is int &&
              value['category'] is String) {
            final category = categories.entries
                .firstWhere(
                    (catitem) => catitem.value.title == value['category'])
                .value;

            loadeditems.add(GroceryItem(
                id: key,
                name: value['name'],
                quantity: value['quantity'],
                category: category));
          }
        });

        setState(() {
          _groceryitem = loadeditems;
          _isloading = false;
        });

        // print('Loaded items: $_groceryitem');
      } else {
        throw Exception(
            'Failed to load items. Status code: ${response.statusCode}');
      }
    } catch (error) {
      //print('Error loading items: $error');
    }
  }

  void _additem() async {
    final newitem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const Newitem()));
    if (newitem == null) {
      return;
    }
    setState(() {
      _groceryitem.add(newitem);
    });
  }

  void _removeitem(GroceryItem item) async {
    final url = Uri.https('course-a405f-default-rtdb.firebaseio.com',
        'shopping_list/${item.id}.json');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      setState(() {
        _groceryitem.remove(item);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} removed!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added'));

    if (_isloading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryitem.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryitem.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeitem(_groceryitem[index]);
          },
          key: ValueKey(_groceryitem[index].id),
          child: ListTile(
            title: Text(_groceryitem[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryitem[index].category.color,
            ),
            trailing: Text(_groceryitem[index].quantity.toString()),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('YOUR LIST'),
        actions: [IconButton(onPressed: _additem, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
