import 'package:json_annotation/json_annotation.dart';

part 'hadith.g.dart';

@JsonSerializable()
class Hadith {
  final String id;
  final String narrator;
  final String textArabic;
  final String textTranslation;
  final String explanation;
  final String book; // Sahih Bukhari, Müslim, vb.
  final String hadithNumber;
  final int degree; // Sahih, Hasen, Zaeef vb.
  final String category; // İman, Namaz, Oruç vb.

  Hadith({
    required this.id,
    required this.narrator,
    required this.textArabic,
    required this.textTranslation,
    required this.explanation,
    required this.book,
    required this.hadithNumber,
    required this.degree,
    required this.category,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) =>
      _$HadithFromJson(json);

  Map<String, dynamic> toJson() => _$HadithToJson(this);
}
