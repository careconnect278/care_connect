class CareTakerModel {
  String name;
  String phoneNumber;
  String email;
  String careUid;
  List<String> memberUid;
  String careToken;

  CareTakerModel(
      {required this.name,
      required this.phoneNumber,
      required this.email,
      required this.careUid,
      required this.memberUid,
      required this.careToken});

  factory CareTakerModel.fromJson(Map<String, dynamic> json) {
    List members = json["memberUid"];
    return CareTakerModel(
      name: json["name"].toString(),
      phoneNumber: json["phonenumber"].toString(),
      email: json["email"].toString(),
      careUid: json["careUid"].toString(),
      memberUid: members.map((e) => e.toString()).toList(),
      careToken: json["careToken"].toString(),
    );
  }
  Map<String, dynamic> toJson() => {
        "name": name,
        "phonenumber": phoneNumber,
        "email": email,
        "careUid": careUid,
        "memberUid": memberUid,
        "careToken": careToken,
      };
}
