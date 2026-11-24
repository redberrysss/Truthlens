enum Verdict { likely, none, inconclusive }

class Check {
  final String id;
  final DateTime date;
  final Verdict verdict;
  final bool demo;
  final bool message;
  Check({
    required this.id,
    required this.date,
    required this.verdict,
    this.demo = true,
    this.message = false,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'verdict': verdict.index,
    'demo': demo,
    'message': message,
  };
  factory Check.fromJson(Map<String, dynamic> j) => Check(
    id: j['id'],
    date: DateTime.parse(j['date']),
    verdict: Verdict.values[j['verdict']],
    demo: j['demo'],
    message: j['message'],
  );
}
