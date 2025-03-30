import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperAboutScreen extends StatelessWidget {
  const DeveloperAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Developer> developers = [
      Developer(
        name: 'Yash Mistry',
        role: 'Mobile/Web App Developer, Backend-Developer',
        imageUrl:
        'https://media.licdn.com/dms/image/D4D35AQEVAWpDQoRMww/profile-framedphoto-shrink_400_400/0/1680425150164?e=1704556800&v=beta&t=16uTFdDAw_d-uW_DqFxUQfql9Tq8-QBkKDLWx2t3KX0',
        links: [
          DeveloperLink(
              icon: Icons.code, label: 'GitHub', value: 'yash240408', url: 'https://github.com/yash240408'),
          DeveloperLink(
              icon: Icons.connect_without_contact_rounded,
              label: 'LinkedIn',
              value: 'Yash Mistry',
              url: 'https://linkedin.com/in/yashmistry24'),
          DeveloperLink(
              icon: Icons.email_rounded,
              label: 'Email',
              value: 'Mail Developer',
              url: 'mailto:yash.mistry.g43@gmail.com'),
        ],
      ),
      Developer(
        name: 'Jinendra Gundigara',
        role: 'Flutter Application Developer',
        imageUrl:
        'https://media.licdn.com/dms/image/D4D03AQFVh4TuhZWkTQ/profile-displayphoto-shrink_200_200/0/1684759464666?e=2147483647&v=beta&t=J_Od5h1hBEJfArjxY1Gqcyyebx6lro4ZMjJkjK6TBfk',
        links: [
          DeveloperLink(
              icon: Icons.code, label: 'GitHub', value: 'IT-jin9920', url: 'https://github.com/IT-jin9920'),
          DeveloperLink(
              icon: Icons.connect_without_contact_rounded,
              label: 'LinkedIn',
              value: 'Jinendra Gundigara',
              url: 'https://linkedin.com/in/jinendra-flutter'),
          DeveloperLink(
              icon: Icons.email_rounded,
              label: 'Email',
              value: 'Mail Developer',
              url: 'mailto:jinendra9920h@gmail.com'),
          DeveloperLink(
              icon: Icons.travel_explore,
              label: 'LinkTree',
              value: 'linktr.ee/jinendra.link',
              url: 'https://linktr.ee/jinendra.link'),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Developers'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.deepPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: developers.length,
          itemBuilder: (context, index) {
            final developer = developers[index];
            return _buildDeveloperCard(developer);
          },
        ),
      ),
    );
  }

  Widget _buildDeveloperCard(Developer developer) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(developer.imageUrl),
            ),
            const SizedBox(height: 16),
            Text(
              developer.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              developer.role,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...developer.links.map((link) => _buildInfoRow(link)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(DeveloperLink link) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunchUrl(Uri.parse(link.url))) {
          launchUrl(Uri.parse(link.url));
        } else {
          debugPrint("Can't launch ${link.url}");
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(link.icon, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              '${link.label}: ',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              link.value,
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

class Developer {
  final String name;
  final String role;
  final String imageUrl;
  final List<DeveloperLink> links;

  Developer({
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.links,
  });
}

class DeveloperLink {
  final IconData icon;
  final String label;
  final String value;
  final String url;

  DeveloperLink({
    required this.icon,
    required this.label,
    required this.value,
    required this.url,
  });
}
