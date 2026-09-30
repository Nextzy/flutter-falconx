class BlocEvent<Event> {
  const new(
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
