class Record {
  final String name;
  final String address;
  final String phone;

  Record(this.name, this.address, this.phone);

  @override
  String toString() {
    return 'Record({"name": "$name", "address": "$address", "phone": "$phone"})';
  }
}
