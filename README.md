
## Features
Drop-in replacement of Provider with lots of features.

## Getting started


## Usage

Define store before using it. Store can be anything

```dart
class MyClass extends ConsumerNotifier {
    int value = 0;

    increment() {
        value++;
        notifyListeners();
    }
}

String myStoreOne = 'my store';
List<int> myStoreTwo = [1, 2, 3, 4, 5];
MyClass myStoreThree = MyClass(); 
```

Then use Provider to map stores.

```dart
// single store
Provider(
    id: 'sad',
    store: myStoreTwo,
    child: Column(
        children: [
            Consumer(
                id: 'sad',
                notifierBuilder: (BuildContext context, List<int> taste, rebuild) {
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
    )
)

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
                notifierBuilder: (BuildContext context, storeMap, Function rebuild) {
                    List<int> taste = storeMap['tasteTwo'];

                    return GestureDetector(
                        onTap: () {
                            myStoreTwo.add(0);
                            notifyConsumers('sad.default');
                            rebuild();
                        },
                        child: Text(taste.join(', ')),
                    );
                },
            ),
        ],
    ),
)
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
