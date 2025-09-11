class FAQItem {
  final int id;
  final String category;
  final String question;
  final String answer;
  final String createdAt;

  FAQItem({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    required this.createdAt,
  });

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(
      id: json['id'],
      category: json['category'],
      question: json['question'],
      answer: json['answer'],
      createdAt: json['created_at'],
    );
  }
}