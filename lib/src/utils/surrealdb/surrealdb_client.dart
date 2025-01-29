import 'package:surrealdb/surrealdb.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DB {
  String? _dbUrl;
  String? _username;
  String? _password;
  String? _database;
  String? _namespace;
  Future<void> _loadEnvVars() async {
    _dbUrl = dotenv.env['SURREALDB_URL'];
    _username = dotenv.env['SURREALDB_USERNAME'];
    _password = dotenv.env['SURREALDB_PASSWORD'];
    _namespace = dotenv.env['SURREALDB_NAMESPACE'];
    _database = dotenv.env['SURREALDB_DATABASE'];
  }

  static final DB _instance = DB._internal();
  SurrealDB? _db;

  factory DB() {
    return _instance;
  }

  DB._internal();

  /// Initialize the database connection
  Future<String> initialize() async {
    try {
      // Ensure required environment variables are set
      await _loadEnvVars();
      if (_dbUrl == null ||
          _username == null ||
          _password == null ||
          _namespace == null ||
          _database == null) {
        return "Missing one or more required environment variables:\n"
            "SURREALDB_URL: $_dbUrl\n"
            "SURREALDB_USERNAME: $_username\n"
            "SURREALDB_PASSWORD: $_password\n"
            "SURREALDB_NAMESPACE: $_namespace\n"
            "SURREALDB_DATABASE: $_database";
      }

      // Initialize the database connection only if it's null
      if (_db == null) {
        _db = SurrealDB("wss://$_dbUrl/rpc");
        _db!.connect();
        await _db!.wait();

        // Sign in to the database
        final token = await _db!.signin(
          user: _username,
          pass: _password,
        );
        // Authenticate using the retrieved token
        await _db!.authenticate(token);

        await _db!.query("USE NS $_namespace; USE DB $_database");
      }
      return "Database initialized successfully";
    } catch (e) {
      return e.toString(); // Rethrow the exception for higher-level handling
    }
  }

  /// Close the database connection
  void close() {
    try {
      _db?.close();
      _db = null; // Reset _db so it can be re-initialized if needed
    } catch (e) {
      print("Failed to close the database connection: $e");
    }
  }

  /// Execute a query on the database
  Future<dynamic> query({
    required String query,
    Map<String, Object?>? vars,
  }) async {
    int tries = 0;
    while (tries < 3) {
      // prepend the query with "USE NS $_namespace; USE DB $_database;"
      query = "USE NS $_namespace; USE DB $_database; $query";
      try {
        // Ensure the database is initialized
        if (_db == null) {
          await initialize(); // Initialize it if it's not already
        }
      } catch (e) {
        return "Initializing database failed: ${e.toString()}";
      }

      try {
        return await _db!.query(query, vars);
      } catch (e) {
        if (tries < 3) {
          _db!.close();
          // wait tries * 500ms
          await Future.delayed(Duration(milliseconds: 500 * tries));
          _db = null;
          await initialize();
          tries++;
        }
      }
    }
  }
}

void main() async {
  try {
    await dotenv.load();
    final dbClient = DB();

    // Initialize the database
    await dbClient.initialize();

    // Perform database operations
    final response = await dbClient
        .query(query: 'SELECT * FROM test', vars: {'param': 'value'});
    print('Query response: $response');

    // Close the database
    dbClient.close();
  } catch (e) {
    print("An error occurred: $e");
  }
}
