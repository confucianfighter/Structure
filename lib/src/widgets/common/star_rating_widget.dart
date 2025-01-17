import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onRatingChanged;
  final int maxRating;

  const StarRatingWidget({
    Key? key,
    required this.rating,
    required this.onRatingChanged,
    this.maxRating = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        return IconButton(
          icon: Icon(
            Icons.star,
            color: index < rating ? Colors.amber : Colors.grey,
          ),
          onPressed: () {
            onRatingChanged?.call(index + 1);
          },
        );
      }),
    );
  }
}
