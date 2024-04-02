import 'dart:async';

import 'package:flutter/material.dart';

class StreamListenableBuilder<T> extends StatefulWidget {
  final Stream<T> stream;
  final void Function(BuildContext, AsyncSnapshot<T>)? listener;
  final Widget Function(BuildContext, AsyncSnapshot<T>) builder;

  const StreamListenableBuilder({
    super.key,
    required this.stream,
    this.listener,
    required this.builder,
  });

  @override
  State<StreamListenableBuilder<T>> createState() =>
      _StreamListenableBuilderState<T>();
}

class _StreamListenableBuilderState<T>
    extends State<StreamListenableBuilder<T>> {
  StreamSubscription? _subscription;
  @override
  void initState() {
    super.initState();
    _subscription = widget.stream.listen((event) {
      widget.listener
          ?.call(context, AsyncSnapshot.withData(ConnectionState.done, event));
    }, onError: (error) {
      widget.listener
          ?.call(context, AsyncSnapshot.withError(ConnectionState.done, error));
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: widget.stream,
      builder: (context, snapshot) => widget.builder(context, snapshot),
    );
  }
}
