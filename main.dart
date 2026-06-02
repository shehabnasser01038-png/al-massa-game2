import 'package:flutter/material.dart';

void main() {
  runApp(const AlMassaGame());
}

class AlMassaGame extends StatelessWidget {
  const AlMassaGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final int rows = 5;
  final int columns = 5;

  int currentLevel = 1; // المرحلة الحالية
  bool isLaserActive = false;
  bool hasWon = false;

  // إحداثيات الليزر والماسة لكل مرحلة
  late int laserRow;
  late int laserCol;
  late int diamondRow;
  late int diamondCol;

  // خريطة الاتجاهات: 0 = يمين (➡️), 1 = تحت (⬇️), 2 = شمال (⬅️), 3 = فوق (⬆️)
  Map<String, int> mirrors = {};
  List<String> laserPath = [];

  @override
  void initState() {
    super.initState();
    loadLevel(currentLevel);
  }

  // تحميل بيانات المرحلة
  void loadLevel(int level) {
    mirrors.clear();
    laserPath.clear();
    isLaserActive = false;
    hasWon = false;

    if (level == 1) {
      laserRow = 0; laserCol = 0;
      diamondRow = 4; diamondCol = 4;
    } else if (level == 2) {
      laserRow = 0; laserCol = 2;
      diamondRow = 4; diamondCol = 0;
    } else { // المرحلة 3 الأصعب
      laserRow = 2; laserCol = 0;
      diamondRow = 2; diamondCol = 4;
    }

    // توليد أسهم باتجاهات عشوائية (من 0 لـ 3) في كل المربعات
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if ((r == laserRow && c == laserCol) || (r == diamondRow && c == diamondCol)) {
          continue;
        }
        mirrors["$r,$c"] = (r * c + level) % 4; 
      }
    }
  }

  void calculateLaser() {
    laserPath.clear();
    hasWon = false;

    int currentRow = laserRow;
    int currentCol = laserCol;
    
    // اتجاه البداية التلقائي حسب المرحلة
    int currentDir = (currentLevel == 2) ? 1 : 0; 

    laserPath.add("$currentRow,$currentCol");

    int steps = 0;
    while (steps < 60) {
      steps++;

      if (currentDir == 0) currentCol++;
      else if (currentDir == 1) currentRow++;
      else if (currentDir == 2) currentCol--;
      else if (currentDir == 3) currentRow--;

      if (currentRow < 0 || currentRow >= rows || currentCol < 0 || currentCol >= columns) {
        break;
      }

      laserPath.add("$currentRow,$currentCol");

      if (currentRow == diamondRow && currentCol == diamondCol) {
        hasWon = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showWinDialog();
        });
        break;
      }

      String key = "$currentRow,$currentCol";
      if (mirrors.containsKey(key)) {
        // السهم بيجبر الليزر يمشي في اتجاه السهم بالظبط!
        currentDir = mirrors[key]!;
      }
    }
  }

  void showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            currentLevel < 3 ? "🎉 كفو يا وحش! 🎉" : "👑 ملك اللعبة الأسطوري 👑", 
            textDirection: TextDirection.rtl, 
            style: const TextStyle(color: Colors.cyanAccent)
          ),
          content: Text(
            currentLevel < 3 
              ? "قفلت المرحلة $currentLevel بنجاح! جاهز للمرحلة اللي بعدها؟ 🚀" 
              : "أنت بطل حقيقي! قفلت كل مراحل لعبة الماسّة بالكامل! 💎⚡", 
            textDirection: TextDirection.rtl
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  if (currentLevel < 3) {
                    currentLevel++;
                    loadLevel(currentLevel);
                  } else {
                    currentLevel = 1; // إعادة اللعبة من الأول
                    loadLevel(currentLevel);
                  }
                });
              },
              child: Text(
                currentLevel < 3 ? "المرحلة التالية ➡️" : "إعادة اللعبة بالكامل 🔄", 
                style: const TextStyle(color: Colors.greenAccent, fontSize: 16)
              ),
            ),
          ],
        );
      },
    );
  }

  // دالة لإظهار السهم المناسب بناءً على الرقم (0-3)
  String getArrowSign(int dir) {
    if (dir == 0) return "➡️";
    if (dir == 1) return "⬇️";
    if (dir == 2) return "⬅️";
    return "⬆️";
  }

  @override
  Widget build(BuildContext context) {
    if (isLaserActive) {
      calculateLaser();
    } else {
      laserPath.clear();
      hasWon = false;
    }

    return Scaffold(
      backgroundColor: Colors.grey[950],
      appBar: AppBar(
        title: Text('لعبة الماسّة - مرحلة $currentLevel', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber),
            onPressed: () {
              setState(() {
                loadLevel(currentLevel);
              });
            },
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "المهمة: اضبط الأسهم لتوجه الليزر ⚡ للماسّة 💎",
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: rows * columns,
              itemBuilder: (context, index) {
                int r = index ~/ columns;
                int c = index % columns;
                String key = "$r,$c";

                bool isLaserOnCell = laserPath.contains(key);
                Widget item = const SizedBox.shrink();

                if (r == laserRow && c == laserCol) {
                  item = Icon(Icons.bolt, color: isLaserActive ? Colors.redAccent : Colors.grey, size: 35);
                } else if (r == diamondRow && c == diamondCol) {
                  item = Icon(Icons.diamond, color: hasWon && isLaserActive ? Colors.greenAccent : Colors.amber, size: 35);
                } else if (mirrors.containsKey(key)) {
                  item = Text(
                    getArrowSign(mirrors[key]!),
                    style: TextStyle(
                      color: isLaserOnCell && isLaserActive ? Colors.redAccent : Colors.cyanAccent, 
                      fontSize: 24, 
                      fontWeight: FontWeight.bold
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    if (!isLaserActive && mirrors.containsKey(key)) {
                      setState(() {
                        // لف السهم باتجاه عقارب الساعة (0 -> 1 -> 2 -> 3 -> 0)
                        mirrors[key] = (mirrors[key]! + 1) % 4;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      border: Border.all(
                        color: isLaserOnCell && isLaserActive 
                            ? Colors.red 
                            : (mirrors.containsKey(key) ? Colors.cyan.withOpacity(0.4) : Colors.cyan.withOpacity(0.1))
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: item),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isLaserActive ? Colors.red : Colors.cyanAccent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: () {
              setState(() {
                isLaserActive = !isLaserActive;
              });
            },
            child: Text(
              isLaserActive ? "إيقاف الليزر" : "إطلق الليزر ⚡",
              style: TextStyle(fontSize: 18, color: isLaserActive ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

