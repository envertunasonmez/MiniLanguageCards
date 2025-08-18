import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/word_cubit.dart';
import '../cubit/word_state.dart';
import '../widgets/carousel_3d.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text("Mini Language Cards")),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: BlocBuilder<WordCubit, WordState>(
          builder: (context, state) {
            if (state.dailyWords.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Carousel3D(items: state.dailyWords),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        minimumSize: const Size(200, 56),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () =>
                          context.read<WordCubit>().getRandomWords(),
                      icon: const Icon(Icons.refresh,
                          size: 24, color: Colors.white),
                      label: const Text('Yenile'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
