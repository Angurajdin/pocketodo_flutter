class UserDetail {

  UserDetail({required this.userName, required this.email,
    required this.password, required this.phoneNo,
    required this.tasks, required this.assigned,
    required this.groupTasks, required this.categories,
    required this.declined
  });

  UserDetail.fromJson(Map<String, Object?> json)
      : this(
    userName: json['userName']! as String,
    email: json['email']! as String,
    password: json['password']! as String,
    phoneNo: json['phoneNo']! as String,
    tasks: json['tasks']! as List,
    assigned: json['assigned']! as List,
    groupTasks: json['groupTasks']! as List,
    categories: json['categories']! as List,
    declined: json['declined']! as List,
  );

  final String userName;
  final String email;
  final String password;
  final String phoneNo;
  List tasks;
  List assigned;
  List groupTasks;
  List categories;
  List declined;



  Map<String, Object?> toJson() {
    return {
      'title': userName,
      'genre': email,
      'password': password,
      'phoneNo': phoneNo,
      'tasks': tasks,
      'assigned': assigned,
      'groupTasks': groupTasks,
      'categories': categories,
      'declined': declined,
    };
  }
}