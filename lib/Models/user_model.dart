class UserModel {
  String? id; // Optional: For storing the user's Firebase UID
  String name;
  String email;
  String password;
  String? confirmPassword; // Optional: For signup validation
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

  // Factory constructor to create a UserModel from a Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '', // Note: Password should not be stored in Firestore
      dateOfBirth: map['dateOfBirth'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
    );
  }

  // Convert UserModel to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'mobileNumber': mobileNumber,
      // Do not store password or confirmPassword in Firestore
    };
  }

  // Helper method to check if passwords match (for signup validation)
  bool passwordsMatch() {
    if (confirmPassword == null || confirmPassword!.isEmpty) {
      return true; // If confirmPassword is not provided, skip validation
    }
    return password == confirmPassword;
  }

  // Helper method to check if required fields are filled (for signup)
  bool isSignupComplete() {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        dateOfBirth.isNotEmpty &&
        mobileNumber.isNotEmpty;
  }

  // Helper method to check if required fields are filled (for login)
  bool isLoginComplete() {
    return email.isNotEmpty && password.isNotEmpty;
  }
}