library rx;

import 'package:flutter/material.dart';

Map<String, List> _rxIds = {};

rx(id, [ref, bool unlink = false]) {
  if (_rxIds[id] == null) {
    _rxIds[id] = [];
  }

  if (unlink == true) {
    // print('removed: ' + id);
    _rxIds[id]!.remove(ref);
  } else if (ref != null) {
    // print('added: ' + id);
    _rxIds[id]!.add(ref);
  } else {
    // print('fetched: ' + id);
  }

  return _rxIds[id];
}

Map<String, List<List>> _events = {};

// Event('rating.submitted').subscribe((payload) {
//   print(payload);
// }, this);

// Event('rating.submitted').unsubscribe(this);
// Event('rating.submitted').broadcast({});

int _eventSubscriptionId = 0;

// Create a new event
class Event {
  String eventName;

  Event(this.eventName);

  // Subscribe to an event
  subscribe(callback, [id]) {
    if (_events[eventName] == null) {
      _events[eventName] = [];
    }

    _events[eventName]!.add([id ?? ++_eventSubscriptionId, callback]);

    return id ?? _eventSubscriptionId;
  }

  // Unsubscribe from an event
  void unsubscribe([id]) {
    if (_events[eventName] == null) {
      _events[eventName] = [];
    }

    _events[eventName]!.removeWhere((item) => item[0] == id);
  }

  // Trigger an event and call all registered callback with given payload
  void broadcast(payload, [id]) {
    if (_events[eventName] == null) {
      _events[eventName] = [];
    }

    for (int i = 0; i < _events[eventName]!.length; i++) {
      var item = _events[eventName]![i];

      if (id == null || item[0] == id) {
        item[1](payload);
      }
    }
  }
}

Map<String, dynamic> _stores = {};
Map<String, List<_RxWidgetState>> _storeConsumers = {};

class _RxWidget extends StatefulWidget {
  String? id;
  List<String> requestedStores;
  Function? builder, childBuilder, childNotifierBuilder, notifierBuilder;
  ConsumerBuilderType? builderType;
  Widget? child;
  bool isSingle;

  _RxWidget({
    this.id,
    required this.requestedStores,
    this.builder,
    this.builderType,
    this.childBuilder,
    this.childNotifierBuilder,
    this.notifierBuilder,
    this.child,
    required this.isSingle,
  });

  @override
  _RxWidgetState createState() => _RxWidgetState();
}

class _RxWidgetState extends State<_RxWidget> {
  Map<String, dynamic> refs = {};

  @override
  void initState() {
    String id = (widget.id ?? '') + (widget.id != null ? '.' : '');

    initListener(name) {
      if (_storeConsumers[name] == null) {
        _storeConsumers[name] = List<_RxWidgetState>.empty(growable: true);
      }

      // print('_RxWidgetState.initListener');
      // print(name);
      // print(_storeConsumers[name]);
      _storeConsumers[name]!.add(this);
      // print(_storeConsumers[name]);
    }

    if (widget.isSingle) {
      refs['default'] = _stores[id + widget.requestedStores[0]];

      initListener(id + widget.requestedStores[0]);
    } else {
      for (var name in widget.requestedStores) {
        refs[id + name] = _stores[id + name];

        initListener(id + name);
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print('rx build');
    // print(refs);

    if (widget.childBuilder != null) {
      return widget.childBuilder!(
        context,
        widget.isSingle ? refs['default'] : refs,
        widget.child,
      );
    } else if (widget.childNotifierBuilder != null) {
      return widget.childNotifierBuilder!(
        context,
        widget.isSingle ? refs['default'] : refs,
        widget.child,
        () => setState(() {}),
      );
    } else if (widget.notifierBuilder != null) {
      return widget.notifierBuilder!(
        context,
        widget.isSingle ? refs['default'] : refs,
        () => setState(() {}),
      );
    }

    if (defaultConsumerBuilderType == ConsumerBuilderType.childBuilder) {
      return widget.builder!(
        context,
        widget.isSingle ? refs['default'] : refs,
        widget.child,
      );
    } else if (defaultConsumerBuilderType ==
        ConsumerBuilderType.childNotifierBuilder) {
      return widget.builder!(
        context,
        widget.isSingle ? refs['default'] : refs,
        widget.child,
        () => setState(() {}),
      );
    } else if (defaultConsumerBuilderType ==
        ConsumerBuilderType.notifierBuilder) {
      return widget.builder!(
        context,
        widget.isSingle ? refs['default'] : refs,
        () => setState(() {}),
      );
    } else {
      return widget.builder!(
        context,
        widget.isSingle ? refs['default'] : refs,
      );
    }
  }

  @override
  void dispose() {
    endListener(name) {
      // print('_RxWidgetState.endListener');
      // print(name);
      // print(_storeConsumers[name]);
      _storeConsumers[name]!.remove(this);
      // print(_storeConsumers[name]);
    }

    String id = (widget.id ?? '') + (widget.id != null ? '.' : '');

    if (widget.isSingle) {
      refs['default'] = _stores[id + widget.requestedStores[0]];

      endListener(id + widget.requestedStores[0]);
    } else {
      for (var name in widget.requestedStores) {
        refs[id + name] = _stores[id + name];

        endListener(id + name);
      }
    }

    super.dispose();
  }
}

// Build a consumer of given store(s) and return builded widget
// will rebuild on store updates
Widget Consumer({
  String? id,
  String? store,
  List<String>? stores,
  Function? builder,
  Function? childBuilder,
  Function? childNotifierBuilder,
  Function? notifierBuilder,
  Widget? child,
}) {
  // builder requirement
  if (builder == null &&
      childBuilder == null &&
      childNotifierBuilder == null &&
      notifierBuilder == null) {
    throw Exception('Atleast one builder is required.');
  }

  // child requirement
  if (child == null && (childBuilder != null || childNotifierBuilder != null)) {
    throw Exception('No child widget has been provided.');
  }

  bool isSingle = stores == null ? true : false;
  // print('Consumer: ');
  // print(isSingle);

  return _RxWidget(
    id: id,
    requestedStores: isSingle ? [store ?? 'default'] : stores,
    builder: builder,
    childBuilder: childBuilder,
    childNotifierBuilder: childNotifierBuilder,
    notifierBuilder: notifierBuilder,
    child: child,
    isSingle: isSingle,
  );
}

Widget Provider({
  String? id,
  dynamic store,
  Map<String, dynamic>? stores,
  required Widget child,
}) {
  // store requirement
  if (store == null && stores == null) {
    throw Exception('Both store and stores can not be null.');
  }

  String ns = (id ?? '') + (id != null ? '.' : '');

  Map<String, dynamic> _providedStores =
      store == null ? stores! : {'default': store};

  _providedStores.forEach((name, storeObject) {
    _stores[ns + name] = storeObject;

    try {
      storeObject!.stateId = ns + name;
    } catch (NoSuchMethodError) {}
  });

  // print('Provider: ');
  // print(_stores);

  return child;
}

abstract class ProviderState {
  late List<String> _stateIds = [];

  set stateId(String name) {
    _stateIds.add(name);
  }

  notifyListeners([Future? resolver]) {
    notifyAll() {
      for (int i = 0; i < _stateIds.length; i++) {
        notifyConsumers(_stateIds[i]);
      }
    }

    if (resolver != null) {
      return resolver.then((value) {
        notifyAll();
        return value;
      });
    } else {
      notifyAll();
    }
  }

  static notifyConsumers(String name) {
    for (_RxWidgetState state in _storeConsumers[name]!) {
      if (state.mounted) {
        state.setState(() {});
      }
    }
  }
}

enum ConsumerBuilderType {
  builder,
  childBuilder,
  childNotifierBuilder,
  notifierBuilder
}

ConsumerBuilderType defaultConsumerBuilderType = ConsumerBuilderType.builder;
