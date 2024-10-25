class Users {
  final String? userId;
  final String uid;
  final String userName;
  final String email;
  final int currentMl;
  final int totalMl;
  final int botLiv;
  final String profileImg_link;
  final DateTime? startFillingTime;
  final int fillingLimit;
  final List<String> couponCheck;
  final int eventBot;
  final int dayBot;
  final int monthBot;
  final int yearBot;
  final String realName;
  final String sID;

  Users({
    this.userId,
    required this.uid,
    required this.userName,
    required this.email,
    required this.currentMl,
    required this.totalMl,
    required this.botLiv,
    required this.profileImg_link,
    this.startFillingTime,
    required this.fillingLimit,
    this.couponCheck = const [],
    required this.eventBot,
    required this.dayBot,
    required this.monthBot,
    required this.yearBot,
    required this.realName,
    required this.sID,
  });

  // Convert a User instance to a map
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'uid': uid,
      'username': userName,
      'email': email,
      'currentMl': currentMl,
      'totalMl': totalMl,
      'botLiv': botLiv,
      'profileImg_link': profileImg_link,
      'startFillingTime': startFillingTime?.toIso8601String(),
      'fillingLimit': fillingLimit,
      'couponCheck': couponCheck,
      'eventBot': eventBot,
      'dayBot': dayBot,
      'monthBot': monthBot,
      'yearBot': yearBot,
      'realName': realName,
      'sID': sID,
    };
  }

  // Convert a map to a User instance
  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      userId: json['user_id'],
      uid: json['uid'],
      userName: json['userName'],
      email: json['email'],
      currentMl: json['currentMl'],
      totalMl: json['totalMl'],
      botLiv: json['botLiv'],
      profileImg_link: json['profileImg_link'],
      startFillingTime: json['startFillingTime'] != null
          ? DateTime.parse(json['startFillingTime'])
          : null, fillingLimit: json['fillingLimit'], 
      couponCheck:
          json['couponCheck'] != null ? List<String>.from(json['couponCheck']) : [],// Default to empty list if null);
      eventBot: json['eventBot'],
      dayBot: json['dayBot'],
      monthBot: json['monthBot'],
      yearBot: json['yearBot'],
      realName: json['realName'],
      sID: json['sID'],
    ); 
  }
}
