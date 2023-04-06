import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:frontend_user/main.dart';
import 'package:frontend_user/widget/auction_card.dart';
import 'package:frontend_user/widget/default_layout.dart';
import 'package:gap/gap.dart';

class Auctions extends StatefulWidget {
  const Auctions({super.key, this.onlyFollowed});

  final bool? onlyFollowed;

  @override
  State<Auctions> createState() => _AuctionsState();
}

class _AuctionsState extends State<Auctions> {
  List<dynamic> _auctions = [];
  List<dynamic> _categories = [];
  String? _keyword;
  String _category = "";
  int _filter = 0;

  fetchAuctions() async {
    Response res;
    SessionManager session = SessionManager();
    String filter;
    switch (_filter) {
      case 0:
        filter = "mulai_asc";
        break;
      case 1:
        filter = "mulai_desc";
        break;
      case 2:
        filter = "selesai_asc";
        break;
      case 3:
        filter = "selesai_desc";
        break;
      case 4:
        filter = "harga_awal";
        break;
      default:
        filter = "mulai_desc";
        break;
    }

    try {
      if (super.widget.onlyFollowed == true) {
        res = await dio.get("$apiUrl/auctions",
            options: Options(headers: {
              'Authorization': 'Basic ${await session.get("Auth-Header")}'
            }),
            queryParameters: {
              'subscribed': 'true',
              'search': _keyword,
              'category': _category,
              'filter': filter,
            });
      } else {
        res = await dio.get("$apiUrl/auctions",
            options: Options(headers: {
              'Authorization': 'Basic ${await session.get("Auth-Header")}'
            }),
            queryParameters: {
              'search': _keyword,
              'category': _category,
              'filter': filter,
            });
      }

      setState(() {
        _auctions = (res.data['data'] ?? []).map((auction) {
          String? fotoBarang;
          int lastBid = auction['harga_awal'];

          if ((auction['Barang']['FotoBarang'] as List?) != null &&
              (auction['Barang']['FotoBarang'] as List).isNotEmpty) {
            fotoBarang =
                (auction['Barang']['FotoBarang'] as List)[0]['filename'];
          }
          if ((auction['Penawaran'] as List).isNotEmpty) {
            lastBid = (auction['Penawaran'] as List).last['harga'];
          }

          return AuctionCard(
            auction: auction['id_lelang'],
            productName: auction['Barang']['nama'],
            productDescription: auction['Barang']['deskripsi'],
            productImage: fotoBarang,
            lastBid: lastBid,
            active: auction['status_lelang']! == 'dibuka',
          );
        }).toList();
      });
    } catch (e) {
      if (e.runtimeType == DioError) {
        if ((e as DioError).response == null) {
          return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text("Terjadi kesalahan")));
        } else {
          return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(e.response!.data['error'])));
        }
      }
    }
  }

  fetchCategories() async {
    try {
      Response res = await dio.get(
        "$apiUrl/categories",
        options: Options(headers: {
          'Authorization': 'Basic ${await SessionManager().get("Auth-Header")}'
        }),
      );
      if (res.statusCode == 200) {
        setState(() {
          _categories = res.data['data'];
        });
      }
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();

    fetchCategories();
    fetchAuctions();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      body: RefreshIndicator(
        onRefresh: () => fetchAuctions(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Search bar
              Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Form(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            suffix: Icon(Icons.search),
                            hintText: "Cari barang dilelang",
                          ),
                          onChanged: (value) {
                            setState(() {
                              _keyword = value;
                            });
                          },
                          onEditingComplete: fetchAuctions,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_categories.isNotEmpty) ...[
                          DropdownButton(
                            items: [
                              const DropdownMenuItem(
                                value: "",
                                child: Text("Tampilkan semua"),
                              ),
                              ..._categories.map((category) => DropdownMenuItem(
                                    value: category['id_kategori'],
                                    child: Text(category['nama']),
                                  )),
                            ],
                            value: _category,
                            onChanged: (value) {
                              setState(() {
                                _category = "$value";
                              });
                              fetchAuctions();
                            },
                          ),
                          const Gap(10)
                        ],
                        DropdownButton(
                          items: const [
                            DropdownMenuItem(
                              value: 0,
                              child: Text("Mulai Terlama"),
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: Text("Mulai Terkini"),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text("Selesai Terlama"),
                            ),
                            DropdownMenuItem(
                              value: 3,
                              child: Text("Selesai Terkini"),
                            ),
                            DropdownMenuItem(
                              value: 4,
                              child: Text("Harga awal"),
                            ),
                          ],
                          value: _filter,
                          onChanged: (value) {
                            setState(() {
                              _filter = value!;
                            });
                            fetchAuctions();
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    if (_auctions.isEmpty)
                      Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text((super.widget.onlyFollowed == true)
                              ? "Belum ada pelelangan yang kamu ikuti"
                              : "Belum ada pelelangan"),
                          subtitle: Text((super.widget.onlyFollowed == true)
                              ? "Subscribe pelelangan terlebih dahulu"
                              : "Coba lagi dalam beberapa waktu"),
                        ),
                      ),
                    ..._auctions,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
