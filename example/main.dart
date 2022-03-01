import 'package:flutter/material.dart';
import 'package:rx_provider/rx_provider.dart';

void main() async {
  runApp(MyApp());
}

class MyClass extends ProviderState {
  int value = 0;

  increment() {
    value++;
    notifyListeners();
  }
}

String myStoreOne = 'my store';
List<int> myStoreTwo = [1, 2, 3, 4, 5];
MyClass myStoreThree = MyClass();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      home: Column(
        children: [
          // single store
          Provider(
            id: 'sad',
            store: myStoreTwo,
            child: Column(
              children: [
                Consumer(
                  id: 'sad',
                  notifierBuilder:
                      (BuildContext context, List<int> taste, rebuild) {
                    return GestureDetector(
                      onTap: () {
                        myStoreTwo.add(0);
                        rebuild();
                      },
                      child: Text(taste.join(', ')),
                    );
                  },
                ),
              ],
            ),
          ),

          // multiple stores
          Provider(
            stores: {
              'tasteOne': myStoreOne,
              'tasteTwo': myStoreTwo,
            },
            child: Column(
              children: [
                Consumer(
                  store: 'tasteOne',
                  builder: (BuildContext context, String taste) {
                    return Text(taste);
                  },
                ),
                Consumer(
                  stores: ['tasteTwo'],
                  notifierBuilder:
                      (BuildContext context, storeMap, Function rebuild) {
                    List<int> taste = storeMap['tasteTwo'];

                    return GestureDetector(
                      onTap: () {
                        myStoreTwo.add(0);
                        ProviderState.notifyConsumers('sad.default');
                        rebuild();
                      },
                      child: Text(taste.join(', ')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
