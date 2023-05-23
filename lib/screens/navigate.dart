import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluxstore/colors/colors.dart';
import 'package:fluxstore/models/cart_helper.dart';
import 'package:fluxstore/models/login_check.dart';
import 'package:fluxstore/screens/categories.dart';
import 'package:fluxstore/screens/displayCategory.dart';
import 'package:fluxstore/screens/home_screen.dart';
import 'package:fluxstore/screens/login_screen.dart';
import 'package:fluxstore/screens/profile_screen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/myAppBar.dart';
import 'contact.dart';
import 'orders.dart';

class Navigate extends StatefulWidget {
  int index;
  Navigate({
    Key? key,
    required this.index,
  });

  @override
  State<Navigate> createState() => _NavigateState();
}

class _NavigateState extends State<Navigate> {
  List<dynamic> categories = [];
  late int _currentIndex;
  final storage = FlutterSecureStorage();
  String fname = '';
  String lname = '';
  String email = '';
  String number = '03458537650';
  List<Widget> _pages = <Widget>[
    HomeScreen(),
    Categories(),
    Orders(),
    ProfileScreen()
  ];
  @override
  void initState() {
    _currentIndex = widget.index;
    fetchCategories();
    getData();
    super.initState();
  }

  void getData() async {
    fname = (await storage.read(key: 'fname'))!;
    lname = (await storage.read(key: 'lname'))!;
    email = (await storage.read(key: 'email'))!;

    setState(() {});
  }

  void fetchCategories() async {
    String? baseUrl = dotenv.env['BASE_URL'];
    String? consumerKey = dotenv.env['CONSUMER_KEY'];
    String? customerSecret = dotenv.env['CUSTOMER_SECRET'];
    print("Fetching Categories");
    int pageNum = 1;
    bool hasMorePages = true;
    final url = '${baseUrl}products/categories';
    final credentials = "$consumerKey:$customerSecret";
    final utf = utf8.encode(credentials);
    final base64Str = base64.encode(utf);
    final headers = {"Authorization": "Basic $base64Str"};
    while (hasMorePages) {
      final response =
          await http.get(Uri.parse('$url?page=$pageNum'), headers: headers);
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            final data = json.decode(response.body);
            categories.addAll(data);
            hasMorePages =
                (response.headers['link']?.contains('rel="next"') ?? false);
            pageNum++;
          });
        } else {
          print("Didn't work");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartProvider>(context);
    final log = Provider.of<LoginCheck>(context);
    return Scaffold(
      appBar: myAppBar(context),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: GlobalColors().primaryColor,
              ),
              currentAccountPicture: const CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://media.istockphoto.com/id/1208175274/vector/avatar-vector-icon-simple-element-illustrationavatar-vector-icon-material-concept-vector.jpg?s=612x612&w=0&k=20&c=t4aK_TKnYaGQcPAC5Zyh46qqAtuoPcb-mjtQax3_9Xc=')),
              accountName: log.isLoggedIn == true
                  ? Text(
                      '$fname $lname',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  : const Text("Default User"),
              accountEmail: log.isLoggedIn == true
                  ? Text(email)
                  : const Text("Not Logged In"),
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                color: GlobalColors().primaryDarkColor,
              ),
              title: const Text('Home'),
              onTap: () {
                _currentIndex = 0;
                setState(() {});
                Navigator.pop(context);
              },
            ),
            /* ListTile(
              leading: Icon(
                Icons.person,
                color: GlobalColors().primaryDarkColor,
              ),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()));
              },
            ),*/
            ExpansionTile(
                iconColor: GlobalColors().primaryDarkColor,
                title: const Text(
                  "Categories",
                ),
                leading: Icon(
                  Icons.category,
                  color: GlobalColors().primaryDarkColor,
                ),
                children: [
                  SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return InkWell(
                            onTap: () {
                              final id = category['id'].toString();
                              final name = category['name'];
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DisplayByCategory(
                                          categoryId: id, categoryName: name)));
                            },
                            child: ListTile(
                              title: Text(category['name']),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ]),
            ListTile(
              leading: Icon(
                Icons.phone,
                color: GlobalColors().primaryDarkColor,
              ),
              title: const Text('Contact us'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: ((context) => Contact())));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.info,
                color: GlobalColors().primaryDarkColor,
              ),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: GlobalColors().primaryDarkColor,
              ),
              title: log.isLoggedIn == true
                  ? const Text('Logout')
                  : const Text("Login"),
              onTap: () {
                log.changeLog();
                cartModel.clearCart();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (() async {
            final Uri url = Uri(scheme: 'tel', path: number);
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              print('unable to launch the url');
            }
          }),
          backgroundColor: GlobalColors().primaryDarkColor,
          child: const Icon(Icons.phone)),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: GlobalColors().primaryDarkColor,
        ),
        child: BottomNavigationBar(
            selectedItemColor: Colors.white,
            backgroundColor: Colors.red,
            currentIndex: _currentIndex,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  color: GlobalColors().drawerColor,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.category,
                  color: GlobalColors().drawerColor,
                ),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.history,
                  color: GlobalColors().drawerColor,
                ),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  color: GlobalColors().drawerColor,
                ),
                label: 'Profile',
              ),
            ]),
      ),
    );
  }
}
