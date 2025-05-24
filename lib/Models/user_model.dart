class UserModel {
  String? id;
  String name;
  String email;
  String password;
  String? confirmPassword;
  String dateOfBirth;
  String mobileNumber;
  double balance;

  UserModel({
    this.id,
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword,
    this.dateOfBirth = '',
    this.mobileNumber = '',
    this.balance = 0.0,
  });
  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      balance: (map['balance'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'mobileNumber': mobileNumber,
      'balance': balance,
    };
  }

  bool passwordsMatch() {
    if (confirmPassword == null || confirmPassword!.isEmpty) {
      return true;
    }
    return password == confirmPassword;
  }

  bool isSignupComplete() {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        dateOfBirth.isNotEmpty &&
        mobileNumber.isNotEmpty;
  }

  bool isLoginComplete() {
    return email.isNotEmpty && password.isNotEmpty;
  }
}
