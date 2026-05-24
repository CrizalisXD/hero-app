class Avatar {
  const Avatar({
    required this.userId,
    required this.renderer,
    required this.primaryColor,
    this.bodyType = 'default',
    this.faceType = 'default',
    this.hairType = 'default',
    this.clothingType = 'default',
  });

  final String userId;
  final String renderer;
  final String primaryColor;
  final String bodyType;
  final String faceType;
  final String hairType;
  final String clothingType;

  Avatar copyWith({String? primaryColor}) => Avatar(
        userId: userId,
        renderer: renderer,
        primaryColor: primaryColor ?? this.primaryColor,
        bodyType: bodyType,
        faceType: faceType,
        hairType: hairType,
        clothingType: clothingType,
      );

  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
        userId: json['user_id'] as String,
        renderer: json['renderer'] as String? ?? 'placeholder',
        primaryColor: json['primary_color'] as String? ?? '#7F77DD',
        bodyType: json['body_type'] as String? ?? 'default',
        faceType: json['face_type'] as String? ?? 'default',
        hairType: json['hair_type'] as String? ?? 'default',
        clothingType: json['clothing_type'] as String? ?? 'default',
      );
}
