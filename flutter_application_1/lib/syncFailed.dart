import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poc_liste_de_courses/syncSucces.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'main.dart';

class SyncFailedPage extends StatefulWidget {
  const SyncFailedPage({super.key});

  @override
  _SyncFailedPageState createState() => _SyncFailedPageState();
}

class _SyncFailedPageState extends State<SyncFailedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: darkGreen), // Definir la couleur de la flèche de retour
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Oups,',
            style: TextStyle(
                color: red, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Quelque chose cloche...',
            style: TextStyle(color: red, fontSize: 18),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: red50,
                shape: BoxShape.circle,
                border: Border.all(
                  color: redFailed,
                  width: 20,
                ),
              ),
              child: const Icon(
                Icons.close,
                size: 100,
                color: Colors.white,
              ),
            ),
          )
        ],
      )),
      bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          color: const Color.fromRGBO(255, 255, 255, 1),
          child: Container(
              height: 90.0,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(1),
                    offset: const Offset(0, -40),
                    blurRadius: 20.0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () => {Navigator.of(context).pop()},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: red,
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          textStyle: const TextStyle(fontSize: 16.0),
                        ),
                        child: const Text("Réessayer"),
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }
}
