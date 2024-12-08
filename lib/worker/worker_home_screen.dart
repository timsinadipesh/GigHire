// import 'package:flutter/material.dart';
//
// class WorkerHomeScreen extends StatelessWidget {
//   const WorkerHomeScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1A1A1A),
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildTitle(),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildSearchBar(),
//                       const SizedBox(height: 24),
//                       _buildCategoriesSection(),
//                       const SizedBox(height: 24),
//                       _buildPopularWorkersSection(),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             _buildBottomNavBar(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTitle() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//       child: const Text(
//         'GigHire',
//         style: TextStyle(
//           color: Color(0xFF4CAF50),
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Arial',
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
//
//   Widget _buildSearchBar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       height: 50,
//       decoration: BoxDecoration(
//         color: const Color(0xFF2A2A2A),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.search, color: Colors.grey[600]),
//           const SizedBox(width: 8),
//           Text(
//             'Search for services...',
//             style: TextStyle(color: Colors.grey[600], fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCategoriesSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Categories',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             _buildCategoryCard('Home Services'),
//             const SizedBox(width: 16),
//             _buildCategoryCard('Tech & IT'),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             _buildCategoryCard('Design & Creative'),
//             const SizedBox(width: 16),
//             _buildCategoryCard('Business'),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCategoryCard(String title) {
//     return Expanded(
//       child: Container(
//         height: 100,
//         decoration: BoxDecoration(
//           color: const Color(0xFF2A2A2A),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Center(
//           child: Text(
//             title,
//             textAlign: TextAlign.center,
//             style: const TextStyle(color: Colors.white, fontSize: 14),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPopularWorkersSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Popular Workers',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 16),
//         _buildWorkerCard(
//           name: 'John Smith',
//           profession: 'Web Developer',
//           rating: '4.9',
//           reviews: '120',
//         ),
//         const SizedBox(height: 16),
//         _buildWorkerCard(
//           name: 'Sarah Johnson',
//           profession: 'Graphic Designer',
//           rating: '4.8',
//           reviews: '95',
//         ),
//       ],
//     );
//   }
//
//   Widget _buildWorkerCard({
//     required String name,
//     required String profession,
//     required String rating,
//     required String reviews,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF2A2A2A),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: const Color(0xFF333333),
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   profession,
//                   style: TextStyle(
//                     color: Colors.grey[400],
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     const Icon(
//                       Icons.star,
//                       color: Color(0xFF4CAF50),
//                       size: 16,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       '$rating ($reviews reviews)',
//                       style: const TextStyle(
//                         color: Color(0xFF4CAF50),
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBottomNavBar() {
//     return Container(
//       height: 60,
//       color: const Color(0xFF2A2A2A),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildNavBarItem(Icons.home, 'Home', true),
//           _buildNavBarItem(Icons.search, 'Search', false),
//           _buildNavBarItem(Icons.person, 'Profile', false),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNavBarItem(IconData icon, String label, bool isSelected) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(
//           icon,
//           color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({Key? key}) : super(key: key);

  @override
  _WorkerHomeScreenState createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  // Add a state variable to track the current selected index
  int _selectedIndex = 0;

  // Method to handle bottom navigation item taps
  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Add navigation logic based on the selected index
    switch (index) {
      case 0:
      // Already on home screen, do nothing
        break;
      case 1:
      // Navigate to search screen
        Navigator.pushNamed(context, '/search');
        break;
      case 2:
      // Navigate to profile screen
        Navigator.pushNamed(context, '/worker_profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildTitle(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      _buildCategoriesSection(),
                      const SizedBox(height: 24),
                      _buildPopularWorkersSection(),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      color: const Color(0xFF2A2A2A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Pass the selected index to determine active state
          _buildNavBarItem(Icons.home, 'Home', _selectedIndex == 0, 0),
          _buildNavBarItem(Icons.search, 'Search', _selectedIndex == 1, 1),
          _buildNavBarItem(Icons.person, 'Profile', _selectedIndex == 2, 2),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => _onBottomNavItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: const Text(
        'GigHire',
        style: TextStyle(
          color: Color(0xFF4CAF50),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            'Search for services...',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildCategoryCard('Home Services'),
            const SizedBox(width: 16),
            _buildCategoryCard('Tech & IT'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildCategoryCard('Design & Creative'),
            const SizedBox(width: 16),
            _buildCategoryCard('Business'),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularWorkersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Workers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildWorkerCard(
          context: context,
          name: 'John Smith',
          profession: 'Web Developer',
          rating: '4.9',
          reviews: '120',
        ),
        const SizedBox(height: 16),
        _buildWorkerCard(
          context: context,
          name: 'Sarah Johnson',
          profession: 'Graphic Designer',
          rating: '4.8',
          reviews: '95',
        ),
      ],
    );
  }

  Widget _buildWorkerCard({
    required BuildContext context,
    required String name,
    required String profession,
    required String rating,
    required String reviews,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to worker profile screen
        Navigator.pushNamed(
            context,
            '/worker_profile',
            arguments: {
              'name': name,
              'profession': profession,
              'rating': rating,
              'reviews': reviews,
            }
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profession,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFF4CAF50),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$rating ($reviews reviews)',
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}