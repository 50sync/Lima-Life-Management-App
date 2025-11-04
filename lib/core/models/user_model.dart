class UserModel {
  final String id;
  final num currentBalance;
  final String email;
  const UserModel({required this.id,required this.currentBalance, required this.email});

  factory UserModel.fromJson(Map<String,dynamic> doc) {
    return UserModel(id: doc['id'],currentBalance: doc['balance'], email: doc['email']);
  }
}
