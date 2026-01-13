# Feature: JSON Export for Tables and Query Results

## Metadata
issue_number: `2`
adw_id: `0390a27b`
issue_json: `{"number":2,"title":"add json export","body":"feature -adw_sdlc_iso- update to support table and query result 'json' export. similar to our csv export but specifically for json. export"}`

## Feature Description
This feature enables users to export table data and query results as JSON files with a single click, mirroring the existing CSV export functionality. Users can download entire database tables or current query results in JSON format for integration with web services, APIs, data pipelines, or modern data analysis workflows that prefer JSON over CSV.

## User Story
As a data analyst or developer
I want to export table data and query results as JSON files
So that I can integrate data with web services, APIs, and modern data processing tools that consume JSON

## Problem Statement
The application currently supports CSV export for tables and query results, which is useful for traditional data analysis tools. However, many modern applications, APIs, and data pipelines prefer JSON format due to its hierarchical structure, better type preservation, and native compatibility with web technologies. Users working with RESTful APIs, NoSQL databases, or JavaScript-based tools need a way to export data in JSON format directly from the application.

## Solution Statement
Implement JSON export functionality by extending the existing export infrastructure. We will create JSON generation utilities similar to the CSV export utilities, add new API endpoints for JSON export, integrate JSON export buttons into the UI alongside CSV export buttons, and provide comprehensive testing to ensure data integrity and proper handling of various data types in JSON format.

## Relevant Files
Use these files to implement the feature:

- `app/server/core/export_utils.py` - Contains CSV export utilities; will add JSON export functions here following the same pattern as `generate_csv_from_data()` and `generate_csv_from_table()`

- `app/server/core/data_models.py` - Contains ExportRequest and QueryExportRequest models; will add new models for JSON export requests if needed

- `app/server/server.py` - Contains `/api/export/table` and `/api/export/query` endpoints for CSV; will add new endpoints `/api/export/table-json` and `/api/export/query-json`

- `app/client/src/api/client.ts` - Contains `exportTable()` and `exportQueryResults()` API client methods; will add `exportTableJson()` and `exportQueryResultsJson()` methods

- `app/client/src/main.ts` - Contains download button UI logic for CSV export; will add JSON export buttons alongside existing CSV buttons

- `app/client/src/style.css` - Contains styling for export buttons; may need to add styling for JSON export buttons to differentiate them from CSV

- `app/server/tests/test_export_utils.py` - Contains comprehensive tests for CSV export; will add similar test coverage for JSON export functions

- `app/server/core/sql_security.py` - Contains security validation functions used by export endpoints; will use the same validation for JSON exports

- `README.md` - Project documentation; will reference for understanding architecture patterns

- `app_docs/feature-490eb6b5-one-click-table-exports.md` - Documentation of existing CSV export feature; will follow the same architectural patterns

### New Files

- `.claude/commands/e2e/test_json_export_functionality.md` - E2E test file for JSON export functionality, similar to `.claude/commands/e2e/test_export_functionality.md`

## Implementation Plan

### Phase 1: Foundation
Create JSON export utility functions in the backend following the same patterns as CSV export. This includes functions to convert database query results and table data to properly formatted JSON, ensuring correct handling of various data types (integers, floats, strings, nulls, dates) and special characters. The JSON output should be an array of objects where each object represents a row.

### Phase 2: Core Implementation
Add backend API endpoints for JSON export (`/api/export/table-json` and `/api/export/query-json`), implement client-side API methods to call these endpoints, and create UI buttons for JSON export alongside existing CSV buttons. The JSON export buttons should be clearly labeled and positioned consistently with the CSV export buttons.

### Phase 3: Integration
Integrate JSON export buttons into the Available Tables section and Query Results section, ensuring proper error handling and user feedback. Test the complete flow from UI button click to JSON file download, verify data integrity, and ensure the feature works seamlessly with existing functionality.

## Step by Step Tasks

### 1. Create JSON Export Utility Functions

- Read `app/server/core/export_utils.py` to understand the existing CSV export implementation
- Add `generate_json_from_data(data: List[Dict], columns: List[str]) -> bytes` function that:
  - Takes a list of dictionaries and column list as input
  - Converts data to JSON array format
  - Returns JSON as bytes encoded in UTF-8
  - Handles empty data gracefully
  - Preserves data types correctly (integers, floats, strings, booleans, null values)
- Add `generate_json_from_table(conn: sqlite3.Connection, table_name: str) -> bytes` function that:
  - Validates table exists in database
  - Queries all data from the specified table
  - Converts query results to JSON format
  - Returns JSON as bytes encoded in UTF-8
  - Raises ValueError if table doesn't exist

### 2. Add Backend API Endpoints for JSON Export

- Read `app/server/server.py` to understand existing export endpoints
- Import the new JSON export functions from `export_utils`
- Add `POST /api/export/table-json` endpoint that:
  - Accepts ExportRequest with table_name
  - Validates table name using `validate_identifier()`
  - Checks table exists using `check_table_exists()`
  - Generates JSON using `generate_json_from_table()`
  - Returns Response with `application/json` media type
  - Sets Content-Disposition header with filename `{table_name}_export.json`
  - Includes proper error handling and logging
- Add `POST /api/export/query-json` endpoint that:
  - Accepts QueryExportRequest with data and columns
  - Generates JSON using `generate_json_from_data()`
  - Returns Response with `application/json` media type
  - Sets Content-Disposition header with filename `query_results.json`
  - Includes proper error handling and logging

### 3. Create Comprehensive Unit Tests for JSON Export

- Read `app/server/tests/test_export_utils.py` to understand existing test patterns
- Add test class `TestJsonExportUtils` with the following test methods:
  - `test_generate_json_from_data_empty()` - Test with empty data
  - `test_generate_json_from_data_with_columns_no_data()` - Test with columns but no data
  - `test_generate_json_from_data_with_data()` - Test with actual data
  - `test_generate_json_from_data_various_types()` - Test integers, floats, strings, booleans, nulls
  - `test_generate_json_from_data_special_characters()` - Test with commas, quotes, newlines
  - `test_generate_json_from_data_unicode()` - Test with Unicode and emoji characters
  - `test_generate_json_from_table_nonexistent()` - Test with non-existent table
  - `test_generate_json_from_table_empty()` - Test with empty table
  - `test_generate_json_from_table_with_data()` - Test with table containing data
  - `test_generate_json_from_table_special_name()` - Test table with special characters in name
- Run tests to verify all pass: `cd app/server && uv run pytest tests/test_export_utils.py::TestJsonExportUtils -v`

### 4. Add Client-Side API Methods for JSON Export

- Read `app/client/src/api/client.ts` to understand existing export methods
- Add `exportTableJson(tableName: string): Promise<void>` method that:
  - Sends POST request to `/api/export/table-json`
  - Includes table_name in request body
  - Gets filename from Content-Disposition header
  - Downloads file as blob with `.json` extension
  - Handles errors appropriately
- Add `exportQueryResultsJson(data: any[], columns: string[]): Promise<void>` method that:
  - Sends POST request to `/api/export/query-json`
  - Includes data and columns in request body
  - Downloads file as `query_results.json`
  - Handles errors appropriately

### 5. Add JSON Export Buttons to UI

- Read `app/client/src/main.ts` to understand existing export button implementation
- In `displayTables()` function, add JSON export button next to CSV export button:
  - Position JSON button after CSV button in the buttons container
  - Label it with "📊 JSON" or similar icon/text
  - Set onclick handler to call `api.exportTableJson(table.name)`
  - Add title attribute: "Export table as JSON"
  - Apply appropriate CSS class for styling
- In `displayResults()` function, add JSON export button for query results:
  - Position JSON button in the results header buttons container
  - Label it with "📊 JSON" or similar icon/text
  - Set onclick handler to call `api.exportQueryResultsJson(response.results, response.columns)`
  - Add title attribute: "Export results as JSON"
  - Apply appropriate CSS class for styling

### 6. Add Styling for JSON Export Buttons

- Read `app/client/src/style.css` to understand existing export button styles
- Add or update styles to ensure JSON export buttons are visually consistent with CSV buttons
- Ensure proper spacing between CSV and JSON buttons
- Maintain responsive design and accessibility

### 7. Create E2E Test for JSON Export Functionality

- Read `.claude/commands/test_e2e.md` to understand E2E test execution framework
- Read `.claude/commands/e2e/test_export_functionality.md` as a reference for CSV export tests
- Create `.claude/commands/e2e/test_json_export_functionality.md` with:
  - User Story describing JSON export capability
  - Test Steps that validate:
    - JSON export button appears for tables
    - Clicking table JSON export downloads valid JSON file
    - JSON file contains correct table data in array format
    - JSON export button appears for query results
    - Clicking query results JSON export downloads valid JSON file
    - JSON file contains correct query results in array format
    - Empty results produce valid empty JSON array
  - Success Criteria covering all JSON export scenarios
  - Screenshots documenting JSON export buttons and functionality

### 8. Run Validation Commands

- Execute all validation commands listed in the Validation Commands section
- Verify zero regressions in existing functionality
- Verify JSON export works correctly end-to-end
- Fix any issues discovered during validation

## Testing Strategy

### Unit Tests

- Test `generate_json_from_data()` with empty data, data with columns, various data types (int, float, string, boolean, null), special characters, and Unicode
- Test `generate_json_from_table()` with non-existent table, empty table, table with data, and table with special characters in name
- Verify JSON output is valid and parseable
- Verify proper UTF-8 encoding
- Verify data types are preserved correctly in JSON
- Test error handling for invalid inputs

### Integration Tests

- Test API endpoints `/api/export/table-json` and `/api/export/query-json` with various inputs
- Verify proper HTTP headers (Content-Type, Content-Disposition)
- Verify security validation prevents SQL injection
- Test error responses for invalid table names and malformed requests

### Edge Cases

- Empty tables and empty query results
- Tables with single row or single column
- Large datasets (verify performance is acceptable)
- Special characters in table names, column names, and data values
- Unicode and emoji characters in data
- Null values and missing data
- Mixed data types in columns
- Tables and query results with deeply nested or complex column names
- Concurrent export requests

## Acceptance Criteria

- JSON export buttons appear next to CSV export buttons for all tables in the Available Tables section
- JSON export buttons appear in query results header next to CSV export button
- Clicking table JSON export button downloads a `.json` file named `{table_name}_export.json`
- Clicking query results JSON export button downloads a `.json` file named `query_results.json`
- Downloaded JSON files contain valid JSON in array-of-objects format
- JSON data accurately represents table or query result data with correct data types
- Empty tables and empty query results export as empty JSON arrays `[]`
- Special characters, Unicode, and emoji are properly encoded in JSON
- Null values are represented as JSON `null`
- Export functionality works without errors for datasets up to 100,000 rows
- All existing CSV export functionality continues to work without regression
- All unit tests pass with 100% coverage for new JSON functions
- E2E test validates JSON export functionality works end-to-end
- No console errors or warnings during JSON export operations
- Security validation prevents malicious table names from being exported

## Validation Commands

Execute every command to validate the feature works correctly with zero regressions.

- Read `.claude/commands/test_e2e.md`, then read and execute `.claude/commands/e2e/test_json_export_functionality.md` to validate JSON export functionality works end-to-end
- `cd app/server && uv run pytest tests/test_export_utils.py::TestJsonExportUtils -v` - Run JSON export unit tests to ensure all new functions work correctly
- `cd app/server && uv run pytest` - Run all server tests to validate zero regressions
- `cd app/client && bun tsc --noEmit` - Run TypeScript compiler to validate no type errors
- `cd app/client && bun run build` - Run frontend build to validate it compiles successfully

## Notes

- JSON export leverages Python's built-in `json` module, avoiding new external dependencies
- JSON format provides better type preservation compared to CSV (e.g., distinguishes between numbers and strings)
- JSON is ideal for integration with REST APIs, NoSQL databases, and JavaScript applications
- Future enhancements could include formatted/indented JSON for readability (add `indent=2` parameter)
- Consider adding export format selection dropdown in future iterations instead of separate buttons
- Large datasets should be tested for memory efficiency; JSON typically requires more memory than CSV
- The implementation mirrors the CSV export architecture for consistency and maintainability
