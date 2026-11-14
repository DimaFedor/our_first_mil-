import '../../../foundation/json.dart';

class ShopItem {
  final String id;
  final int cost;
  const ShopItem(this.id, this.cost);
}

const shopItems = [
  ShopItem('booster', 80),
  ShopItem('shield', 95),
  ShopItem('hints', 55),
  ShopItem('frame', 140),
];

class RewardPolicy {
  static int level(int xp) {
    var result = 1;
    while (result < 100 && xp >= threshold(result + 1)) {
      result++;
    }
    return result;
  }

  static int threshold(int level) => 25 * level * (level - 1);
  static int lessonXp(int base, bool boost) =>
      base + (boost ? (base * 0.25).round() : 0);
  static String dayKey(DateTime now) =>
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  static int dayDistance(String before, String after) {
    final first = DateTime.tryParse(before);
    final second = DateTime.tryParse(after);
    if (first == null || second == null) return 0;
    return DateTime.utc(
      second.year,
      second.month,
      second.day,
    ).difference(DateTime.utc(first.year, first.month, first.day)).inDays;
  }
}

class Wallet {
  final int credits;
  final int boosts;
  final int shields;
  final int hints;
  final bool hasFrame;
  final String dailyClaim;
  const Wallet({
    this.credits = 0,
    this.boosts = 0,
    this.shields = 0,
    this.hints = 0,
    this.hasFrame = false,
    this.dailyClaim = '',
  });
  factory Wallet.fromJson(JsonMap value) => Wallet(
    credits: jsonInt(value['credits']),
    boosts: jsonInt(value['boosts']),
    shields: jsonInt(value['shields']),
    hints: jsonInt(value['hints']),
    hasFrame: jsonBool(value['hasFrame']),
    dailyClaim: jsonString(value['dailyClaim']),
  );
  JsonMap toJson() => {
    'credits': credits,
    'boosts': boosts,
    'shields': shields,
    'hints': hints,
    'hasFrame': hasFrame,
    'dailyClaim': dailyClaim,
  };
}
