class CreateVirtualTourRequest {
  final String title;
  final String tourUrl;

  const CreateVirtualTourRequest({required this.title, required this.tourUrl});

  Map<String, dynamic> toJson() => {'title': title, 'tourUrl': tourUrl};
}
