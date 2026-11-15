import 'package:flutter/material.dart';

void main() => runApp(const PetPalApp());

const Color petGreen = Color(0xFF52796F);

class PetPalApp extends StatelessWidget {
  const PetPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetPal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: petGreen),
        scaffoldBackgroundColor: const Color(0xFFF8FAF9),
        inputDecorationTheme:
            const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      home: const PetPalHome(),
    );
  }
}

// -------------------- MODELS --------------------

class Pet {
  String name, type, instructions;
  int age, count;

  Pet({
    required this.name,
    required this.type,
    required this.age,
    required this.count,
    required this.instructions,
  });
}

class Sitter {
  String name, petType, location, bio, experience, photo;
  double price, rating, distanceKm;
  List<String> acceptedPets;
  Set<String> availableDates;

  Sitter({
    required this.name,
    required this.petType,
    required this.price,
    required this.rating,
    required this.location,
    required this.distanceKm,
    this.bio = 'Friendly and reliable pet sitter.',
    this.experience = '2 years',
    this.photo = '',
    List<String>? acceptedPets,
    Set<String>? availableDates,
  })  : acceptedPets = acceptedPets ?? [petType],
        availableDates = availableDates ?? {};
}

class Booking {
  final String id;
  final Sitter sitter;
  final String date;
  final int days;
  final double total;
  String status;

  Booking({
    required this.id,
    required this.sitter,
    required this.date,
    required this.days,
    required this.total,
    this.status = 'Pending',
  });
}

// -------------------- MAIN APP --------------------

class PetPalHome extends StatefulWidget {
  const PetPalHome({super.key});

  @override
  State<PetPalHome> createState() => _PetPalHomeState();
}

class _PetPalHomeState extends State<PetPalHome> {
  int selectedTab = 0;
  String? currentUser;

  final List<Pet> pets = [];
  final List<Booking> bookings = [];

  // Demo data. distanceKm is a sample distance from the search reference point.
  final List<Sitter> sitters = [
    Sitter(
      name: 'Sara Ahmed',
      petType: 'Dogs',
      price: 80,
      rating: 4.9,
      location: 'Riyadh',
      distanceKm: 8,
      bio: 'Experienced dog sitter who enjoys outdoor walks.',
      experience: '4 years',
      acceptedPets: ['Dogs'],
    ),
    Sitter(
      name: 'Nora Ali',
      petType: 'Cats',
      price: 50,
      rating: 4.7,
      location: 'Riyadh',
      distanceKm: 15,
      bio: 'Caring cat sitter with flexible hours.',
      experience: '3 years',
      acceptedPets: ['Cats'],
    ),
    Sitter(
      name: 'Lama Saleh',
      petType: 'Dogs',
      price: 120,
      rating: 4.5,
      location: 'Jeddah',
      distanceKm: 75,
      bio: 'Professional pet care and daily updates.',
      experience: '5 years',
      acceptedPets: ['Dogs', 'Cats'],
    ),
    Sitter(
      name: 'Maha Omar',
      petType: 'Birds',
      price: 40,
      rating: 4.8,
      location: 'Riyadh',
      distanceKm: 28,
      bio: 'Special care for birds and small pets.',
      experience: '2 years',
      acceptedPets: ['Birds'],
    ),
    Sitter(
      name: 'Reem Khalid',
      petType: 'Cats',
      price: 90,
      rating: 4.2,
      location: 'Dammam',
      distanceKm: 90,
      bio: 'Calm home environment for cats.',
      experience: '3 years',
      acceptedPets: ['Cats'],
    ),
  ];

  String searchLocation = '';
  DateTime? searchDate;
  int searchDuration = 1;

  String filterType = 'All';
  double maxPrice = 200;
  double minRating = 0;
  double radius = 50;

  String dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void createBooking(Sitter sitter, DateTime date, int days) {
    final key = dateKey(date);

    if (sitter.availableDates.isNotEmpty &&
        !sitter.availableDates.contains(key)) {
      showMessage('This sitter is not available on the selected date.');
      return;
    }

    setState(() {
      bookings.add(
        Booking(
          id: 'B${bookings.length + 1}',
          sitter: sitter,
          date: key,
          days: days,
          total: sitter.price * days,
        ),
      );
      selectedTab = 3;
    });

    Navigator.pop(context);
    showMessage('Booking request created. Status: Pending.');
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return AuthPage(
        onLogin: (email) => setState(() => currentUser = email),
      );
    }

    final pages = [
      PetsPage(pets: pets, onChanged: () => setState(() {})),
      SearchPage(
        onSearch: (location, date, duration) {
          setState(() {
            searchLocation = location;
            searchDate = date;
            searchDuration = duration;
            selectedTab = 2;
          });
        },
      ),
      FiltersPage(
        sitters: sitters,
        location: searchLocation,
        type: filterType,
        maxPrice: maxPrice,
        minRating: minRating,
        radius: radius,
        selectedDate: searchDate,
        onFiltersChanged: (type, price, rating, distance) {
          setState(() {
            filterType = type;
            maxPrice = price;
            minRating = rating;
            radius = distance;
          });
        },
        onViewSitter: (sitter) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SitterDetailPage(
                sitter: sitter,
                onBook: (date, days) => createBooking(sitter, date, days),
              ),
            ),
          );
        },
      ),
      BookingsPage(
        bookings: bookings,
        onStatusChanged: () => setState(() {}),
      ),
      SitterManagementPage(
        sitters: sitters,
        bookings: bookings,
        onChanged: () => setState(() {}),
      ),
      AccountPage(
        email: currentUser!,
        onLogout: () => setState(() {
          currentUser = null;
          selectedTab = 0;
        }),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('PetPal',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: IndexedStack(index: selectedTab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) =>
            setState(() => selectedTab = index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.pets_outlined),
              selectedIcon: Icon(Icons.pets),
              label: 'My Pets'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Sitters'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month), label: 'Bookings'),
          NavigationDestination(
              icon: Icon(Icons.event_available), label: 'Sitter Tools'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }
}

// -------------------- AUTHENTICATION --------------------

class AuthPage extends StatefulWidget {
  final ValueChanged<String> onLogin;
  const AuthPage({super.key, required this.onLogin});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isRegister = false;
  bool hidePassword = true;
  final Map<String, String> demoAccounts = {};

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void message(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;

    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    if (isRegister) {
      if (demoAccounts.containsKey(email)) {
        message('This email is already registered.');
        return;
      }
      demoAccounts[email] = password;
      message('Demo account created.');
      widget.onLogin(email);
    } else {
      if (demoAccounts[email] != password) {
        message('Invalid email or password. Please register first.');
        return;
      }
      widget.onLogin(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.pets, size: 75, color: petGreen),
                const SizedBox(height: 12),
                const Text('PetPal',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(isRegister ? 'Create your account' : 'Welcome back!',
                    textAlign: TextAlign.center),
                const SizedBox(height: 28),
                if (isRegister) ...[
                  TextFormField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Full name'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Enter your name.' : null,
                  ),
                  const SizedBox(height: 14),
                ],
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) {
                    if (v == null ||
                        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(v.trim())) {
                      return 'Enter a valid email address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(hidePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => hidePassword = !hidePassword),
                    ),
                  ),
                  validator: (v) => v == null || v.length < 6
                      ? 'Password must contain at least 6 characters.'
                      : null,
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: submit,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(isRegister ? 'Create Account' : 'Log In'),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    isRegister = !isRegister;
                    formKey.currentState?.reset();
                  }),
                  child: Text(isRegister
                      ? 'Already have an account? Log in'
                      : 'New to PetPal? Create an account'),
                ),
                const Text(
                  'Demo authentication only. Accounts are kept in memory for this DartPad session.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------- PET MANAGEMENT --------------------

class PetsPage extends StatefulWidget {
  final List<Pet> pets;
  final VoidCallback onChanged;
  const PetsPage({super.key, required this.pets, required this.onChanged});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  void openPetForm({Pet? pet}) {
    final name = TextEditingController(text: pet?.name ?? '');
    final age = TextEditingController(text: pet?.age.toString() ?? '');
    final count = TextEditingController(text: pet?.count.toString() ?? '1');
    final notes =
        TextEditingController(text: pet?.instructions ?? '');
    String type = pet?.type ?? 'Dogs';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(pet == null ? 'Add Pet' : 'Edit Pet'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Pet name')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Pet type'),
                  items: ['Dogs', 'Cats', 'Birds', 'Other']
                      .map((v) =>
                          DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialog(() => type = v);
                  },
                ),
                TextField(
                    controller: age,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Age')),
                TextField(
                    controller: count,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Number of pets')),
                TextField(
                    controller: notes,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'Special care instructions')),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final a = int.tryParse(age.text);
                final c = int.tryParse(count.text);
                if (name.text.trim().isEmpty ||
                    a == null ||
                    a < 0 ||
                    c == null ||
                    c < 1) {
                  return;
                }
                setState(() {
                  if (pet == null) {
                    widget.pets.add(Pet(
                      name: name.text.trim(),
                      type: type,
                      age: a,
                      count: c,
                      instructions: notes.text.trim(),
                    ));
                  } else {
                    pet.name = name.text.trim();
                    pet.type = type;
                    pet.age = a;
                    pet.count = c;
                    pet.instructions = notes.text.trim();
                  }
                });
                widget.onChanged();
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('My Pets',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Add and manage your pet information.'),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => openPetForm(),
            icon: const Icon(Icons.add),
            label: const Text('Add a Pet'),
          ),
          if (widget.pets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Text('No pets added yet.', textAlign: TextAlign.center),
            ),
          ...widget.pets.map(
            (pet) => Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.pets)),
                title: Text(pet.name),
                subtitle: Text(
                    '${pet.type} • Age: ${pet.age} • Count: ${pet.count}\n${pet.instructions}'),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') openPetForm(pet: pet);
                    if (v == 'delete') {
                      setState(() => widget.pets.remove(pet));
                      widget.onChanged();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
}

// -------------------- SITTER SEARCH --------------------

class SearchPage extends StatefulWidget {
  final void Function(String, DateTime, int) onSearch;
  const SearchPage({super.key, required this.onSearch});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final locationController = TextEditingController();
  final durationController = TextEditingController(text: '1');
  DateTime? selectedDate;

  @override
  void dispose() {
    locationController.dispose();
    durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Find a Pet Sitter',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Search by location, care date, and duration.'),
          const SizedBox(height: 20),
          TextField(
            controller: locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.location_on_outlined),
              hintText: 'e.g. Riyadh',
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) setState(() => selectedDate = date);
            },
            icon: const Icon(Icons.calendar_month),
            label: Text(selectedDate == null
                ? 'Select care date'
                : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: durationController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Duration (days)'),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () {
              final days = int.tryParse(durationController.text);
              if (locationController.text.trim().isEmpty ||
                  selectedDate == null ||
                  days == null ||
                  days < 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Enter a location, care date, and valid duration.')),
                );
                return;
              }
              widget.onSearch(
                  locationController.text.trim(), selectedDate!, days);
            },
            icon: const Icon(Icons.search),
            label: const Text('Search Sitters'),
          ),
        ],
      );
}

// -------------------- FILTERS + SITTER PROFILE VIEW --------------------

class FiltersPage extends StatelessWidget {
  final List<Sitter> sitters;
  final String location, type;
  final double maxPrice, minRating, radius;
  final DateTime? selectedDate;
  final void Function(String, double, double, double) onFiltersChanged;
  final ValueChanged<Sitter> onViewSitter;

  const FiltersPage({
    super.key,
    required this.sitters,
    required this.location,
    required this.type,
    required this.maxPrice,
    required this.minRating,
    required this.radius,
    required this.selectedDate,
    required this.onFiltersChanged,
    required this.onViewSitter,
  });

  @override
  Widget build(BuildContext context) {
    final dateString = selectedDate == null
        ? null
        : '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';

    final results = sitters.where((s) {
      final matchesType = type == 'All' || s.acceptedPets.contains(type);
      final matchesPrice = s.price <= maxPrice;
      final matchesRating = s.rating >= minRating;
      final matchesLocation = location.isEmpty ||
          s.location.toLowerCase().contains(location.toLowerCase());
      final matchesRadius = s.distanceKm <= radius;
      final matchesDate = dateString == null ||
          s.availableDates.isEmpty ||
          s.availableDates.contains(dateString);
      return matchesType &&
          matchesPrice &&
          matchesRating &&
          matchesLocation &&
          matchesRadius &&
          matchesDate;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Filter Pet Sitters',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        if (location.isNotEmpty) Text('Search location: $location'),
        if (selectedDate != null)
          Text('Care date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: type,
          decoration: const InputDecoration(labelText: 'Pet type'),
          items: ['All', 'Dogs', 'Cats', 'Birds', 'Other']
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              onFiltersChanged(v, maxPrice, minRating, radius);
            }
          },
        ),
        const SizedBox(height: 14),
        Text('Maximum price: ${maxPrice.toInt()} SAR/day'),
        Slider(
          value: maxPrice,
          min: 0,
          max: 200,
          divisions: 20,
          onChanged: (v) =>
              onFiltersChanged(type, v, minRating, radius),
        ),
        Text('Minimum rating: ${minRating.toStringAsFixed(1)}'),
        Slider(
          value: minRating,
          min: 0,
          max: 5,
          divisions: 10,
          onChanged: (v) =>
              onFiltersChanged(type, maxPrice, v, radius),
        ),
        Text('Location radius: ${radius.toInt()} km'),
        Slider(
          value: radius,
          min: 5,
          max: 100,
          divisions: 19,
          onChanged: (v) =>
              onFiltersChanged(type, maxPrice, minRating, v),
        ),
        OutlinedButton.icon(
          onPressed: () => onFiltersChanged('All', 200, 0, 100),
          icon: const Icon(Icons.refresh),
          label: const Text('Clear All Filters'),
        ),
        const Divider(height: 30),
        Text('Available Sitters (${results.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ...results.map(
          (s) => Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(s.name),
              subtitle: Text(
                  '${s.acceptedPets.join(', ')} • ${s.location}\nRating: ${s.rating}/5 • ${s.distanceKm.toInt()} km away'),
              isThreeLine: true,
              trailing: Text('${s.price.toInt()} SAR/day'),
              onTap: () => onViewSitter(s),
            ),
          ),
        ),
        if (results.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('No sitters match your filters.',
                textAlign: TextAlign.center),
          ),
        const Text(
          'Radius uses sample distance values for this prototype. Connect real sitter coordinates/location data for production distance calculations.',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

class SitterDetailPage extends StatelessWidget {
  final Sitter sitter;
  final void Function(DateTime, int) onBook;

  const SitterDetailPage(
      {super.key, required this.sitter, required this.onBook});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Sitter Profile')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            CircleAvatar(
              radius: 42,
              backgroundImage:
                  sitter.photo.trim().isNotEmpty ? NetworkImage(sitter.photo) : null,
              child: sitter.photo.trim().isEmpty
                  ? const Icon(Icons.person, size: 44)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(sitter.name,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('${sitter.location} • ${sitter.rating}/5',
                textAlign: TextAlign.center),
            const SizedBox(height: 18),
            _detail('Bio', sitter.bio),
            _detail('Experience', sitter.experience),
            _detail('Accepted pet types', sitter.acceptedPets.join(', ')),
            _detail('Daily price', '${sitter.price.toInt()} SAR'),
            _detail('Location', '${sitter.location} • ${sitter.distanceKm.toInt()} km'),
            _detail(
              'Available dates',
              sitter.availableDates.isEmpty
                  ? 'No dates configured. Ask the sitter to set availability.'
                  : sitter.availableDates.join(', '),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date == null) return;

                final daysController = TextEditingController(text: '1');
                final days = await showDialog<int>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Booking duration'),
                    content: TextField(
                      controller: daysController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Number of days'),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel')),
                      FilledButton(
                        onPressed: () => Navigator.pop(
                            ctx, int.tryParse(daysController.text)),
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                );
                if (days != null && days > 0) onBook(date, days);
              },
              icon: const Icon(Icons.event_available),
              label: const Text('Book this Sitter'),
            ),
          ],
        ),
      );

  Widget _detail(String title, String value) => Card(
        child: ListTile(title: Text(title), subtitle: Text(value)),
      );
}

// -------------------- BOOKING LIST --------------------

class BookingsPage extends StatelessWidget {
  final List<Booking> bookings;
  final VoidCallback onStatusChanged;

  const BookingsPage({
    super.key,
    required this.bookings,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('My Bookings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('View booking requests and their current status.'),
          if (bookings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Text('No bookings yet.', textAlign: TextAlign.center),
            ),
          ...bookings.map(
            (b) => Card(
              child: ListTile(
                leading: const CircleAvatar(
                    child: Icon(Icons.calendar_month)),
                title: Text('${b.sitter.name} • ${b.id}'),
                subtitle: Text(
                    'Date: ${b.date}\nDuration: ${b.days} day(s)\nTotal: ${b.total.toInt()} SAR\nStatus: ${b.status}'),
                isThreeLine: true,
              ),
            ),
          ),
        ],
      );
}

// -------------------- SITTER MANAGEMENT + REQUEST ACTIONS --------------------

class SitterManagementPage extends StatefulWidget {
  final List<Sitter> sitters;
  final List<Booking> bookings;
  final VoidCallback onChanged;

  const SitterManagementPage({
    super.key,
    required this.sitters,
    required this.bookings,
    required this.onChanged,
  });

  @override
  State<SitterManagementPage> createState() => _SitterManagementPageState();
}

class _SitterManagementPageState extends State<SitterManagementPage> {
  Sitter? selectedSitter;

  @override
  void initState() {
    super.initState();
    selectedSitter = widget.sitters.first;
  }

  @override
  Widget build(BuildContext context) {
    final sitter = selectedSitter!;
    final bioController = TextEditingController(text: sitter.bio);
    final experienceController =
        TextEditingController(text: sitter.experience);
    final priceController =
        TextEditingController(text: sitter.price.toInt().toString());
    final acceptedPetsController =
        TextEditingController(text: sitter.acceptedPets.join(', '));
    final photoController = TextEditingController(text: sitter.photo);

    final sitterBookings =
        widget.bookings.where((b) => b.sitter == sitter).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Sitter Tools',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Text('Manage sitter profile, availability, and booking requests.'),
        const SizedBox(height: 12),
        DropdownButtonFormField<Sitter>(
          value: sitter,
          decoration: const InputDecoration(labelText: 'Select sitter'),
          items: widget.sitters
              .map((s) =>
                  DropdownMenuItem(value: s, child: Text(s.name)))
              .toList(),
          onChanged: (s) {
            if (s != null) setState(() => selectedSitter = s);
          },
        ),
        const SizedBox(height: 18),
        const Text('Edit Sitter Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextField(
            controller: bioController,
            decoration: const InputDecoration(labelText: 'Bio')),
        const SizedBox(height: 8),
        TextField(
            controller: experienceController,
            decoration: const InputDecoration(labelText: 'Experience')),
        const SizedBox(height: 8),
        TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Daily price (SAR)')),
        const SizedBox(height: 8),
        TextField(
          controller: acceptedPetsController,
          decoration: const InputDecoration(
            labelText: 'Accepted pet types (comma separated)',
            hintText: 'Dogs, Cats, Birds',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: photoController,
          decoration: const InputDecoration(
            labelText: 'Profile photo URL (optional)',
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () {
            final price = double.tryParse(priceController.text);
            if (price == null || price < 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter a valid price.')),
              );
              return;
            }
            setState(() {
              sitter.bio = bioController.text.trim();
              sitter.experience = experienceController.text.trim();
              sitter.price = price;
              sitter.acceptedPets = acceptedPetsController.text
                  .split(',')
                  .map((v) => v.trim())
                  .where((v) => v.isNotEmpty)
                  .toList();
              sitter.photo = photoController.text.trim();
            });
            widget.onChanged();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sitter profile updated.')),
            );
          },
          child: const Text('Save Profile'),
        ),
        const Divider(height: 30),
        const Text('Availability Calendar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text('Select a date to mark it available or unavailable.'),
        FilledButton.tonalIcon(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date == null) return;
            final key =
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            setState(() {
              if (sitter.availableDates.contains(key)) {
                sitter.availableDates.remove(key);
              } else {
                sitter.availableDates.add(key);
              }
            });
            widget.onChanged();
          },
          icon: const Icon(Icons.calendar_month),
          label: const Text('Toggle availability for a date'),
        ),
        if (sitter.availableDates.isEmpty)
          const Text('No availability dates set yet.')
        else
          Wrap(
            spacing: 6,
            children: sitter.availableDates
                .map((d) => Chip(label: Text(d)))
                .toList(),
          ),
        const Divider(height: 30),
        const Text('Incoming Booking Requests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (sitterBookings.isEmpty)
          const Text('No booking requests for this sitter yet.'),
        ...sitterBookings.map(
          (booking) => Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Request ${booking.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Date: ${booking.date} • ${booking.days} day(s)'),
                  Text('Total: ${booking.total.toInt()} SAR'),
                  Text('Status: ${booking.status}'),
                  if (booking.status == 'Pending')
                    Wrap(
                      spacing: 8,
                      children: [
                        FilledButton(
                          onPressed: () {
                            setState(() => booking.status = 'Accepted');
                            widget.onChanged();
                          },
                          child: const Text('Accept'),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            setState(() => booking.status = 'Declined');
                            widget.onChanged();
                          },
                          child: const Text('Decline'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Prototype note: profile, availability, and booking data are stored in memory in this DartPad version.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

// -------------------- ACCOUNT --------------------

class AccountPage extends StatelessWidget {
  final String email;
  final VoidCallback onLogout;

  const AccountPage(
      {super.key, required this.email, required this.onLogout});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                  radius: 40, child: Icon(Icons.person, size: 42)),
              const SizedBox(height: 16),
              const Text('My Account',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(email),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
              ),
            ],
          ),
        ),
      );
}
