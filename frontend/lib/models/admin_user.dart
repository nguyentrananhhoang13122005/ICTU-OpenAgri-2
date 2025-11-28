class AdminUser {
  final int id;
  final String email;
  final String username;
  final String? fullName;
  final bool isActive;
  final bool isSuperuser;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminUser({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    required this.isActive,
    required this.isSuperuser,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      fullName: json['full_name'],
      isActive: json['is_active'],
      isSuperuser: json['is_superuser'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'is_active': isActive,
      'is_superuser': isSuperuser,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class AdminUserListResponse {
  final List<AdminUser> users;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  AdminUserListResponse({
    required this.users,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory AdminUserListResponse.fromJson(Map<String, dynamic> json) {
    return AdminUserListResponse(
      users: (json['users'] as List)
          .map((user) => AdminUser.fromJson(user))
          .toList(),
      total: json['total'],
      page: json['page'],
      pageSize: json['page_size'],
      totalPages: json['total_pages'],
    );
  }
}

class AdminUserStats {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int superusers;

  AdminUserStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.superusers,
  });

  factory AdminUserStats.fromJson(Map<String, dynamic> json) {
    return AdminUserStats(
      totalUsers: json['total_users'],
      activeUsers: json['active_users'],
      inactiveUsers: json['inactive_users'],
      superusers: json['superusers'],
    );
  }
}
