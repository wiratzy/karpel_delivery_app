import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/item_provider.dart';
import 'package:provider/provider.dart';

class RestaurantConflictDialog extends StatelessWidget {
  final int itemId;
  final int qty;
  final VoidCallback? onConfirm;

  const RestaurantConflictDialog({
    super.key,
    required this.itemId,
    required this.qty,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      width: media.width,
      decoration: BoxDecoration(
        color: Tcolor.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  itemProvider.clearPendingCartItemWithoutNotify(); // Method baru tanpa notifyListeners
                  Navigator.pop(context);
                  print('Bottom sheet closed via close button');
                },
                icon: Icon(
                  Icons.close,
                  color: Tcolor.primaryText,
                  size: 25,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning,
                color: Tcolor.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Restaurant Berbeda !',
                style: TextStyle(
                  color: Tcolor.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Keranjang Anda berisi makanan dari restoran lain. Menambahkan makanan ini akan mengganti seluruh keranjang Anda. Lanjutkan?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Tcolor.secondaryText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: RoundButton(
                  title: 'Cancel',
                  type: RoundButtonType.textPrimary,
                  onPressed: () {
                    itemProvider.clearPendingCartItemWithoutNotify(); // Method baru tanpa notifyListeners
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Action cancelled')),
                    );
                    print('Bottom sheet closed via Cancel button');
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: RoundButton(
                  title: 'Yes',
                  type: RoundButtonType.bgPrimary,
                  onPressed: () async {
                    // Simpan ScaffoldMessengerState sebelum menutup bottom sheet
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    
                    // Tutup bottom sheet
                    Navigator.pop(context);
                    print('Bottom sheet closed via Yes button');
                    print('Pending item before operation: ${itemProvider.pendingCartItem}');
                    // Jalankan operasi asinkronus
                    try {
                      await itemProvider.clearCart(authProvider.token!);
                      await itemProvider.addPendingItemToCart(
                        authProvider.token!,
                        authProvider.user!.id,
                      );

                      // Tampilkan snackbar menggunakan ScaffoldMessengerState yang disimpan
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('Cart updated with new item')),
                      );

                      // Panggil onConfirm setelah semua operasi selesai
                      if (onConfirm != null) {
                        onConfirm!();
                      }
                    } catch (e) {
                      print('Error while updating cart: $e');
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}