// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:frontend_user/main.dart';
import 'package:frontend_user/widget/default_layout.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Auction extends StatefulWidget {
  const Auction({super.key, required this.auction});

  final String auction;

  @override
  State<Auction> createState() => AuctionState();
}

class AuctionState extends State<Auction> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String _product = "";
  String _description = "";
  List _images = [];
  DateTime _endsAt = DateTime.now();
  DateTime? _lastBidAt;
  int _startingPrice = 0;
  int? _lastBidNominal;
  int _bidNominal = 0;
  int _minBidNominal = 0;
  bool _active = false;
  bool _winner = false;
  bool _isSubscribed = false;
  bool _paid = false;
  String _phoneNumber = "";

  fetchAuction() async {
    // Payment
    try {
      Response res = await dio.get("$apiUrl/paid/${super.widget.auction}",
          options: Options(headers: {
            'Authorization':
                'Basic ${await SessionManager().get("Auth-Header")}'
          }));
      if (res.statusCode == 200) {
        setState(() {
          _paid = true;
        });
      }
    } catch (e) {
      setState(() {
        _paid = false;
      });
    }

    // Auction
    try {
      Response res = await dio.get(
        "$apiUrl/auction/${super.widget.auction}",
        options: Options(headers: {
          'Authorization': 'Basic ${await SessionManager().get("Auth-Header")}'
        }),
      );

      if (res.statusCode == 200) {
        setState(() {
          _product = res.data['data']['Barang']['nama'];
          _description = res.data['data']['Barang']['deskripsi'];
          _endsAt = DateTime.parse(res.data['data']['selesai_lelang']);
          _startingPrice = res.data['data']['harga_awal'];
          _minBidNominal = res.data['data']['min_penawaran'];
          _active = res.data['data']['status_lelang'] == "dibuka";

          // Is this user the winner of the auction
          if (!_active) {
            if (res.data['data']['Penawaran'] != null) {
              if ((res.data['data']['Penawaran'] as List)
                      .last['id_masyarakat'] ==
                  res.headers['set-cookie']!.first.substring(8)) {
                setState(() {
                  _winner = true;
                });
              }
            }
          }

          // Get the last bid
          if (res.data['data']['Penawaran'] != null) {
            if ((res.data['data']['Penawaran'] as List).isNotEmpty) {
              _lastBidAt = DateTime.parse(
                  (res.data['data']['Penawaran'] as List).last['timestamp']);
              _lastBidNominal = (res.data['data']['Penawaran']).last['harga'];

              if (!_active) {
                _endsAt = _lastBidAt!;
              }
            }
          }

          // Get the item's images
          if (res.data['data']['Barang']['FotoBarang'] != null) {
            _images = (res.data['data']['Barang']['FotoBarang'] as List)
                .map((productImage) {
              return "$apiAssetsUrl/${productImage['filename']}";
            }).toList();
          }
        });
      }
    } catch (e) {
      if (e.runtimeType == DioError) {
        if ((e as DioError).response?.data['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.response!.data['error']),
            backgroundColor: Colors.redAccent,
          ));
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Terjadi kesalahan"),
        backgroundColor: Colors.redAccent,
      ));
    }

    // Subscription
    try {
      Response res = await dio.get("$apiUrl/subscribe/${super.widget.auction}",
          options: Options(headers: {
            'Authorization':
                'Basic ${await SessionManager().get("Auth-Header")}'
          }));
      if (res.statusCode == 200) {
        setState(() {
          _isSubscribed = true;
        });
      }
    } catch (e) {
      setState(() {
        _isSubscribed = false;
      });
    }
  }

  // Bid
  saveBid() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isSubscribed) {
      await updateSubscription();
    }

    try {
      Response res = await dio.post("$apiUrl/bid/${super.widget.auction}",
          options: Options(headers: {
            'Authorization':
                'Basic ${await SessionManager().get("Auth-Header")}'
          }),
          data: {'harga': _bidNominal});
      if (res.statusCode == 201) {
        fetchAuction();
        return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.greenAccent,
            content: Text("Penawaran telah disimpan")));
      }
    } catch (e) {
      if (e.runtimeType == DioError) {
        if ((e as DioError).response?.data['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.response!.data['error']),
            backgroundColor: Colors.redAccent,
          ));
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Terjadi kesalahan"),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  // Subscribe
  updateSubscription() async {
    try {
      if (!_isSubscribed) {
        Response res = await dio.post(
            "$apiUrl/subscribe/${super.widget.auction}",
            options: Options(headers: {
              'Authorization':
                  'Basic ${await SessionManager().get("Auth-Header")}'
            }));
        if (res.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Pelelangan diikuti")));
          setState(() {
            _isSubscribed = true;
          });
        }
      } else if (_isSubscribed) {
        Response res = await dio.delete(
            "$apiUrl/unsubscribe/${super.widget.auction}",
            options: Options(headers: {
              'Authorization':
                  'Basic ${await SessionManager().get("Auth-Header")}'
            }));
        if (res.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Pelelangan dilepaskan")));
          setState(() {
            _isSubscribed = false;
          });
        }
      }
    } catch (e) {
      if (e.runtimeType == DioError) {
        if ((e as DioError).response?.data['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.response!.data['error']),
            backgroundColor: Colors.redAccent,
          ));
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Terjadi kesalahan"),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  // Pay
  payAuction() async {
    try {
      Response res = await dio.post("$apiUrl/pay/${super.widget.auction}",
          options: Options(headers: {
            'Authorization':
                'Basic ${await SessionManager().get("Auth-Header")}'
          }),
          data: {'no_telp': _phoneNumber});
      if (res.statusCode == 201) {
        if (await launchUrl(Uri.parse(res.data['data'][1]['url']))) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Pelelangan berhasil dibayar"),
            backgroundColor: Colors.greenAccent,
          ));
          fetchAuction();
          return;
        } else {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Tidak dapat membuka url pembayaran"),
            backgroundColor: Colors.redAccent,
          ));
          return;
        }
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res.data['data']),
        backgroundColor: Colors.greenAccent,
      ));
      fetchAuction();
    } catch (e) {
      if (e.runtimeType == DioError) {
        if ((e as DioError).response != null &&
            e.response!.data['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.response!.data['error']),
            backgroundColor: Colors.redAccent,
          ));
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Terjadi kesalahan"),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  @override
  void initState() {
    super.initState();

    fetchAuction();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      floatingActionButton: (_active)
          ? FloatingActionButton(
              onPressed: updateSubscription,
              tooltip: (_isSubscribed)
                  ? "Lepaskan pelelangan ini"
                  : "Ikuti pelelangan ini",
              child: Icon((_isSubscribed) ? Icons.check : Icons.bookmark),
            )
          : (!_paid &&
                  _winner) // Kondisi jika pengguna ini adalah yang berhak memiliki barangnya
              ? FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "KONFIRMASI PEMBAYARAN",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const Gap(5),
                                const Text(
                                  "Dengan menekan tombol bayar maka anda setuju untuk membayar barang ini",
                                  textAlign: TextAlign.center,
                                ),
                                const Gap(15),
                                TextFormField(
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                      label: Text("Nomor Telepon Gopay")),
                                  onChanged: (value) {
                                    setState(() {
                                      _phoneNumber = value;
                                    });
                                  },
                                ),
                                const Gap(15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: const ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.redAccent)),
                                      icon: const Icon(Icons.cancel),
                                      label: const Text("Nanti"),
                                    ),
                                    const Gap(10),
                                    FilledButton.icon(
                                      onPressed: payAuction,
                                      icon: const Icon(Icons.payments),
                                      label: const Text("Bayar"),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  tooltip: "Bayar barang ini",
                  child: const Icon(Icons.payments_rounded),
                )
              : null,
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        onRefresh: () => fetchAuction(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              clipBehavior: Clip.antiAlias,
              color: Colors.white,
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_images.isNotEmpty)
                                ..._images.map((url) => Image.network(
                                      url,
                                      width: MediaQuery.of(context).size.width -
                                          40,
                                      fit: BoxFit.fitWidth,
                                    ))
                              else
                                Image.asset(
                                  "images/placeholder.jpg",
                                  width: MediaQuery.of(context).size.width - 40,
                                  fit: BoxFit.fitWidth,
                                )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: (_active)
                            ? const Color.fromARGB(255, 103, 148, 142)
                            : Colors.redAccent,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              "LELANG ${_active ? 'AKAN' : 'TELAH'} BERAKHIR PADA ${DateFormat.yMd().add_Hms().format(_endsAt)}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      if (_paid && _winner) ...[
                        const Gap(10),
                        Column(children: const [
                          ListTile(
                            tileColor: Colors.greenAccent,
                            title: Text("Barang sudah dibayarkan"),
                            subtitle: Text(
                                "Silahkan ambil barang di lokasi pelelangan"),
                          ),
                        ])
                      ],
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _product,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(10),
                            Text(
                              _description,
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 350),
                          child: Card(
                            color: (_active) ? Colors.white : Colors.white24,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Colors.black, width: 3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Title
                                  Center(
                                    child: Text(
                                      _paid
                                          ? "PENAWARAN TERAKHIR"
                                          : "BUAT PENAWARAN BARU",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Gap(25),
                                  // Latest bid
                                  if (_lastBidNominal != null)
                                    ListTile(
                                      title: Text(_paid
                                          ? "Harga Barang"
                                          : "Penawaran Terbaru"),
                                      subtitle: Text(NumberFormat.currency(
                                              locale: "id-ID",
                                              name: "Rupiah",
                                              symbol: "Rp")
                                          .format(_lastBidNominal ?? 0)),
                                    )
                                  else
                                    ListTile(
                                      title: const Text("Harga Awal"),
                                      subtitle: Text(NumberFormat.currency(
                                              locale: "id-ID",
                                              name: "Rupiah",
                                              symbol: "Rp")
                                          .format(_startingPrice)),
                                    ),
                                  const Gap(10),
                                  TextFormField(
                                    // enabled: _active,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      label: Text("Masukan Penawaran anda"),
                                    ),
                                    validator: (value) {
                                      if (value == null) {
                                        return "Field harus diisi";
                                      }
                                      if (value.isEmpty) {
                                        return "Field harus diisi";
                                      }
                                      try {
                                        int.parse(value);
                                      } catch (e) {
                                        return "Field harus berisikan angka";
                                      }
                                      if (int.parse(value) < _minBidNominal) {
                                        return "Minimal penawaran ${NumberFormat.currency(locale: "id-ID", name: "Rupiah", symbol: "Rp").format(_minBidNominal)}";
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        try {
                                          _bidNominal = int.parse(value);
                                        } catch (e) {
                                          _formKey.currentState!.validate();
                                        }
                                      });
                                    },
                                  ),
                                  const Gap(20),
                                  FilledButton(
                                    onPressed: (_active) ? saveBid : null,
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text("SIMPAN PENAWARAN"),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
