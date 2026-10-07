import os

filepath = "lib/src/features/profile/presentation/screens/profile_screen.dart"
with open(filepath, "r") as f:
    content = f.read()

# Add VIP badge to Profile screen username
old_username = """                  Text(
                    _profileData!['username'] ?? 'User',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),"""

new_username = """                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _profileData!['username'] ?? 'User',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      if (context.watch<AuthProvider>().isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('VIP', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ]
                    ],
                  ),"""

content = content.replace(old_username, new_username, 1)

with open(filepath, "w") as f:
    f.write(content)
