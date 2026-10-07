import os

filepath = "lib/providers/auth_provider.dart"
with open(filepath, "r") as f:
    content = f.read()

# Add _subscriptionTier
old_vars = """  String? _token;
  double _balance = 0.0;"""
new_vars = """  String? _token;
  double _balance = 0.0;
  String _subscriptionTier = "FREE";"""
content = content.replace(old_vars, new_vars, 1)

# Add getter
old_getters = """  String? get token => _token;
  double get balance => _balance;
  bool get isAuthenticated => _token != null;"""
new_getters = """  String? get token => _token;
  double get balance => _balance;
  bool get isAuthenticated => _token != null;
  String get subscriptionTier => _subscriptionTier;
  bool get isPremium => _subscriptionTier == "PREMIUM";"""
content = content.replace(old_getters, new_getters, 1)

# Add to fetchMyProfile
old_fetch = """        final data = json.decode(response.body);
        _balance = (data['balance'] as num).toDouble();
        notifyListeners();"""
new_fetch = """        final data = json.decode(response.body);
        _balance = (data['balance'] as num).toDouble();
        _subscriptionTier = data['subscription_tier'] ?? "FREE";
        notifyListeners();"""
content = content.replace(old_fetch, new_fetch, 1)

with open(filepath, "w") as f:
    f.write(content)
