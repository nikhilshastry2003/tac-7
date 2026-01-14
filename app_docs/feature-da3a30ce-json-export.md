# JSON Export Support

**ADW ID:** da3a30ce
**Issue:** #6
**Date:** 2026-01-13
**Specification:** specs/issue-6-adw-da3a30ce-sdlc_planner-json-export.md

## Overview

This feature adds JSON export functionality for database tables and query results, complementing the existing CSV export capabilities. Users can now export data in JSON format with a single click, providing an alternative to CSV exports that is better suited for structured data interchange, web applications, and API integration scenarios.

## What Was Built

- JSON export functionality for database tables
- JSON export functionality for query results
- JSON download buttons integrated alongside CSV export buttons
- Server-side JSON generation with proper formatting and type preservation
- Client-side file download handling for JSON files
- Comprehensive unit tests for JSON export utilities
- E2E test suite for JSON export functionality

## Technical Implementation

### Files Modified

- `app/server/core/export_utils.py`: Added `generate_json_from_data()` and `generate_json_from_table()` functions
- `app/server/server.py`: Added `/api/export/table-json` and `/api/export/query-json` endpoints
- `app/client/src/api/client.ts`: Added `exportTableJson()` and `exportQueryResultsJson()` API methods
- `app/client/src/main.ts`: Added JSON download buttons alongside CSV buttons in UI
- `app/server/tests/test_export_utils.py`: Added comprehensive unit tests for JSON export utilities
- `.claude/commands/e2e/test_json_export_functionality.md`: E2E test suite for JSON export features

### Key Changes

- Created `generate_json_from_data()` and `generate_json_from_table()` functions using Python's json module
- Implemented proper NaN to None conversion for valid JSON null handling using pandas `replace({np.nan: None})`
- Added JSON download buttons labeled with "📋 JSON" positioned between CSV buttons and remove/hide buttons
- Implemented client-side blob download functionality with proper Content-Type handling
- JSON files are formatted with 2-space indentation for human readability
- Unicode characters are preserved using `ensure_ascii=False` in json.dumps()
- Data types are preserved (numbers, booleans, null values) unlike CSV which converts everything to strings
- Added comprehensive test coverage for various data types, Unicode, special characters, and edge cases

## How to Use

### Exporting Table Data as JSON

1. Navigate to the "Available Tables" section
2. Locate the table you want to export
3. Click the "📋 JSON" button next to the "📊 CSV" button
4. The JSON file will automatically download with filename format: `tablename_export.json`

### Exporting Query Results as JSON

1. Execute any SQL query that returns results
2. In the query results section, locate the header with export buttons
3. Click the "📋 JSON" button to the left of the "Hide" button
4. The JSON file will download as `query_results.json`

## JSON Format

### Example Table Export

```json
[
  {
    "id": 1,
    "name": "Item 1",
    "value": 100.5,
    "active": true
  },
  {
    "id": 2,
    "name": "Item 2",
    "value": 200.75,
    "active": false
  },
  {
    "id": 3,
    "name": "Item 3",
    "value": null,
    "active": true
  }
]
```

### Data Type Preservation

- **Integers**: Exported as JSON numbers (e.g., 42)
- **Floats**: Exported as JSON numbers (e.g., 3.14)
- **Strings**: Exported as JSON strings (e.g., "text")
- **Booleans**: Exported as JSON booleans (true/false)
- **Null**: Exported as JSON null (not "null" string)
- **Unicode**: Preserved properly (e.g., "测试", "Café", "😀")

### Empty Results

Empty tables or query results export as a valid empty JSON array:
```json
[]
```

## Configuration

No additional configuration required. The feature uses:
- Python's built-in `json` module (no new dependencies)
- Pandas for DataFrame operations (existing dependency)
- NumPy for NaN handling (existing dependency)
- FastAPI Response class for file downloads
- Unicode icons (📋 JSON, 📊 CSV) for clear differentiation

## Testing

### Unit Tests
Run server tests to validate JSON export functionality:
```bash
cd app/server && uv run pytest tests/test_export_utils.py -v
```

All 22 tests pass, including:
- Empty data handling
- Various data types (int, float, string, bool, null)
- Unicode and special characters
- Table export with non-existent tables
- Empty tables
- Tables with data

### E2E Tests
Execute comprehensive JSON export functionality tests:
```bash
# Read and execute the E2E test file
.claude/commands/e2e/test_json_export_functionality.md
```

### Manual Testing
1. Upload a CSV file and verify JSON export contains properly formatted data
2. Execute queries with various data types and verify type preservation in JSON
3. Test with empty tables and empty query results
4. Verify Unicode characters (Chinese, emojis, accents) are properly encoded
5. Verify file downloads work in different browsers
6. Compare JSON exports with CSV exports to see data type differences

## Use Cases

### When to Use JSON Export

1. **Web Application Integration**: JSON is the native format for JavaScript/TypeScript applications
2. **API Development**: Use exported data to mock API responses or test API integrations
3. **Data Type Preservation**: When you need to maintain number/boolean/null types (CSV converts everything to strings)
4. **Nested Data**: JSON supports more complex data structures than flat CSV files
5. **Modern Tooling**: Many modern data tools (Postman, REST clients, NoSQL databases) prefer JSON

### When to Use CSV Export

1. **Spreadsheet Applications**: Excel, Google Sheets, Numbers work best with CSV
2. **Data Analysis**: R, MATLAB, and many statistical tools expect CSV format
3. **Simple Tabular Data**: CSV is simpler and more human-readable for flat tables
4. **Legacy Systems**: Older systems and ETL pipelines often expect CSV

## Notes

- JSON generation uses Python's built-in json module, avoiding new external dependencies
- Export buttons are clearly labeled with emoji icons (📊 CSV vs 📋 JSON) for easy differentiation
- Security validation prevents SQL injection through table name validation (reused from CSV export)
- Large datasets are handled efficiently through pandas DataFrame operations
- NaN values from pandas are properly converted to JSON null using `df.replace({np.nan: None})`
- JSON files use 2-space indentation for human readability (can be changed to minified format if needed)
- Unicode characters are preserved using `ensure_ascii=False` parameter in json.dumps()
- Future enhancements could include JSONL (JSON Lines) format for streaming large datasets
