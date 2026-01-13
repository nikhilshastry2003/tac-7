# Feature: JSON Export Support

## Metadata
issue_number: `6`
adw_id: `da3a30ce`
issue_json: `{"number":6,"title":"update json export","body":"adw_sdlc_iso update to support table and query result 'json export', similar to csv export, but this is specifically for json export."}`

## Feature Description
This feature adds JSON export functionality for database tables and query results, mirroring the existing CSV export capabilities. Users will be able to export data in JSON format with a single click, providing an alternative to CSV exports that is better suited for structured data interchange, web applications, and API integration scenarios.

The feature will provide parallel functionality to the existing CSV export system (feature-490eb6b5-one-click-table-exports), allowing users to choose between CSV or JSON formats based on their use case.

## User Story
As a data analyst or developer
I want to export table data and query results as JSON files with one click
So that I can integrate data with web applications, APIs, and modern data pipelines that prefer JSON format over CSV

## Problem Statement
Currently, the application only supports CSV export for tables and query results. While CSV is suitable for spreadsheet applications and simple data exchange, many modern workflows require JSON format for:
- Direct consumption by web applications and REST APIs
- Preservation of data type information (numbers, booleans, null values)
- Nested or structured data representation
- Integration with JavaScript/TypeScript applications
- API development and testing workflows

Users working with modern data pipelines need a native JSON export option alongside the existing CSV functionality.

## Solution Statement
Extend the existing export infrastructure to support JSON format by:
1. Creating JSON generation utilities parallel to CSV utilities (generate_json_from_data, generate_json_from_table)
2. Adding new API endpoints (/api/export/table-json and /api/export/query-json) that return JSON files
3. Adding JSON download buttons in the UI alongside existing CSV export buttons
4. Maintaining the same security validation and error handling patterns as CSV exports
5. Ensuring consistent user experience with download button placement and behavior

The implementation will leverage Python's built-in json module and follow the established patterns from the CSV export feature to ensure maintainability and consistency.

## Relevant Files
Use these files to implement the feature:

- **app/server/core/export_utils.py** - Contains CSV export utilities; will be extended with JSON export functions (generate_json_from_data, generate_json_from_table)
- **app/server/core/data_models.py** - Contains ExportRequest and QueryExportRequest models; may need JsonExportRequest models if different from CSV
- **app/server/server.py** - Contains /api/export/table and /api/export/query endpoints; will add parallel JSON endpoints
- **app/client/src/api/client.ts** - Contains exportTable and exportQueryResults API methods; will add exportTableJson and exportQueryResultsJson methods
- **app/client/src/main.ts** - Contains CSV download button logic; will add JSON download buttons with similar functionality
- **app/client/src/style.css** - Contains styling for export buttons; may need additional styles for JSON export buttons
- **app/server/tests/test_export_utils.py** - Contains comprehensive unit tests for CSV exports; will be extended with JSON export tests
- **app_docs/feature-490eb6b5-one-click-table-exports.md** - Reference documentation for CSV export feature implementation patterns
- **.claude/commands/test_e2e.md** - E2E test runner instructions for executing E2E tests
- **.claude/commands/e2e/test_basic_query.md** - Example E2E test structure for understanding test patterns
- **.claude/commands/e2e/test_export_functionality.md** - Existing CSV export E2E tests; will inform JSON export E2E tests

### New Files

- **.claude/commands/e2e/test_json_export_functionality.md** - New E2E test file for validating JSON export functionality
- **app_docs/feature-da3a30ce-json-export.md** - Feature documentation describing JSON export implementation

## Implementation Plan

### Phase 1: Foundation
Create the core JSON export utilities in the server-side codebase by extending the existing export_utils.py module. This includes:
- JSON generation functions that convert Python data structures to properly formatted JSON
- Database table to JSON conversion with proper type handling
- Security validation integration using existing validate_identifier and check_table_exists functions
- Error handling for edge cases (empty data, invalid tables, encoding issues)

### Phase 2: Core Implementation
Implement the API endpoints and client-side functionality:
- Backend API endpoints (/api/export/table-json, /api/export/query-json) following the same patterns as CSV exports
- Client API methods (exportTableJson, exportQueryResultsJson) with blob download handling
- UI components: JSON download buttons positioned consistently with CSV buttons
- File naming conventions (tablename_export.json, query_results.json)
- Comprehensive unit tests for all JSON export utilities

### Phase 3: Integration
Integrate JSON exports into the application workflow and validate:
- E2E tests to validate end-to-end JSON export functionality
- Visual consistency with existing export buttons
- Error handling and user feedback
- Documentation of the feature for future reference
- Full validation suite to ensure zero regressions

## Step by Step Tasks

### Task 1: Create JSON Export Utilities
- Add `generate_json_from_data(data: List[Dict], columns: List[str]) -> bytes` function to app/server/core/export_utils.py
- Add `generate_json_from_table(conn: sqlite3.Connection, table_name: str) -> bytes` function to app/server/core/export_utils.py
- Ensure proper encoding (UTF-8), indentation for readability, and type preservation
- Handle edge cases: empty data, missing columns, special characters, Unicode
- Follow the same security patterns as CSV exports

### Task 2: Extend Data Models
- Review app/server/core/data_models.py to determine if new models are needed
- If ExportRequest and QueryExportRequest are sufficient, reuse them
- Otherwise, add JsonExportRequest and JsonQueryExportRequest models
- Ensure models support JSON-specific requirements if any

### Task 3: Add Server API Endpoints
- Add POST /api/export/table-json endpoint to app/server/server.py
- Add POST /api/export/query-json endpoint to app/server/server.py
- Implement security validation using validate_identifier and check_table_exists
- Set appropriate Content-Type (application/json) and Content-Disposition headers
- Handle errors consistently with existing endpoints
- Test endpoints manually using curl or Postman

### Task 4: Create Unit Tests for JSON Export
- Add test cases to app/server/tests/test_export_utils.py for JSON export functions
- Test empty data, various data types (int, float, string, bool, null), Unicode, special characters
- Test table export with non-existent tables, empty tables, tables with data
- Test edge cases: large datasets, nested structures if supported, special table names
- Ensure 100% code coverage for new JSON export functions

### Task 5: Add Client-Side API Methods
- Add exportTableJson(tableName: string): Promise<void> to app/client/src/api/client.ts
- Add exportQueryResultsJson(data: any[], columns: string[]): Promise<void> to app/client/src/api/client.ts
- Implement blob download with proper Content-Type handling
- Use filename patterns: {tableName}_export.json and query_results.json
- Handle errors and provide user feedback

### Task 6: Add JSON Download Buttons to UI
- Add JSON download buttons to table items in app/client/src/main.ts
- Add JSON download buttons to query results section in app/client/src/main.ts
- Position buttons consistently with CSV export buttons (may use icon or text differentiation)
- Consider using button groups or separate buttons with clear labeling (e.g., "JSON" vs "CSV")
- Implement click handlers that call exportTableJson and exportQueryResultsJson
- Add loading states and error handling

### Task 7: Style JSON Export Buttons
- Add or update styles in app/client/src/style.css for JSON export buttons
- Ensure visual consistency with existing export buttons
- Differentiate JSON buttons from CSV buttons (via text, icon, or color)
- Maintain responsive design and accessibility

### Task 8: Create E2E Test for JSON Export
- Create .claude/commands/e2e/test_json_export_functionality.md
- Base the structure on test_export_functionality.md
- Include test steps for:
  - Uploading a test file
  - Verifying JSON download buttons appear for tables
  - Clicking JSON download button and verifying JSON file is downloaded
  - Executing a query and verifying JSON download button appears for results
  - Clicking JSON download button and verifying query_results.json is downloaded
  - Validating downloaded JSON files contain correct data and proper formatting
  - Testing empty results produce valid empty JSON arrays
- Include 4-5 screenshots capturing key states
- Define clear success criteria

### Task 9: Run Unit Tests and Fix Issues
- Execute `cd app/server && uv run pytest tests/test_export_utils.py -v`
- Verify all JSON export tests pass
- Fix any failing tests or implementation issues
- Ensure zero regressions in existing CSV export tests

### Task 10: Run Frontend Type Check and Build
- Execute `cd app/client && bun tsc --noEmit`
- Fix any TypeScript errors
- Execute `cd app/client && bun run build`
- Verify build succeeds without errors

### Task 11: Execute E2E Test for JSON Export
- Read .claude/commands/test_e2e.md to understand E2E execution process
- Execute the new .claude/commands/e2e/test_json_export_functionality.md test
- Verify all test steps pass
- Capture screenshots and save to appropriate directory
- Fix any issues discovered during E2E testing

### Task 12: Create Feature Documentation
- Create app_docs/feature-da3a30ce-json-export.md
- Document the JSON export feature with:
  - Overview and screenshots
  - What was built (files modified, key changes)
  - How to use (exporting tables and query results as JSON)
  - Technical implementation details
  - Testing instructions
  - Notes on JSON format, encoding, and use cases

### Task 13: Final Validation
- Run all validation commands to ensure zero regressions
- Verify CSV export still works correctly
- Verify JSON export works for tables and query results
- Confirm UI is intuitive and buttons are clearly labeled
- Ensure all tests pass and application builds successfully

## Testing Strategy

### Unit Tests
- **JSON Generation from Data**: Test generate_json_from_data with empty data, various data types, Unicode, special characters, nested structures
- **JSON Generation from Table**: Test generate_json_from_table with non-existent tables, empty tables, tables with data, special table names
- **Data Type Preservation**: Verify integers, floats, strings, booleans, and null values are correctly represented in JSON
- **Error Handling**: Test error cases such as invalid table names, database connection failures, encoding errors
- **Edge Cases**: Large datasets, special characters in data, Unicode characters, empty results

### E2E Tests
- **Table JSON Export**: Upload a CSV, verify JSON download button appears, click button, verify JSON file downloads with correct data
- **Query Results JSON Export**: Execute a query, verify JSON download button appears, click button, verify query_results.json downloads with correct data
- **Empty Results**: Execute a query returning no results, verify JSON export produces valid empty array
- **Multiple Tables**: Upload multiple tables, verify each has its own JSON export button
- **JSON Format Validation**: Verify downloaded JSON is valid, properly formatted, and contains expected data structure

### Edge Cases
- Empty tables export as empty JSON arrays with proper structure
- Tables with special characters in names are sanitized for filenames
- Unicode and emoji characters are properly encoded in JSON
- Large datasets (up to 100,000 rows) export successfully
- Concurrent exports don't interfere with each other
- Network failures during download are handled gracefully

## Acceptance Criteria
- Users can export any database table as a JSON file by clicking a JSON export button
- Users can export query results as a JSON file by clicking a JSON export button
- JSON export buttons are visually distinct from CSV export buttons and clearly labeled
- Downloaded JSON files follow naming convention: {table_name}_export.json for tables, query_results.json for query results
- JSON files are properly formatted with indentation for human readability
- JSON files preserve data types (numbers remain numbers, booleans remain booleans, nulls remain null)
- Empty tables/results export as valid empty JSON arrays: []
- All unit tests pass with 100% coverage of JSON export functions
- E2E tests validate JSON export functionality end-to-end
- CSV export functionality remains unchanged and fully functional (zero regressions)
- Frontend build completes without TypeScript errors
- Backend tests complete without errors
- Feature documentation is complete and accurate

## Validation Commands
Execute every command to validate the feature works correctly with zero regressions.

- Read `.claude/commands/test_e2e.md`, then read and execute `.claude/commands/e2e/test_json_export_functionality.md` to validate JSON export functionality works end-to-end
- `cd app/server && uv run pytest` - Run server tests to validate the feature works with zero regressions
- `cd app/client && bun tsc --noEmit` - Run frontend tests to validate the feature works with zero regressions
- `cd app/client && bun run build` - Run frontend build to validate the feature works with zero regressions

## Notes

### Technical Considerations
- **JSON Format**: Use Python's json.dumps() with indent=2 for readable output
- **Data Type Preservation**: JSON natively supports integers, floats, strings, booleans, and null (unlike CSV which converts everything to strings)
- **Character Encoding**: Always use UTF-8 encoding for JSON files to support international characters
- **MIME Type**: Use application/json for Content-Type header
- **File Extension**: Use .json extension for all exported files
- **Security**: Leverage existing validate_identifier and check_table_exists security functions to prevent SQL injection

### Dependencies
- No new external dependencies required (Python's built-in json module will be used)
- Pandas is not needed for JSON export (unlike CSV which uses pandas)

### Future Enhancements
- Add option to export as JSONL (JSON Lines) format for large datasets
- Add option to export as minified JSON (no indentation) for smaller file sizes
- Add format selection dropdown (CSV, JSON, JSONL) instead of separate buttons
- Add option to customize JSON formatting (indent size, sort keys, etc.)
- Support exporting nested/hierarchical data structures
- Add Excel export format (.xlsx) as a third option

### Implementation Notes
- Follow the existing CSV export patterns in export_utils.py for consistency
- Reuse ExportRequest and QueryExportRequest models if possible to reduce code duplication
- Position JSON buttons adjacent to CSV buttons for easy comparison
- Use clear labeling (e.g., "📊 CSV" vs "📋 JSON" or "CSV" vs "JSON" text buttons)
- Ensure error messages are user-friendly and actionable
- Test thoroughly with various data types and edge cases to ensure robust implementation
