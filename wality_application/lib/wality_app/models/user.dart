class Users {
  final String userId;
  final String uid;
  final String userName;
  final String email;
  final int currentMl;
  final int totalMl;
  final int botLiv;
  final String profileImg_link;

  Users({
    required this.userId,
    required this.uid,
    required this.userName,
    required this.email,
    required this.currentMl,
    required this.totalMl,
    required this.botLiv,
    required this.profileImg_link,
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
      'profileImg_link': profileImg_link
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
    );
  }
}
