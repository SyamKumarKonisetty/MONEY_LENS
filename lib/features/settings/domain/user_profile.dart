/// User profile domain model for MoneyLens.
class UserProfile {
  final String name;

  const UserProfile({required this.name});

  /// Creates a copy of this [UserProfile] but with the given fields replaced with the new values.
  UserProfile copyWith({String? name}) {
    return UserProfile(name: name ?? this.name);
  }
}
