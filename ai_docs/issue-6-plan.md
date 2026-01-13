# Implementation Plan: JSON Export Functionality

## Issue #6
**Goal:** Add JSON export functionality for tables and query results, similar to existing CSV export.

## Current State
- CSV export exists for both tables and query results
- Backend has `/api/export/table` and `/api/export/query` endpoints that return CSV
- Frontend has `exportTable()` and `exportQueryResults()` API methods
- Export button shows "CSV" icon and triggers CSV download

## Requirements
1. Add JSON export option alongside existing CSV export
2. Users can export:
   - Individual tables as JSON
   - Query results as JSON
3. JSON format should be an array of objects (similar to how data is stored internally)

## Implementation Steps

### Step 1: Add JSON export utility functions (Backend)
In `app/server/core/export_utils.py`:
1. Add `generate_json_from_data(data: list, columns: list) -> str` function
2. Add `generate_json_from_table(conn, table_name: str) -> str` function
3. Use `json.dumps()` with proper formatting (indent=2)

### Step 2: Add JSON export API endpoints (Backend)
In `app/server/server.py`:
1. Add `/api/export/table/json` endpoint
   - Similar to existing CSV export but returns JSON
   - Content-Type: `application/json`
   - Filename: `{table_name}_export.json`
2. Add `/api/export/query/json` endpoint
   - Similar to existing CSV query export but returns JSON
   - Content-Type: `application/json`
   - Filename: `query_results.json`

### Step 3: Add JSON export API methods (Frontend)
In `app/client/src/api/client.ts`:
1. Add `exportTableAsJson(tableName: string)` method
2. Add `exportQueryResultsAsJson(data: any[], columns: string[])` method
3. Both methods should trigger file download similar to CSV methods

### Step 4: Update UI for export options (Frontend)
In `app/client/src/main.ts`:
1. Modify export button to show dropdown/menu with CSV and JSON options
2. For tables section: add JSON export option next to CSV
3. For query results: add JSON export option next to CSV

Option A (Simple): Add separate JSON button next to CSV button
Option B (Dropdown): Convert export button to dropdown with CSV/JSON options

Recommended: Option A for simplicity - add a second button for JSON export

### Step 5: Update CSS for new buttons
In `app/client/src/style.css`:
1. Add styling for JSON export button (if different from CSV)
2. Ensure button group looks cohesive

## Files to Modify
1. `app/server/core/export_utils.py` - Add JSON generation functions
2. `app/server/server.py` - Add JSON export endpoints
3. `app/client/src/api/client.ts` - Add JSON export API methods
4. `app/client/src/main.ts` - Add JSON export UI buttons
5. `app/client/src/style.css` - Style new buttons (if needed)

## Testing
1. Test JSON export for tables
2. Test JSON export for query results
3. Verify JSON file format is valid and readable
4. Verify CSV export still works
5. Test with various data types (strings, numbers, nulls, nested objects)
6. Verify proper filename in downloaded files
