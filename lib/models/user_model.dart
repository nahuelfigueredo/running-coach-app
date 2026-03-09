/// Modelo de usuario para la aplicación Running Coach App
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'coach' | 'student'
  final String? coachId;
  final DateTime createdAt;
  final String? profileImage;
  final String? phone;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.coachId,
    required this.createdAt,
    this.profileImage,
    this.phone,
  });

  /// Crea un UserModel desde un mapa de Firestore
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: map['role'] as String? ?? 'student',
      coachId: map['coachId'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['createdAt'] as dynamic).millisecondsSinceEpoch as int,
            )
          : DateTime.now(),
      profileImage: map['profileImage'] as String?,
      phone: map['phone'] as String?,
    );
  }

  /// Convierte el modelo a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      if (coachId != null) 'coachId': coachId,
      'createdAt': createdAt,
      if (profileImage != null) 'profileImage': profileImage,
      if (phone != null) 'phone': phone,
    };
  }

  /// Crea una copia del modelo con campos modificados
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? coachId,
    DateTime? createdAt,
    String? profileImage,
    String? phone,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      coachId: coachId ?? this.coachId,
      createdAt: createdAt ?? this.createdAt,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
    );
  }

  /// Verifica si el usuario es coach
  bool get isCoach => role == 'coach';

  /// Verifica si el usuario es estudiante
  bool get isStudent => role == 'student';

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, role: $role)';
  }
}
