# E2E Test: Drop Zone Expansion

Test the expanded drag-and-drop functionality on both the sample data section and drop zone in the Natural Language SQL Interface application.

## User Story

As a user
I want to drag and drop data files directly onto the sample data or file upload sections
So that I can quickly create tables without having to click the Upload button first

## Test Steps

1. Navigate to the `Application URL`
2. Take a screenshot of the initial state
3. **Verify** the page title is "Natural Language SQL Interface"
4. **Verify** core UI elements are present:
   - Query input textbox
   - Query button
   - Upload Data button
   - Available Tables section

5. Click the "Upload Data" button to open the upload modal
6. **Verify** the upload modal is displayed
7. **Verify** the modal contains:
   - "Quick Start with Sample Data" section (upper div)
   - Sample data buttons (Users Data, Product Inventory, Event Analytics)
   - "or" divider
   - Drop zone section (lower div) with text "Drag and drop .csv, .json, or .jsonl files here"
   - Browse Files button
8. Take a screenshot of the upload modal initial state

9. Create a test CSV file with sample data
10. Simulate dragging a file over the sample data section (upper div)
11. **Verify** the sample data section displays the dragover state:
    - Border color changes to primary color
    - Background changes to highlighted state
    - Text updates to "Drop to create a table"
12. Take a screenshot of the drag over sample data section state

13. Simulate dragging away from the sample data section
14. **Verify** the sample data section returns to normal state:
    - Border returns to transparent
    - Background returns to normal
    - Text returns to "Quick Start with Sample Data"

15. Simulate dragging a file over the drop zone section (lower div)
16. **Verify** the drop zone displays the dragover state:
    - Border color changes to primary color
    - Background changes to highlighted state
    - Text updates to "Drop to create a table"
17. Take a screenshot of the drag over drop zone state

18. Simulate dragging away from the drop zone
19. **Verify** the drop zone returns to normal state:
    - Border returns to dashed style
    - Background returns to normal
    - Text returns to "Drag and drop .csv, .json, or .jsonl files here"

20. Simulate dropping a CSV file on the sample data section (upper div)
21. **Verify** the file upload is triggered
22. **Verify** the upload modal closes automatically after successful upload
23. **Verify** a success message appears with the table name and row count
24. Take a screenshot of the successful upload result

25. Click the "Upload Data" button to open the modal again
26. Simulate dropping a CSV file on the drop zone section (lower div)
27. **Verify** the file upload is triggered
28. **Verify** the upload modal closes automatically after successful upload
29. **Verify** a success message appears with the table name and row count
30. Take a screenshot of the second successful upload result

## Success Criteria
- Upload modal opens and displays both sections correctly
- Sample data section (upper div) accepts drag and drop operations
- Drop zone section (lower div) accepts drag and drop operations
- Both sections display visual feedback (dragover state) when files are dragged over
- Text updates to "Drop to create a table" during drag operations on both sections
- Text restores to original when drag leaves or completes
- Files dropped on either section trigger the upload process
- Upload modal closes automatically after successful upload
- Success messages appear after each upload
- Sample data buttons continue to work normally
- Browse button continues to work normally
- At least 5 screenshots are taken
