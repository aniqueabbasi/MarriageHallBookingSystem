class VirtualTourInfo {
  final int id;
  final String title;
  final String tourUrl;

  const VirtualTourInfo({
    required this.id,
    required this.title,
    required this.tourUrl,
  });

  factory VirtualTourInfo.fromJson(Map<String, dynamic> json) =>
      VirtualTourInfo(
        id: json['id'] as int,
        title: json['title'] as String,
        tourUrl: json['tourUrl'] as String,
      );
}
