# E2E Test: JSON Export Functionality

Test table and query result JSON export functionality in the Natural Language SQL Interface application.

## User Story

As a data analyst or developer
I want to export table data and query results as JSON files with one click
So that I can integrate data with web applications, APIs, and modern data pipelines that prefer JSON format over CSV

## Test Steps

1. Navigate to the `Application URL`
2. Take a screenshot of the initial state
3. **Verify** the page title is "Natural Language SQL Interface"
4. **Verify** core UI elements are present:
   - Query input textbox
   - Query button
   - Upload Data button
   - Available Tables section

5. Upload a test CSV file containing sample data
6. **Verify** the table appears in the Available Tables section
7. **Verify** both CSV and JSON download buttons appear for the table
8. **Verify** the JSON button is labeled with "📋 JSON"
9. Take a screenshot of the table with both export buttons

10. Click the JSON download button for the table
11. **Verify** a JSON file is downloaded with the table name (e.g., "tablename_export.json")
12. **Verify** the downloaded file contains valid JSON
13. **Verify** the JSON data is properly formatted with indentation
14. **Verify** data types are preserved (numbers, booleans, null values)

15. Enter a query: "SELECT * FROM uploaded_table LIMIT 5"
16. Click the Query button
17. **Verify** the query results appear
18. **Verify** both CSV and JSON download buttons appear for query results
19. **Verify** buttons are positioned to the left of the 'Hide' button
20. Take a screenshot of query results with both export buttons

21. Click the JSON download button for query results
22. **Verify** a JSON file is downloaded named "query_results.json"
23. **Verify** the downloaded file contains valid JSON
24. **Verify** the JSON data matches the query results displayed

25. Execute an empty result query: "SELECT * FROM uploaded_table WHERE 1=0"
26. **Verify** both download buttons are still present
27. Click the JSON download button
28. **Verify** a JSON file with an empty array "[]" is downloaded

29. Execute a query with various data types: numbers, strings, null values
30. Click the JSON download button
31. **Verify** data types are preserved in JSON (not converted to strings like CSV)
32. **Verify** null values appear as "null" in JSON

33. Test Unicode and special characters:
    - Upload or query data containing Unicode characters (e.g., "测试", "Café")
    - Export as JSON
    - **Verify** Unicode characters are properly encoded

34. Take a screenshot of the final state

## Success Criteria
- Both CSV and JSON download buttons appear for tables and query results
- JSON buttons are clearly labeled and distinguishable from CSV buttons
- JSON button is positioned between CSV button and remove/hide buttons
- Table JSON export downloads complete table as properly formatted JSON
- Query JSON export downloads current results as properly formatted JSON
- JSON files have appropriate names (tablename_export.json, query_results.json)
- Empty results produce valid empty JSON array: []
- Data types are preserved in JSON (numbers, booleans, null)
- Unicode and special characters are properly encoded
- All download operations complete successfully
- 4+ screenshots are taken
