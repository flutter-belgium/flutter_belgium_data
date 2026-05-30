import 'package:flutter_belgium_data/src/flutter_belgium/models/person.dart';

class Testimonial {
  const Testimonial({required this.text, required this.author});

  final String text;
  final Person author;

  factory Testimonial.fromJson(Map<String, dynamic> json) => Testimonial(
    text: json['text'] as String,
    author: Person.fromJson(json['author'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {'text': text, 'author': author.toJson()};
}
