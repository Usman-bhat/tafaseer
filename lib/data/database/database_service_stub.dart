// Stub for web - no actual database functions needed
// Web uses WebDataService with JSON files instead

// Define a stub type that matches what database_service.dart expects
typedef Database = void;

Future<void> initializeDatabases() async {
  // No-op on web
}
