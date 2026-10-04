import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/visitor_service.dart';

class VisitorAvatar extends StatefulWidget {
  const VisitorAvatar({
    super.key,
    required this.name,
    this.photoPath,
    this.radius = 23,
  });

  final String name;
  final String? photoPath;
  final double radius;

  @override
  State<VisitorAvatar> createState() =>
      _VisitorAvatarState();
}

class _VisitorAvatarState extends State<VisitorAvatar> {
  late Future<String?> _photoFuture;

  @override
  void initState() {
    super.initState();

    _photoFuture = VisitorService.instance
        .createVisitorPhotoUrl(
      widget.photoPath,
    );
  }

  @override
  void didUpdateWidget(
      covariant VisitorAvatar oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.photoPath != widget.photoPath) {
      _photoFuture = VisitorService.instance
          .createVisitorPhotoUrl(
        widget.photoPath,
      );
    }
  }

  String get _initials {
    final parts = widget.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _photoFuture,
      builder: (context, snapshot) {
        final photoUrl = snapshot.data;

        return CircleAvatar(
          radius: widget.radius,
          backgroundColor: AppColors.lightBlue,
          backgroundImage:
          photoUrl != null
              ? NetworkImage(photoUrl)
              : null,
          child: photoUrl == null
              ? Text(
            _initials,
            style:  TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          )
              : null,
        );
      },
    );
  }
}