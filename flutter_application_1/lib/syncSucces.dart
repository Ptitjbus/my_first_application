import 'package:flutter/material.dart';
import 'main.dart';

class SyncSuccessPage extends StatefulWidget {
  const SyncSuccessPage({super.key});

  @override
  _SyncSuccessPageState createState() => _SyncSuccessPageState();
}

class _SyncSuccessPageState extends State<SyncSuccessPage> {
  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: darkGreen,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: darkGreen), // Definir la couleur de la flèche de retour
            onPressed: () {},
          ),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Félicitations !',
              style: TextStyle(
                  color: green, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Vos courses ont bien été synchronisées !',
              style: TextStyle(color: green, fontSize: 18),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: greenSuccess,
                    width: 20,
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  size: 100,
                  color: white,
                ),
              ),
            )
          ],
        )),
        bottomNavigationBar: CustomPaint(
          size: Size(MediaQuery.of(context).size.width,
              90), // Specify the size of the BottomAppBar
          painter: BNBCustomPainter(green),
          child: BottomAppBar(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              color: Colors.transparent,
              child: Container(
                height: 90.0,
                child: Column(
                  children: [
                    FractionallySizedBox(
                      widthFactor: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            //return to home
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ProductList()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkGreen,
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            textStyle: const TextStyle(fontSize: 16.0),
                          ),
                          child: const Text("Revenir à l'écran principal"),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }
}

class BNBCustomPainter extends CustomPainter {
  final Color backgroundColor;

  BNBCustomPainter(this.backgroundColor);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    Path path = Path()
      ..moveTo(0, 20) // Start the path at the left bottom of the canvas
      ..quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0)
      ..quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20)
      ..arcToPoint(Offset(size.width * 0.60, 20), radius: Radius.circular(20.0))
      ..quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0)
      ..quadraticBezierTo(size.width * 0.80, 0, size.width, 20)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
