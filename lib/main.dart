import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Get person ID from build arguments (or default to 1)
  const personId = String.fromEnvironment('PERSON_ID', defaultValue: '1');
  
  // Load the specific config
  final config = await loadConfig(personId);
  
  runApp(MyApp(config: config));
}

Future<Map<String, dynamic>> loadConfig(String personId) async {
  final configString = await rootBundle.loadString('assets/config/config_$personId.json');
  return json.decode(configString);
}

class MyApp extends StatelessWidget {
  final Map<String, dynamic> config;
  
  const MyApp({Key? key, required this.config}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IEEE MACE Gift',
      theme: ThemeData(
        primaryColor: const Color(0xFF003B5C),
        fontFamily: 'Poppins',
      ),
      home: LoadingScreen(config: config),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoadingScreen extends StatefulWidget {
  final Map<String, dynamic> config;
  
  const LoadingScreen({Key? key, required this.config}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  ImageProvider? _photoImage;
  bool _isLoading = true;
  String? _error;

  bool _didLoad = false;

  @override
  void initState() {
    super.initState();
    // Do not call _loadData here!
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _didLoad = true;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      final photoAsset = widget.config['photo'] as String?;
      if (photoAsset == null || photoAsset.isEmpty) {
        throw Exception('Photo asset missing in config.');
      }
      final image = AssetImage(photoAsset);
      await precacheImage(image, context);
      setState(() {
        _photoImage = image;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: \n${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F3E6),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.width * 0.6,
            child: Lottie.asset(
              'assets/animations/gift_box.json',
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
        ),
      );
    } else if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F3E6),
        body: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return GiftScreen(
        photoImage: _photoImage!,
        name: widget.config['name'] as String? ?? '',
        bannerText: widget.config['bannerText'] as String? ?? '',
      );
    }
  }
}

// GiftScreen class remains the same as before...
class GiftScreen extends StatefulWidget {
  final ImageProvider photoImage;
  final String name;
  final String bannerText;

  const GiftScreen({
    Key? key,
    required this.photoImage,
    required this.name,
    required this.bannerText,
  }) : super(key: key);

  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> with SingleTickerProviderStateMixin {
  final List<HeartAnimation> _hearts = [];
  late AnimationController _controller;
  final Random _random = Random();
  
  // Banner color customization
  Color _bannerColor1 = const Color(0xFF808000);
  Color _bannerColor2 = const Color(0xFF808000);
  bool _useGradient = false;
  bool _showColorPicker = false;
  
  int _red1 = 128, _green1 = 128, _blue1 = 0;
  int _red2 = 128, _green2 = 128, _blue2 = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addListener(() {
      setState(() {});
    });
  }

  void _sendLove() {
    final int heartCount = 15 + _random.nextInt(10);
    for (int i = 0; i < heartCount; i++) {
      _hearts.add(HeartAnimation(
        startX: _random.nextDouble() * 200 - 100,
        startY: 0,
        duration: 1000 + _random.nextInt(500),
        size: 20 + _random.nextDouble() * 20,
      ));
    }
    _controller.forward(from: 0.0);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for being an amazing senior! 💙'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateBannerColor() {
    setState(() {
      _bannerColor1 = Color.fromRGBO(_red1, _green1, _blue1, 1);
      if (_useGradient) {
        _bannerColor2 = Color.fromRGBO(_red2, _green2, _blue2, 1);
      } else {
        _bannerColor2 = _bannerColor1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F3E6),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Large Rectangular Photo
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxHeight: 500),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image(
                              image: widget.photoImage,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Senior Name with Pacifico Font
                        Text(
                          widget.name,
                          style: GoogleFonts.pacifico(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF003B5C),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Banner with Color Picker
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: _useGradient
                                    ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [_bannerColor1, _bannerColor2],
                                      )
                                    : LinearGradient(
                                        colors: [_bannerColor1, _bannerColor1],
                                      ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: _buildBannerText(),
                              ),
                            ),
                            Positioned(
                              top: -12,
                              right: -12,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _showColorPicker = !_showColorPicker;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.palette,
                                      size: 24,
                                      color: Color(0xFF808000),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Send Love Button
                      // Send Love Button
                       ElevatedButton.icon(
                         onPressed: _sendLove,
                         icon: const Icon(Icons.favorite),
                         label: const Text('Send Love'),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: const Color(0xFFFFC857),
                           foregroundColor: const Color(0xFF003B5C),
                           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(30),
                             ),
                           ),
                        ), 
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Color Picker Dialog
          if (_showColorPicker)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showColorPicker = false;
                  });
                },
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Customize Banner Color',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            Row(
                              children: [
                                const Text('Use Gradient:'),
                                const SizedBox(width: 10),
                                Switch(
                                  value: _useGradient,
                                  onChanged: (value) {
                                    setState(() {
                                      _useGradient = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            Text(
                              _useGradient ? 'Color 1:' : 'Color:',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            _buildColorSlider(_red1, _green1, _blue1, (r, g, b) {
                              setState(() {
                                _red1 = r;
                                _green1 = g;
                                _blue1 = b;
                                _updateBannerColor();
                              });
                            }),
                            
                            if (_useGradient) ...[
                              const SizedBox(height: 20),
                              const Text(
                                'Color 2:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              _buildColorSlider(_red2, _green2, _blue2, (r, g, b) {
                                setState(() {
                                  _red2 = r;
                                  _green2 = g;
                                  _blue2 = b;
                                  _updateBannerColor();
                                });
                              }),
                            ],
                            
                            const SizedBox(height: 20),
                            
                            Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: _useGradient
                                    ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color.fromRGBO(_red1, _green1, _blue1, 1),
                                          Color.fromRGBO(_red2, _green2, _blue2, 1),
                                        ],
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Color.fromRGBO(_red1, _green1, _blue1, 1),
                                          Color.fromRGBO(_red1, _green1, _blue1, 1),
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showColorPicker = false;
                                });
                              },
                              child: const Text('Done'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          
          // Heart Animation Overlay
          if (_controller.isAnimating)
            ..._hearts.map((heart) => Positioned(
              left: MediaQuery.of(context).size.width / 2 - 50 + heart.startX,
              bottom: 100 + heart.startY,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: heart.duration),
                builder: (context, progress, child) {
                  final dy = -progress * 300;
                  final opacity = 1.0 - progress;
                  final scale = 0.5 + progress * 0.5;
                  return Opacity(
                    opacity: opacity,
                    child: Transform.translate(
                      offset: Offset(0, dy),
                      child: Transform.scale(
                        scale: scale,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: heart.size,
                        ),
                      ),
                    ),
                  );
                },
                onEnd: () {
                  setState(() {
                    _hearts.remove(heart);
                  });
                },
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildColorSlider(int red, int green, int blue, Function(int, int, int) onChanged) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            const Text('R:', style: TextStyle(color: Colors.red)),
            Expanded(
              child: Slider(
                value: red.toDouble(),
                min: 0,
                max: 255,
                onChanged: (value) {
                  onChanged(value.toInt(), green, blue);
                },
                activeColor: Colors.red,
              ),
            ),
            Text(red.toString()),
          ],
        ),
        Row(
          children: [
            const Text('G:', style: TextStyle(color: Colors.green)),
            Expanded(
              child: Slider(
                value: green.toDouble(),
                min: 0,
                max: 255,
                onChanged: (value) {
                  onChanged(red, value.toInt(), blue);
                },
                activeColor: Colors.green,
              ),
            ),
            Text(green.toString()),
          ],
        ),
        Row(
          children: [
            const Text('B:', style: TextStyle(color: Colors.blue)),
            Expanded(
              child: Slider(
                value: blue.toDouble(),
                min: 0,
                max: 255,
                onChanged: (value) {
                  onChanged(red, green, value.toInt());
                },
                activeColor: Colors.blue,
              ),
            ),
            Text(blue.toString()),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildBannerText() {
    final lines = widget.bannerText.split('\n');
    final List<Widget> widgets = [];
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }
      if (line.trim().contains("SYSTEM REBOOT") || line.contains("🎉")) {
        widgets.add(Text(
          line,
          style: GoogleFonts.pacifico(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ));
      } else {
        widgets.add(Text(
          line,
          style: GoogleFonts.quicksand(
            fontSize: 16,
            color: Colors.white,
            fontWeight: line.contains(':') ? FontWeight.w600 : FontWeight.normal,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ));
      }
      widgets.add(const SizedBox(height: 6));
    }
    return widgets;
  }
}

class HeartAnimation {
  final double startX;
  final double startY;
  final int duration;
  final double size;

  HeartAnimation({
    required this.startX,
    required this.startY,
    required this.duration,
    required this.size,
  });
}
 