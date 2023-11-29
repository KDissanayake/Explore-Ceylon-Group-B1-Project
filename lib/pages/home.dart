import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../widgets/search.dart';
import 'package:newproject/models.dart';

class Home extends StatelessWidget {
  Home({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MyAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 30),
          const SearchBarComponent(),
          const SizedBox(height: 40),
          const Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, right: 215, top: 20),
                child: Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(top: 40),
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Container(
                  width: 200,
                  margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 185, 132, 132),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Adventure",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Container(
                  width: 200,
                  margin: const EdgeInsets.only(left: 1, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 134, 160, 179),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Camping",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Container(
                  width: 200,
                  margin: const EdgeInsets.only(left: 1, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 182, 174, 123),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Hotels",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Container(
                  width: 200,
                  margin: const EdgeInsets.only(left: 1, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 84, 193, 137),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Beaches",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Container(
                  width: 200,
                  margin: const EdgeInsets.only(left: 1, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 213, 244, 130),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Gems/\nJewellery",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Column(
            children: [
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 13),
                      child: Text(
                        "Places to visit",
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
          Container(
            color: Colors.black12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
          )
        ],
      ),
    );
  }
}
