import 'package:api/splash.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_products.dart';
import 'auth.dart';
import 'auth_screen.dart';
import 'product_details.dart';
import 'products.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /* 
  await Firebase.initializeApp();
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: "barry.allen@example.com", password: "SuperSecretPassword!");
    print('Done');
  } catch (e) {
    print(e);
  }
  const String url =
      "https://api01-f9571-default-rtdb.firebaseio.com/product.json";
  http.post(url as Uri,
      body: json.encode({
        "id": 1,
        "title": "mytitle",
        "body": "my body",
      })); */ // post sends data on format of  json to url

  /*
    DatabaseReference _ref = FirebaseDatabase.instance.ref().child("Product");
  + encode uses with post fun but decode uses with get fun
  encode converts object of json to string
  decode converts string to object of json
*/

/*  
  + we doesn't use this way ,but use api
 _ref.set({'id':10});
  _ref.push().set({'id':10}); // push store values inside reference or defualt id 
 */

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(
          create: (_) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          // ChangeNotifierProxyProvider configures two providers , second provider depends on first
          create: (context) => Products(),
          update: (ctx, value, previousProducts) => previousProducts!
            ..getData(
              value.token!,
              previousProducts.productsList,
            ), // value is variable by it ,it can reach to contents of Auth
        )
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Auth>(
      // Consumer is used to build any widget,also it consumes provider
      builder: (ctx, value, _) => MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.orange,
            canvasColor: const Color.fromRGBO(255, 238, 219, 1)),
        debugShowCheckedModeBanner: false,
        home: value.isAuth
            ? MyHomePage()
            : FutureBuilder(
                future: value.tryAutoLogin(),
                builder: (ctx, snapShot) =>
                    snapShot.connectionState == ConnectionState.waiting
                        ? const SplashScreen()
                        : AuthScreen(),
              ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = true;

  @override
  void initState() {
    Provider.of<Products>(context, listen: false).fetchData().then((_) =>
        _isLoading =
            false); // when completing of getting of data ,ProgressIndicator disappears
    super.initState();
  }

  Widget detailCard(id, tile, desc, price, imageUrl) {
    return Builder(
      builder: (innerContext) => TextButton(
        onPressed: () {
          print(id);
          Navigator.push(
            innerContext,
            MaterialPageRoute(builder: (_) => ProductDetails(id)),
          ).then(
              (id) => Provider.of<Products>(context, listen: false).delete(id));
        },
        child: Column(
          children: [
            const SizedBox(height: 5),
            Card(
              elevation: 10,
              color: const Color.fromRGBO(115, 138, 119, 1),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.only(right: 10),
                      width: 130,
                      child: Hero(
                        tag: id,
                        child: Image.network(imageUrl, fit: BoxFit.fill),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        Text(
                          tile,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const Divider(color: Colors.white),
                        SizedBox(
                          width: 200,
                          child: Text(
                            desc,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            softWrap: true,
                            overflow: TextOverflow.fade,
                            textAlign: TextAlign.justify,
                            maxLines: 3,
                          ),
                        ),
                        const Divider(color: Colors.white),
                        Text(
                          "\$$price",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 18),
                        ),
                        const SizedBox(height: 13),
                      ],
                    ),
                  ),
                  const Expanded(flex: 1, child: Icon(Icons.arrow_forward_ios)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Product> prodList =
        Provider.of<Products>(context, listen: true).productsList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          TextButton(
              onPressed: () =>
                  Provider.of<Auth>(context, listen: false).logout(),
              child: const Text('LogOUt'))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (prodList.isEmpty
              ? const Center(
                  child: Text('No Products Added.',
                      style: TextStyle(fontSize: 22)))
              : RefreshIndicator(
                  onRefresh: () async =>
                      await Provider.of<Products>(context, listen: false)
                          .fetchData(),
                  child: ListView(
                    children: prodList
                        .map(
                          (item) => detailCard(item.id, item.title,
                              item.description, item.price, item.imageUrl),
                        )
                        .toList(),
                  ),
                )),
      floatingActionButton: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Theme.of(context).primaryColor,
        ),
        child: TextButton.icon(
          label: const Text("Add Product",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddProduct())),
        ),
      ),
    );
  }
}
