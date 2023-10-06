import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:to_do/app/features/authentication/presentation/authentication_screen.dart';

class AuthenticationRepositoryImpl {
  late Database _database;
  final String _tableName = 'users';

  Future<void> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'todo_database.db');
    _database = await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        username TEXT,
        email TEXT PRIMARY KEY,
        password TEXT
      )
    ''');
  }

  Future<bool> authenticateUser(String email, String password) async {
    try {
      // Query the user by email only
      final user = await _database.query(
        _tableName,
        where: 'email = ?',
        whereArgs: [email],
      );

      // Check if the user exists and the password matches
      return user.isNotEmpty && user[0]['password'] == password;
    } catch (e) {
      // Handle any errors that occur during querying the database
      Get.snackbar(
        'Error',
        'Error authenticating user! $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> registerUser(
      String username, String email, String password) async {
    try {
      final user = await _database.query(
        _tableName,
        where: 'email = ?',
        whereArgs: [email],
      );

      if (user.isNotEmpty) {
        // User with the same email already exists.

        Get.snackbar(
          'Error',
          'User with this email already exists.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      } else {
        // User does not exist, proceed with registration.
        await _database.insert(
          _tableName,
          {
            'username': username,
            'email': email,
            'password': password,
          },
        );

        Get.snackbar(
          'Success',
          'User registered successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
    } catch (e) {
      // Handle any errors that occur during registration.
      Get.snackbar(
        'Error',
        'Error registering user!',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<void> signOut() async {
    Get.to(const AuthenticationScreen());
  }

  Future<void> closeDatabase() async {
    await _database.close();
  }
}
