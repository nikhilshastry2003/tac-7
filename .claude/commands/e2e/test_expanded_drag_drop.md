# E2E Test: Expanded Drag and Drop Zone

Test the expanded drag-and-drop functionality that allows users to drag files onto the Query Section and Available Tables Section.

## User Story

As a user
I want to drag and drop files directly onto the query section or tables section
So that I can quickly upload data without having to click the "Upload" button first and navigate a modal

## Test Steps

1. Navigate to the `Application URL`
2. Take a screenshot of the initial state
3. **Verify** the page title is "Natural Language SQL Interface"
4. **Verify** core UI elements are present:
   - Query input textbox (within query-section)
   - Query button
   - Upload Data button
   - Available Tables section (tables-section)

5. Prepare a test CSV file for drag-and-drop testing (use sample data or create a simple test file)
6. Simulate dragging a CSV file over the Query Section (query-section element)
7. **Verify** the drag-over visual feedback appears with text "Drop to create the table"
8. Take a screenshot showing the drag-over state on Query Section
9. Simulate dropping the file on the Query Section
10. **Verify** the file upload succeeds and a success message appears
11. **Verify** the new table appears in the Available Tables section
12. Take a screenshot of the successful upload

13. Prepare another test file (JSON or JSONL format)
14. Simulate dragging the file over the Available Tables Section (tables-section element)
15. **Verify** the drag-over visual feedback appears with text "Drop to create the table"
16. Take a screenshot showing the drag-over state on Tables Section
17. Simulate dropping the file on the Tables Section
18. **Verify** the file upload succeeds and a success message appears
19. **Verify** the new table appears in the Available Tables section
20. Take a screenshot of the final state with both uploaded tables

21. **Verify** dragging text (not files) over the sections does not trigger the drop zone
22. **Verify** the existing modal upload functionality still works (click Upload button and modal appears)

## Success Criteria
- Dragging files over Query Section shows "Drop to create the table" overlay
- Dragging files over Tables Section shows "Drop to create the table" overlay
- Dropping files on Query Section successfully uploads and creates table
- Dropping files on Tables Section successfully uploads and creates table
- Visual feedback appears immediately when dragging valid files
- Visual feedback disappears when dragging away from sections
- Success messages appear after successful uploads
- Tables list updates after successful uploads
- Existing modal upload functionality remains intact
- 4 screenshots are taken capturing key states
