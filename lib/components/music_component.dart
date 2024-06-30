import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MusicComponent extends StatelessWidget {
  final Map<String, dynamic> content;
  final int index;
  final Function onClick;
  const MusicComponent({
    super.key,
    required this.content,
    required this.onClick,
    required this.index,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClick(index);
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    content['title']!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  content['artist'],
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
