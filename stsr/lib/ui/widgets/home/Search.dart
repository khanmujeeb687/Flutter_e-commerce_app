import 'package:stsr/resources/themes/light_color.dart';
import 'package:stsr/ui/pages/search_page.dart';
import 'package:flutter/material.dart';

import 'cart.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: LightColor.black,
      body: SearchPage(),
    );
  }
  Widget _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor:LightColor.black,
    );
  }
}
