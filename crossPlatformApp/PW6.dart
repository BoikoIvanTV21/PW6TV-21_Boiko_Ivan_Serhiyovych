import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const StandardDarkApp());
}

class StandardDarkApp extends StatelessWidget {
  const StandardDarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Power Load Calculator',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.cyanAccent,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final tcPhShlif = TextEditingController(text: "20");
  final tcKvPolir = TextEditingController(text: "0.2");
  final tcTgCirk = TextEditingController(text: "1.52");

  String outShr1 = "";
  String outTotal = "";

  double parseVal(String s) => double.tryParse(s) ?? 0.0;

  void executeCalc() {
    double phShlif = parseVal(tcPhShlif.text);
    double kvPolir = parseVal(tcKvPolir.text);
    double tgCirk = parseVal(tcTgCirk.text);

    double sumPhShr1 = 4 * phShlif + 2 * 14 + 4 * 42 + 1 * 36 + 1 * 20 + 1 * 40 + 2 * 32 + 1 * 20;
    double sumPhKvShr1 = 4 * phShlif * 0.15 + 2 * 14 * 0.12 + 4 * 42 * 0.15 + 1 * 36 * 0.3 + 1 * 20 * 0.5 + 1 * 40 * kvPolir + 2 * 32 * 0.2 + 1 * 20 * 0.65;
    double sumPhKvTgShr1 = 4 * phShlif * 0.15 * 1.33 + 2 * 14 * 0.12 * 1.0 + 4 * 42 * 0.15 * 1.33 + 1 * 36 * 0.3 * tgCirk + 1 * 20 * 0.5 * 0.75 + 1 * 40 * kvPolir * 1.0 + 2 * 32 * 0.2 * 1.0 + 1 * 20 * 0.65 * 0.75;
    double sumPh2Shr1 = 4 * (phShlif * phShlif) + 2 * 196 + 4 * 1764 + 1 * 1296 + 1 * 400 + 1 * 1600 + 2 * 1024 + 1 * 400;

    double kvShr1 = sumPhKvShr1 / sumPhShr1;
    double neShr1 = (sumPhShr1 * sumPhShr1) / sumPh2Shr1;
    double kpShr1 = 1.25; 
    double ppShr1 = kpShr1 * sumPhKvShr1;
    double qpShr1 = 1.0 * sumPhKvTgShr1;
    double spShr1 = sqrt(ppShr1 * ppShr1 + qpShr1 * qpShr1);
    double ipShr1 = ppShr1 / 0.38;

    double sumPhTotal = 3 * sumPhShr1 + 440 + 522;
    double sumPhKvTotal = 3 * sumPhKvShr1 + 232 + 234.52;
    double sumPhKvTgTotal = 3 * sumPhKvTgShr1 + 120 + 215.094;
    double sumPh2Total = 3 * sumPh2Shr1 + 48800 + 3212;

    double kvTotal = sumPhKvTotal / sumPhTotal;
    double neTotal = (sumPhTotal * sumPhTotal) / sumPh2Total;
    double kpTotal = 0.7; 
    double ppTotal = kpTotal * sumPhKvTotal;
    double qpTotal = kpTotal * sumPhKvTgTotal;
    double spTotal = sqrt(ppTotal * ppTotal + qpTotal * qpTotal);
    double ipTotal = ppTotal / 0.38;

    setState(() {
      outShr1 = "Кв: ${kvShr1.toStringAsFixed(4)}\n"
          "n_e: ${neShr1.toStringAsFixed(0)}\n"
          "Кр: ${kpShr1.toStringAsFixed(2)}\n"
          "Рр: ${ppShr1.toStringAsFixed(2)} кВт\n"
          "Qp: ${qpShr1.toStringAsFixed(2)} квар\n"
          "Sp: ${spShr1.toStringAsFixed(2)} кВ*А\n"
          "Ip: ${ipShr1.toStringAsFixed(2)} А";

      outTotal = "Кв (цех): ${kvTotal.toStringAsFixed(4)}\n"
          "n_e (цех): ${neTotal.toStringAsFixed(0)}\n"
          "Кр (цех): ${kpTotal.toStringAsFixed(2)}\n"
          "Рр (ТП): ${ppTotal.toStringAsFixed(2)} кВт\n"
          "Qp (ТП): ${qpTotal.toStringAsFixed(2)} квар\n"
          "Sp (ТП): ${spTotal.toStringAsFixed(2)} кВ*А\n"
          "Ip (ТП): ${ipTotal.toStringAsFixed(2)} А";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Електричні навантаження"),
        elevation: 0,
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Вхідні дані (Варіант)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    const SizedBox(height: 15),
                    TextField(
                      controller: tcPhShlif,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Рн (Шліф. верстат), кВт",
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: tcKvPolir,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Кв (Полір. верстат)",
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: tcTgCirk,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "tg φ (Циркулярна пила)",
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: executeCalc,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("ОБЧИСЛИТИ", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            if (outShr1.isNotEmpty) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ШР1 (Розподільча шина 1)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                      const Divider(color: Colors.white24, height: 20),
                      Text(outShr1, style: const TextStyle(height: 1.5, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ТП (Цех в цілому)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                      const Divider(color: Colors.white24, height: 20),
                      Text(outTotal, style: const TextStyle(height: 1.5, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}