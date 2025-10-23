class BlocEvent<Event> {
  const BlocEvent(
    this.name, {
    this.data,
  });

  final Event name;
  final Object? data;

  @override
  String toString() {
    return 'BlocEvent{name: $name, data: $data}';
  }
}


