import 'package:flutter/material.dart';
import 'package:frontend_user/main.dart';
import 'package:frontend_user/pages/auction.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class AuctionCard extends StatelessWidget {
  const AuctionCard({
    super.key,
    required this.productName,
    required this.productDescription,
    this.productImage,
    required this.lastBid,
    required this.auction,
    required this.active,
  });

  final String auction;
  final String productName;
  final String productDescription;
  final String? productImage;
  final int lastBid;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Auction(auction: auction),
        ));
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(8)),
                    clipBehavior: Clip.antiAlias,
                    child: (productImage != null)
                        ? Image.network("$apiAssetsUrl/${productImage!}")
                        : Image.asset("images/placeholder.jpg")),
                const Gap(10),
                Text(productName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    )),
                const Gap(2),
                Text(trimDescription()),
                Text(
                  "Bid Terakhir ${NumberFormat.currency(locale: "id-ID", name: "Rupiah", symbol: "Rp").format(lastBid)}",
                ),
                const Gap(10),
                if (!active)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.redAccent,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Center(
                        child: Text(
                          "Lelang sudah berakhir",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String trimDescription() {
    if (productDescription.length > 30) {
      return "${productDescription.substring(0, 30)}...";
    } else {
      return productDescription;
    }
  }
}
