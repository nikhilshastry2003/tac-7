# E2E Test: JSON Export Functionality

Test table and query result JSON export functionality in the Natural Language SQL Interface application.

## User Story

As a data analyst or developer
I want to export table data and query results as JSON files with one click
So that I can integrate data with web services, APIs, and modern data processing tools that consume JSON

## Test Steps

1. Navigate to the `Application URL`
2. Take a screenshot of the initial state
3. **Verify** the page title is "Natural Language SQL Interface"
4. **Verify** core UI elements are present:
   - Query input textbox
   - Query button
   - Upload Data button
   - Available Tables section

5. Upload a test CSV file containing sample data with various data types (integers, floats, strings, null values)
6. **Verify** the table appears in the Available Tables section
7. **Verify** both CSV and JSON download buttons appear for the table
8. **Verify** the JSON button is positioned between the CSV button and the 'x' icon
9. Take a screenshot of the table with both export buttons

10. Click the JSON download button for the table
11. **Verify** a JSON file is downloaded with filename format "{table_name}_export.json"
12. **Verify** the downloaded JSON file:
    - Is valid JSON
    - Contains an array of objects
    - Each object represents a row from the table
    - Data types are preserved (integers, floats, strings, null values)
    - All table data is present and correct

13. Enter a query: "SELECT * FROM uploaded_table LIMIT 5"
14. Click the Query button
15. **Verify** the query results appear
16. **Verify** both CSV and JSON export buttons appear in the results header
17. **Verify** buttons are positioned to the left of the 'Hide' button
18. Take a screenshot of query results with both export buttons

19. Click the JSON export button for query results
20. **Verify** a JSON file is downloaded named "query_results.json"
21. **Verify** the downloaded JSON file:
    - Is valid JSON
    - Contains an array of objects
    - Each object represents a row from the query results
    - All query result data is present and correct
    - Data types are correctly preserved

22. Execute a query with special characters: "SELECT * FROM uploaded_table WHERE description LIKE '%test%'"
23. Click the JSON export button
24. **Verify** special characters are properly encoded in the JSON file

25. Execute an empty result query: "SELECT * FROM uploaded_table WHERE 1=0"
26. **Verify** the JSON export button is still present
27. Click the JSON export button
28. **Verify** a valid JSON file with an empty array "[]" is downloaded

29. Test with Unicode and emoji: Upload data or query data containing Unicode characters and emojis
30. Export as JSON
31. **Verify** Unicode characters and emojis are correctly preserved in the JSON output

32. Take a screenshot of the final state

## Success Criteria

- JSON export buttons appear next to CSV export buttons for all tables
- JSON export buttons appear in query results header next to CSV export button
- Table JSON export downloads complete table data as valid JSON array
- Query JSON export downloads current results as valid JSON array
- JSON files have appropriate names ({table_name}_export.json and query_results.json)
- Empty results produce valid empty JSON array "[]"
- Data types are correctly preserved in JSON (integers, floats, strings, booleans, null)
- Special characters are properly encoded
- Unicode and emoji characters are correctly preserved
- All JSON files are valid and parseable
- All download operations complete successfully without errors
- 4 screenshots are taken
