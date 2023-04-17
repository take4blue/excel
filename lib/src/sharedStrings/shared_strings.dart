part of excel;

class _SharedStringsMaintainer {
  static final instance = _SharedStringsMaintainer._();

  late Map<SharedString, _IndexingHolder> _map;
  late List<SharedString> _list;
  late int _index;

  factory _SharedStringsMaintainer._() {
    return _SharedStringsMaintainer();
  }

  _SharedStringsMaintainer() {
    _map = <SharedString, _IndexingHolder>{};
    _list = <SharedString>[];
    _index = 0;
  }

  SharedString addFromString(String val) {
    final newSharedString = SharedString(
        node: XmlElement(XmlName('si'), [], [
      XmlElement(XmlName('t'),
          [XmlAttribute(XmlName("space", "xml"), "preserve")], [XmlText(val)]),
    ]));

    add(newSharedString);
    return newSharedString;
  }

  /// The strings stored in sharedStrings are not unique, and there may
  /// be multiple instances of the same string.
  /// To cope with this, the list should be read in such a way that the
  /// order and number of strings registered in the list is maintained.
  /// 
  /// For [Parser._parseSharedString].
  void parseAdd(SharedString val) {
    if (_map[val] == null) {
      _map[val] = _IndexingHolder(_index);
    } else {
      _map[val]!.increaseCount();
    }
    _list.add(val);
    _index += 1;
  }

  void add(SharedString val) {
    if (_map[val] == null) {
      _map[val] = _IndexingHolder(_index);
      _list.add(val);
      _index += 1;
    } else {
      _map[val]!.increaseCount();
    }
  }

  int indexOf(SharedString val) {
    return _map[val] != null ? _map[val]!.index : -1;
  }

  SharedString? value(int i) {
    if (i < _list.length) {
      return _list[i];
    } else {
      return null;
    }
  }

  void clear() {
    _index = 0;
    _list = <SharedString>[];
    _map = <SharedString, _IndexingHolder>{};
  }

  void ensureReinitialize() {
    _map = <SharedString, _IndexingHolder>{};
    _list = <SharedString>[];
    _index = 0;
  }
}

class _IndexingHolder {
  final int index;
  late int count;
  _IndexingHolder(this.index, [int _count = 1]) {
    this.count = _count;
  }

  void increaseCount() {
    this.count += 1;
  }
}

class SharedString {
  final XmlElement node;
  final int _hashCode;

  SharedString({required this.node}) : _hashCode = node.toString().hashCode;

  @override
  String toString() {
    var buffer = StringBuffer();
    node.findAllElements('t').forEach((child) {
      if (child.parentElement == null ||
          child.parentElement!.name.local != 'rPh') {
        buffer.write(Parser._parseValue(child));
      }
    });
    return buffer.toString();
  }

  @override
  int get hashCode => _hashCode;

  @override
  operator ==(Object other) => other.hashCode == _hashCode;
}
