import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('This is the $title screen.')),
    );
  }
}

class CustomDrawer extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userImageUrl;

  const CustomDrawer({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.userImageUrl,
  }) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  void _onTapDown() {
    _controller.forward();
    setState(() {
      _scale = 0.95;
    });
  }

  void _onTapUp() {
    _controller.reverse();
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _showImageDialog(context);
            },
            onTapDown: (_) => _onTapDown(),
            onTapUp: (_) => _onTapUp(),
            child: Transform.scale(
              scale: _scale,
              child: Hero(
                tag: 'userImage',
                child: UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 239, 239, 239),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: NetworkImage(widget.userImageUrl),
                  ),
                  accountName: Text(
                    widget.userName,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(
                    widget.userEmail,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          ..._buildListTiles(context),
        ],
      ),
    );
  }

  List<Widget> _buildListTiles(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        "icon": Icons.payment_rounded,
        "text": "Plans & Payment",
        "onTap": () =>
            Get.to(() => const PlaceholderScreen(title: "Plans & Payment")),
      },
      {
        "icon": Icons.person_rounded,
        "text": "Update Your Details",
        "onTap": () =>
            Get.to(() => const PlaceholderScreen(title: "Update Your Details")),
      },
      {
        "icon": Icons.storefront_rounded,
        "text": "Update Shop Details",
        "onTap": () =>
            Get.to(() => const PlaceholderScreen(title: "Update Shop Details")),
      },
      {
        "icon": Icons.inventory_2_rounded,
        "text": "Update Stock",
        "onTap": () =>
            Get.to(() => const PlaceholderScreen(title: "Update Stock")),
      },
      {
        "icon": Icons.logout_rounded,
        "text": "Logout",
        "onTap": () async {
          var sharedPref = await SharedPreferences.getInstance();
          sharedPref.clear();
          Fluttertoast.showToast(msg: "Logged Out Successfully");
          Future.delayed(const Duration(seconds: 2), () {
            Get.offAll(() => const PlaceholderScreen(title: "Login Screen"));
          });
        },
      },
    ];

    return items.map((item) {
      return GestureDetector(
        onTapDown: (_) => _onTapDown(),
        onTapUp: (_) => _onTapUp(),
        child: Transform.scale(
          scale: _scale,
          child: ListTile(
            leading: Icon(item['icon']),
            title: Text(item['text']),
            onTap: item['onTap'],
          ),
        ),
      );
    }).toList();
  }

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Image.network(widget.userImageUrl),
        );
      },
    );
  }
}
