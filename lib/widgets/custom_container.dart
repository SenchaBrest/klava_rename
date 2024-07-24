import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows),
            label: 'Other',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.speed),
            label: 'Velocity',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return const Tab1();
              case 1:
                return const Tab2();
              default:
                return const Center(child: Text('Unknown tab'));
            }
          },
        );
      },
    );
  }
}

class Tab1 extends StatelessWidget {
  const Tab1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black38,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton1(),
            const SizedBox(height: 3,),
            CustomButton2(),
            const SizedBox(height: 3,),
            CustomButton3(),
            const SizedBox(height: 3,),
            CustomButton4(),
            const SizedBox(height: 3,),
            CustomButton5(),
            const SizedBox(height: 3,),
            CustomButton6(),
          ],
        )
      );
  }
}

class Tab2 extends StatelessWidget {
  const Tab2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black38,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomButton7(),
          const SizedBox(height: 3,),
          CustomButton8(),
          const SizedBox(height: 3,),
          CustomButton9(),
          const SizedBox(height: 3,),
          CustomButton10(),
          const SizedBox(height: 3,),
          CustomButton11(),
        ],
      ),
    );
  }
}

class CustomButton1 extends StatelessWidget {
  const CustomButton1({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 40,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        color: Colors.white,
        child: Row(
          children: [
            Text('Red', style: TextStyle(color: Colors.red)),
            Text('Green', style: TextStyle(color: Colors.green)),
          ],
        ),
        onPressed: () {},
      )
    );
  }
}

class CustomButton2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: Colors.white,
      child: Row(
        children: [
          Text('Red', style: TextStyle(color: Colors.red)),
          Text('Green', style: TextStyle(color: Colors.green)),
        ],
      ),
      onPressed: () {},
    );
  }
}

class CustomButton3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: Colors.white,
      child: Row(
        children: [
          Text('Red', style: TextStyle(color: Colors.red)),
          Text('Green', style: TextStyle(color: Colors.green)),
        ],
      ),
      onPressed: () {},
    );
  }
}

class CustomButton4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: Colors.white,
      child: Row(
        children: [
          Text('Red', style: TextStyle(color: Colors.red)),
          Text('Green', style: TextStyle(color: Colors.green)),
        ],
      ),
      onPressed: () {},
    );
  }
}

class CustomButton5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: Colors.white,
      child: Row(
        children: [
          Text('Red', style: TextStyle(color: Colors.red)),
          Text('Green', style: TextStyle(color: Colors.green)),
        ],
      ),
      onPressed: () {},
    );
  }
}

class CustomButton6 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: Colors.white,
      child: Row(
        children: [
          Text('Red', style: TextStyle(color: Colors.red)),
          Text('Green', style: TextStyle(color: Colors.green)),
        ],
      ),
      onPressed: () {},
    );
  }
}

class CustomButton7 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: Colors.white,
      child: Row(
        children: [
          Text('Red', style: TextStyle(color: Colors.red)),
          Text('Green', style: TextStyle(color: Colors.green)),
        ],
      ),
      onPressed: () {},
    );
  }
}

class CustomButton8 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: Colors.white,
      child: Row(
        children: [
          Text('Red', style: TextStyle(color: Colors.red)),
          Text('Green', style: TextStyle(color: Colors.green)),
        ],
      ),
      onPressed: () {},
    );
  }
}

class CustomButton9 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: Colors.white,
      child: Row(
        children: [
          Text('Red', style: TextStyle(color: Colors.red)),
          Text('Green', style: TextStyle(color: Colors.green)),
        ],
      ),
      onPressed: () {},
    );
  }
}

class CustomButton10 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: Colors.white,
      child: Row(
        children: [
          Text('Red', style: TextStyle(color: Colors.red)),
          Text('Green', style: TextStyle(color: Colors.green)),
        ],
      ),
      onPressed: () {},
    );
  }
}

class CustomButton11 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: Colors.white,
      child: Row(
        children: [
          Text('Red', style: TextStyle(color: Colors.red)),
          Text('Green', style: TextStyle(color: Colors.green)),
        ],
      ),
      onPressed: () {},
    );
  }
}
