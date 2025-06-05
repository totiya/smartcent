import 'package:flutter/material.dart';

class Achievement {
  final String name;
  final String description;
  bool unlocked;
  DateTime? unlockedAt;
  final IconData icon;
  final Color color;

  Achievement({
    required this.name,
    required this.description,
    this.unlocked = false,
    this.unlockedAt,
    this.icon = Icons.emoji_events,
    this.color = Colors.amber,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'unlocked': unlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'icon': icon.codePoint,
      'color': color.value,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      name: map['name'] as String,
      description: map['description'] as String,
      unlocked: map['unlocked'] as bool,
      unlockedAt: map['unlockedAt'] != null ? DateTime.parse(map['unlockedAt']) : null,
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
      color: Color(map['color'] as int),
    );
  }

  void unlock() {
    if (!unlocked) {
      unlocked = true;
      unlockedAt = DateTime.now();
    }
  }

  String get timeSinceUnlocked {
    if (!unlocked || unlockedAt == null) return 'Not unlocked yet';
    
    final difference = DateTime.now().difference(unlockedAt!);
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
} 