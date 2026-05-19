import 'package:flutter/material.dart';
import '../../translations.dart';

class DeleteConfirmDialog {
  // الألوان الجديدة - هادئة ومحايدة
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color softWhite = Color(0xFFF8F8F8);
  static const Color lightGray = Color(0xFFE5E5E5);
  static const Color mediumGray = Color(0xFF9E9E9E);
  static const Color darkGray = Color(0xFF424242);
  static const Color charcoal = Color(0xFF2C2C2C);

  static Future<bool?> show({
    required BuildContext context,
    String? title,
    String? message,
    String? confirmText,
    String? cancelText,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: lightGray,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: darkGray,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  title ?? S.of(context, 'warning'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkGray,
                  ),
                ),

                const SizedBox(height: 16),

                // Message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: softWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message ?? S.of(context, 'confirm_delete_generic'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: mediumGray,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Cancel Button (Safe option - prominent)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: charcoal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      cancelText ?? S.of(context, 'no_go_back'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: pureWhite,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Delete Button (Dangerous option - less prominent)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: darkGray, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmText ?? S.of(context, 'yes_delete'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGray,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
