class UserModel {
  String? id;
  String name;
  String email;
  String password;
  String? confirmPassword;
  String dateOfBirth;
  String mobileNumber;

  UserModel({
    this.id,
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword,
    this.dateOfBirth = '',
    this.mobileNumber = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'mobileNumber': mobileNumber,
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
