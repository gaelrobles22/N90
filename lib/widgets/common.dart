import 'package:flutter/material.dart';
import '../models/app_models.dart';

const lime = Color(0xFFA3FF3F);
const bg = Color(0xFF0B0B0B);
const card = Color(0xFF141416);

Widget netImage(
  String url, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  String? fallbackAsset,
}) =>
    url.isEmpty && fallbackAsset != null
        ? Image.asset(fallbackAsset, width: width, height: height, fit: fit)
        : Image.network(
            url,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => fallbackAsset != null
                ? Image.asset(
                    fallbackAsset,
                    width: width,
                    height: height,
                    fit: fit,
                  )
                : const Icon(Icons.shield, color: Colors.white54),
          );

Widget title(String t, {String? action, VoidCallback? onAction}) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          t.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white54,
            letterSpacing: 1,
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
      ],
    );

Widget sectionCard(Widget child) => Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );

Widget teamLogo(String url) => ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 58,
        height: 58,
        color: Colors.black26,
        child: netImage(url, fit: BoxFit.contain),
      ),
    );

String statusLabel(MatchStatus s) => switch (s) {
      MatchStatus.live => 'EN VIVO',
      MatchStatus.scheduled => 'PROGRAMADO',
      MatchStatus.finished => 'FINALIZADO',
      MatchStatus.suspended => 'SUSPENDIDO',
    };
