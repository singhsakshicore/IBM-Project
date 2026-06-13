import 'package:flutter/material.dart';

void main() {
  runApp(const PhishingDetectorApp());
}

class PhishingDetectorApp extends StatelessWidget {
  const PhishingDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Phishing Detector',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050B12),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController urlController = TextEditingController();

  String riskLevel = "";
  int riskScore = 0;
  int trustScore = 100;
  List<String> reasons = [];
  List<String> history = [];

  void scanUrl() {
    String input = urlController.text.trim();

    if (input.isEmpty) {
      return;
    }

    String url = input.toLowerCase();

    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      url = "https://$url";
    }

    Uri? uri = Uri.tryParse(url);

    if (uri == null || uri.host.isEmpty) {
      setState(() {
        riskLevel = "INVALID URL";
        riskScore = 100;
        trustScore = 0;
        reasons = ["Invalid website URL"];
      });
      return;
    }

    int score = 0;
    List<String> warnings = [];
    List<String> passedChecks = [];

    // HTTPS
    if (!url.startsWith("https://")) {
      score += 15;
      warnings.add("No HTTPS encryption");
    } else {
      passedChecks.add("HTTPS enabled");
    }

    // URL length
    if (url.length > 80) {
      score += 10;
      warnings.add("Very long URL");
    } else {
      passedChecks.add("Normal URL length");
    }

    // @ symbol
    if (url.contains("@")) {
      score += 25;
      warnings.add("@ symbol detected");
    }

    // Too many subdomains
    int dots = ".".allMatches(uri.host).length;

    if (dots > 3) {
      score += 20;
      warnings.add("Too many subdomains");
    } else {
      passedChecks.add("Normal domain structure");
    }

    // Suspicious TLDs
    List<String> suspiciousTlds = [
      ".xyz",
      ".top",
      ".click",
      ".tk",
      ".gq",
      ".cf",
    ];

    for (String tld in suspiciousTlds) {
      if (uri.host.endsWith(tld)) {
        score += 20;
        warnings.add("Suspicious domain extension");
      }
    }

    // URL shorteners
    List<String> shorteners = ["bit.ly", "tinyurl.com", "t.co", "shorturl.at"];

    for (String s in shorteners) {
      if (uri.host.contains(s)) {
        score += 20;
        warnings.add("Shortened URL detected");
      }
    }

    // Suspicious keywords
    List<String> keywords = [
      "login",
      "verify",
      "secure",
      "bank",
      "account",
      "update",
      "signin",
      "wallet",
      "payment",
      "otp",
    ];

    for (String word in keywords) {
      if (url.contains(word)) {
        score += 8;
        warnings.add("Keyword detected: $word");
      }
    }

    // Brand impersonation
    List<String> brands = [
      "google",
      "facebook",
      "instagram",
      "amazon",
      "paypal",
      "microsoft",
      "apple",
      "netflix",
    ];

    for (String brand in brands) {
      if (url.contains(brand) && !uri.host.contains(brand)) {
        score += 25;
        warnings.add("Possible $brand impersonation");
      }
    }

    score = score.clamp(0, 100);

    String risk;

    if (score <= 20) {
      risk = "SAFE";
    } else if (score <= 50) {
      risk = "MEDIUM RISK";
    } else {
      risk = "HIGH RISK";
    }

    int trust = 100 - score;

    List<String> allMessages = [
      ...passedChecks.map((e) => "✓ $e"),
      ...warnings.map((e) => "⚠ $e"),
    ];

    setState(() {
      riskLevel = risk;
      riskScore = score;
      trustScore = trust;
      reasons = allMessages;

      history.insert(0, "${uri.host}  •  $risk");

      if (history.length > 10) {
        history.removeLast();
      }
    });

    urlController.clear();
  }

  Color getRiskColor() {
    if (riskScore <= 20) {
      return Colors.green;
    }

    if (riskScore <= 50) {
      return Colors.orange;
    }

    return Colors.red;
  }

  IconData getRiskIcon() {
    if (riskScore <= 20) {
      return Icons.verified_user;
    }

    if (riskScore <= 50) {
      return Icons.warning_amber;
    }

    return Icons.dangerous;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.security, color: Color(0xFF00FF9D)),
            SizedBox(width: 10),
            Text(
              "SMART PHISHING DETECTOR",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: getRiskColor().withOpacity(0.6),
                    blurRadius: 35,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(getRiskIcon(), size: 90, color: getRiskColor()),
            ),
            const SizedBox(height: 15),

            const Text(
              "AI POWERED THREAT ANALYSIS",
              style: TextStyle(
                color: Colors.cyanAccent,
                letterSpacing: 3,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "SYSTEM STATUS : SECURE",
              style: TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: urlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Scan website URL...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.link, color: Color(0xFF00FF9D)),
                filled: true,
                fillColor: const Color(0xFF101820),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Color(0xFF00FF9D)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color(0xFF00D9FF),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FF9D), Color(0xFF00D9FF)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: scanUrl,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.radar, color: Colors.black),
                    SizedBox(width: 10),
                    Text(
                      "INITIATE SCAN",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (riskLevel.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF101820),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: getRiskColor(), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: getRiskColor().withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      riskLevel,
                      style: TextStyle(
                        color: getRiskColor(),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "THREAT SCORE : $riskScore%",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "TRUST SCORE : $trustScore%",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 15),

            Expanded(
              child: ListView(
                children: [
                  if (reasons.isNotEmpty) ...[
                    const Text(
                      "Analysis",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ...reasons.map(
                      (e) => Card(
                        color: const Color(0xFF101820),
                        elevation: 8,
                        shadowColor: Colors.greenAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(e),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  if (history.isNotEmpty) ...[
                    const Text(
                      "Recent Scans",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ...history.map(
                      (e) => Card(
                        color: const Color(0xFF101820),
                        elevation: 6,
                        shadowColor: Colors.cyanAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(e),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
