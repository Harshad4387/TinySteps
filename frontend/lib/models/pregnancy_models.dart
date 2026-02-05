/// ================= CHECKLIST ITEM =================
class ChecklistItem {
  String item;
  bool done;

  ChecklistItem({
    required this.item,
    required this.done,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      item: json['item'] ?? '',
      done: json['done'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "item": item,
        "done": done,
      };
}

/// ================= TEST / SCAN =================
class TestScan {
  final String name;
  final String date;

  TestScan({
    required this.name,
    required this.date,
  });

  factory TestScan.fromJson(Map<String, dynamic> json) {
    return TestScan(
      name: json['name'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "date": date,
      };
}

/// ================= BACKEND RESPONSE MODEL =================
class PregnancyBackendData {
  final String parentId;
  final int month;
  List<ChecklistItem> checklist;
  List<TestScan> testsAndScans;

  PregnancyBackendData({
    required this.parentId,
    required this.month,
    required this.checklist,
    required this.testsAndScans,
  });

  factory PregnancyBackendData.fromJson(Map<String, dynamic> json) {
    return PregnancyBackendData(
      parentId: json['parentId'] ?? '',
      month: json['month'] ?? 0,
      checklist: (json['checklist'] ?? [])
          .map<ChecklistItem>((e) => ChecklistItem.fromJson(e))
          .toList(),
      testsAndScans: (json['testsAndScans'] ?? [])
          .map<TestScan>((e) => TestScan.fromJson(e))
          .toList(),
    );
  }
}
