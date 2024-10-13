class User {
  String? email;
  String? password;
  String? name;
  int? age;
  String? gender;
  String? intro;
  String? job;
  String? country;
  String? area;
  String? description;
  String? friendshipStatus;

  User(
      {this.email,
      this.password,
      this.name,
      this.age,
      this.gender,
      this.intro,
      this.job,
      this.country,
      this.area,
      this.description,
      this.friendshipStatus});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'age': age,
      'gender': gender,
      'intro': intro,
      'job': job,
      'country': country,
      'area': area,
      'description': description,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      password: json['password'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      intro: json['intro'],
      job: json['job'],
      country: json['country'],
      area: json['area'],
      description: json['description'],
      friendshipStatus: json['friendshipStatus'],
    );
  }
}
