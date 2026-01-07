import 'package:flutter/material.dart';

enum AppLanguage {
  english,
  vietnamese,
}

class AppLocalizations {
  final AppLanguage language;

  AppLocalizations(this.language);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Menu Screen
  String get appTitle =>
      language == AppLanguage.vietnamese ? 'SKY HAULER' : 'SKY HAULER';
  String get appSubtitle =>
      language == AppLanguage.vietnamese ? 'HEAVY FUEL' : 'HEAVY FUEL';
  String get appTagline => language == AppLanguage.vietnamese
      ? 'Bơm nhiên liệu để bay, nhưng chú ý trọng lượng!'
      : 'Pump fuel to fly, but watch the weight!';
  String get money => language == AppLanguage.vietnamese ? 'Tiền:' : 'Money:';
  String get totalDistance => language == AppLanguage.vietnamese
      ? 'Tổng quãng đường:'
      : 'Total Distance:';
  String get startMission =>
      language == AppLanguage.vietnamese ? 'BẮT ĐẦU NHIỆM VỤ' : 'START MISSION';
  String get hangar =>
      language == AppLanguage.vietnamese ? 'KHO MÁY BAY' : 'HANGAR';
  String get planes =>
      language == AppLanguage.vietnamese ? 'máy bay' : 'planes';
  String get howToPlay =>
      language == AppLanguage.vietnamese ? 'HƯỚNG DẪN CHƠI' : 'HOW TO PLAY';

  // How to Play Dialog
  String get howToPlayTitle =>
      language == AppLanguage.vietnamese ? 'HƯỚNG DẪN CHƠI' : 'HOW TO PLAY';
  String get controls =>
      language == AppLanguage.vietnamese ? '🎮 ĐIỀU KHIỂN' : '🎮 CONTROLS';
  String get controlsText1 => language == AppLanguage.vietnamese
      ? '• Giữ 2 NGÓN TAY để đổ nhiên liệu & đẩy'
      : '• Hold 2 FINGERS to refuel & thrust';
  String get controlsText2 => language == AppLanguage.vietnamese
      ? '• Nhả ra để lướt và tiết kiệm nhiên liệu'
      : '• Release to glide and save fuel';
  String get controlsText3 => language == AppLanguage.vietnamese
      ? '• Vuốt XUỐNG để thả hàng'
      : '• Swipe DOWN to jettison cargo';
  String get physics =>
      language == AppLanguage.vietnamese ? '⚖️ VẬT LÝ' : '⚖️ PHYSICS';
  String get physicsText1 => language == AppLanguage.vietnamese
      ? '• Nhiều nhiên liệu = Máy bay nặng hơn = Khó bay hơn'
      : '• More fuel = Heavier plane = Harder to fly';
  String get physicsText2 => language == AppLanguage.vietnamese
      ? '• Hàng nặng cần quản lý nhiên liệu cẩn thận'
      : '• Heavy cargo needs careful fuel management';
  String get physicsText3 => language == AppLanguage.vietnamese
      ? '• Cân bằng lực đẩy và trọng lượng để sống sót'
      : '• Balance thrust and weight to survive';
  String get dangers =>
      language == AppLanguage.vietnamese ? '⚠️ NGUY HIỂM' : '⚠️ DANGERS';
  String get dangersText1 => language == AppLanguage.vietnamese
      ? '• Va vào địa hình = KẾT THÚC'
      : '• Crash into terrain = GAME OVER';
  String get dangersText2 => language == AppLanguage.vietnamese
      ? '• Hết nhiên liệu = RƠI'
      : '• Run out of fuel = FALL';
  String get dangersText3 => language == AppLanguage.vietnamese
      ? '• Bay quá cao = Sét đánh gây sát thương'
      : '• Fly too high = Lightning damage';
  String get rewards =>
      language == AppLanguage.vietnamese ? '💰 PHẦN THƯỞNG' : '💰 REWARDS';
  String get rewardsText1 => language == AppLanguage.vietnamese
      ? '• Giao hàng = Tiền lớn'
      : '• Deliver cargo = Big money';
  String get rewardsText2 => language == AppLanguage.vietnamese
      ? '• Thả hàng = Chỉ điểm quãng đường'
      : '• Jettison cargo = Only distance points';
  String get rewardsText3 => language == AppLanguage.vietnamese
      ? '• Mua máy bay tốt hơn trong kho'
      : '• Buy better planes in the hangar';
  String get gotIt =>
      language == AppLanguage.vietnamese ? 'HIỂU RỒI!' : 'GOT IT!';

  // Cargo Selection Screen
  String get selectContract =>
      language == AppLanguage.vietnamese ? 'CHỌN HỢP ĐỒNG' : 'SELECT CONTRACT';
  String get difficultyEasy =>
      language == AppLanguage.vietnamese ? 'DỄ' : 'EASY';
  String get difficultyMedium =>
      language == AppLanguage.vietnamese ? 'VỪA' : 'MEDIUM';
  String get difficultyHard =>
      language == AppLanguage.vietnamese ? 'KHÓ' : 'HARD';
  String get difficultyExtreme =>
      language == AppLanguage.vietnamese ? 'CỰC KHÓ' : 'EXTREME';
  String get explosive =>
      language == AppLanguage.vietnamese ? 'NỔ' : 'EXPLOSIVE';

  // Cargo descriptions
  String get mailName =>
      language == AppLanguage.vietnamese ? 'Thư từ (Hạng C)' : 'Mail (Class C)';
  String get mailDesc => language == AppLanguage.vietnamese
      ? 'Giao hàng nhẹ - Dễ'
      : 'Light delivery - Easy';
  String get foodName => language == AppLanguage.vietnamese
      ? 'Thực phẩm (Hạng B)'
      : 'Food (Class B)';
  String get foodDesc => language == AppLanguage.vietnamese
      ? 'Trọng lượng vừa - Bình thường'
      : 'Medium weight - Moderate';
  String get goldName =>
      language == AppLanguage.vietnamese ? 'Vàng (Hạng A)' : 'Gold (Class A)';
  String get goldDesc => language == AppLanguage.vietnamese
      ? 'Hàng nặng - Khó'
      : 'Heavy cargo - Difficult';
  String get uraniumName => language == AppLanguage.vietnamese
      ? 'Uranium (Hạng S)'
      : 'Uranium (Class S)';
  String get uraniumDesc => language == AppLanguage.vietnamese
      ? 'Nổ! Cực kỳ khó'
      : 'Explosive! Extreme difficulty';

  // Game Screen
  String get distance =>
      language == AppLanguage.vietnamese ? 'Quãng đường' : 'Distance';
  String get fuel => language == AppLanguage.vietnamese ? 'NHIÊN LIỆU' : 'FUEL';
  String get holdTwoFingers =>
      language == AppLanguage.vietnamese ? 'GIỮ 2 NGÓN TAY' : 'HOLD 2 FINGERS';
  String get toRefuelThrust => language == AppLanguage.vietnamese
      ? 'để đổ nhiên liệu & đẩy'
      : 'to refuel & thrust';
  String get swipeDown =>
      language == AppLanguage.vietnamese ? 'VUỐT XUỐNG' : 'SWIPE DOWN';
  String get toJettisonCargo =>
      language == AppLanguage.vietnamese ? 'để thả hàng' : 'to jettison cargo';
  String get refueling => language == AppLanguage.vietnamese
      ? '⛽ ĐANG ĐỔ NHIÊN LIỆU'
      : '⛽ REFUELING';
  String get engineDamaged => language == AppLanguage.vietnamese
      ? '⚡ ĐỘNG CƠ BỊ HƯ!'
      : '⚡ ENGINE DAMAGED!';
  String get paused =>
      language == AppLanguage.vietnamese ? 'TẠM DỪNG' : 'PAUSED';
  String get resume =>
      language == AppLanguage.vietnamese ? 'TIẾP TỤC' : 'RESUME';
  String get mainMenu =>
      language == AppLanguage.vietnamese ? 'MENU CHÍNH' : 'MAIN MENU';

  // Game Over Screen
  String get crashed =>
      language == AppLanguage.vietnamese ? 'VA CHẠM!' : 'CRASHED!';
  String get crashedMessage => language == AppLanguage.vietnamese
      ? 'Bạn đã va vào địa hình!'
      : 'You hit the terrain!';
  String get outOfFuel =>
      language == AppLanguage.vietnamese ? 'HẾT NHIÊN LIỆU!' : 'OUT OF FUEL!';
  String get outOfFuelMessage => language == AppLanguage.vietnamese
      ? 'Máy bay đã hết nhiên liệu!'
      : 'Your plane ran out of fuel!';
  String get explosion =>
      language == AppLanguage.vietnamese ? 'NỔ!' : 'EXPLOSION!';
  String get explosionMessage => language == AppLanguage.vietnamese
      ? 'Hàng nổ đã phát nổ!'
      : 'The explosive cargo detonated!';
  String get gameOver =>
      language == AppLanguage.vietnamese ? 'KẾT THÚC' : 'GAME OVER';
  String get flightReport =>
      language == AppLanguage.vietnamese ? 'BÁO CÁO BAY' : 'FLIGHT REPORT';
  String get distanceTraveled => language == AppLanguage.vietnamese
      ? 'Quãng đường đi'
      : 'Distance Traveled';
  String get distanceBonus => language == AppLanguage.vietnamese
      ? 'Thưởng quãng đường'
      : 'Distance Bonus';
  String get cargoDelivered =>
      language == AppLanguage.vietnamese ? 'Giao hàng ✓' : 'Cargo Delivered ✓';
  String get cargoStatus =>
      language == AppLanguage.vietnamese ? 'Trạng thái hàng' : 'Cargo Status';
  String get jettisoned =>
      language == AppLanguage.vietnamese ? 'ĐÃ THẢ' : 'JETTISONED';
  String get totalEarned =>
      language == AppLanguage.vietnamese ? 'TỔNG THU' : 'TOTAL EARNED';
  String get totalMoney =>
      language == AppLanguage.vietnamese ? 'Tổng tiền' : 'Total Money';
  String get tryAgain =>
      language == AppLanguage.vietnamese ? 'THỬ LẠI' : 'TRY AGAIN';
  String get continueFlying =>
      language == AppLanguage.vietnamese ? 'TIẾP TỤC BAY' : 'CONTINUE FLYING';
  String get continueHint => language == AppLanguage.vietnamese
      ? '(Chỉ 1 lần mỗi chuyến bay)'
      : '(One time per flight)';

  // Plane Selection Screen
  String get selectPlane =>
      language == AppLanguage.vietnamese ? 'CHỌN MÁY BAY' : 'SELECT PLANE';
  String get contract =>
      language == AppLanguage.vietnamese ? 'Hợp đồng:' : 'Contract:';
  String get startFlight =>
      language == AppLanguage.vietnamese ? 'BẮT ĐẦU BAY' : 'START FLIGHT';
  String get buy => language == AppLanguage.vietnamese ? 'MUA' : 'BUY';
  String get buyMessage1 =>
      language == AppLanguage.vietnamese ? 'Giá' : 'This will cost';
  String get buyMessage2 =>
      language == AppLanguage.vietnamese ? 'Bạn có' : 'You have';
  String get cancel => language == AppLanguage.vietnamese ? 'Hủy' : 'Cancel';
  String get purchased =>
      language == AppLanguage.vietnamese ? 'đã mua!' : 'purchased!';
  String get selected =>
      language == AppLanguage.vietnamese ? 'ĐÃ CHỌN' : 'SELECTED';
  String get owned => language == AppLanguage.vietnamese ? 'SỞ HỮU' : 'OWNED';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final AppLanguage language;

  const AppLocalizationsDelegate(this.language);

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(language);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => old.language != language;
}
