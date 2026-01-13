# Feature: Expand Drag and Drop Zone Surface Area

## Metadata
issue_number: `5`
adw_id: `79447884`
issue_json: `{"number":5,"title":"increase the drop zone surface area","body":"/feature\n\nadw_sdlc_ios.py\n\nlet's increase the drop zone surface area, instead of clicking 'upload data', the user can drag and drop right on the upper div or lower div\n\nalso the UI will update to 'Drop to create the table'.\n\nthis has the exact functionality, but a bit user friendly."}`

## Feature Description
Enhance the file upload user experience by expanding the drag-and-drop zones from being limited to a modal dialog to supporting drag-and-drop directly on the main page sections. This allows users to drag files onto either the Query Section (upper div) or the Available Tables Section (lower div) without first clicking the "Upload" button to open a modal. The UI will provide clear visual feedback showing "Drop to create the table" when a file is dragged over these zones.

## User Story
As a user
I want to drag and drop files directly onto the query section or tables section
So that I can quickly upload data without having to click the "Upload" button first and navigate a modal

## Problem Statement
Currently, users must follow a multi-step process to upload data:
1. Click the "Upload" button to open a modal
2. Either drag files into the modal's drop zone or use the browse button
3. Wait for the modal to close after successful upload

This creates friction in the user experience, especially for users who frequently upload multiple datasets. The drag-and-drop functionality is hidden behind a modal, making it less discoverable and requiring extra clicks.

## Solution Statement
Expand the drag-and-drop surface area to include the two main sections of the page: the Query Section (upper div) and the Available Tables Section (lower div). When users drag a file over either section, the UI will display a visual overlay with the text "Drop to create the table" to indicate that files can be dropped there. This maintains all existing functionality (file validation, table creation, etc.) while making the upload process more intuitive and reducing the number of clicks required.

## Relevant Files
Use these files to implement the feature:

- `app/client/src/main.ts` - Contains the file upload initialization logic and drag-and-drop event handlers. This is where we'll add new drag-and-drop zones for the query section and tables section.
- `app/client/src/style.css` - Contains all styling including the current drop-zone styles. We'll add styles for the new drag-over states and overlay text for the expanded drop zones.
- `app/client/index.html` - Contains the HTML structure with the query-section and tables-section divs that will become drop zones.
- `app/client/src/api/client.ts` - Contains the API client methods including `uploadFile()` which we'll reuse for handling file uploads from the new drop zones.
- `app/server/server.py` - Contains the `/api/upload` endpoint that handles file uploads. No changes needed but relevant for understanding the upload flow.

### New Files

- `.claude/commands/e2e/test_expanded_drag_drop.md` - E2E test file to validate the new drag-and-drop functionality works correctly on both the query section and tables section.

## Implementation Plan
### Phase 1: Foundation
Add the necessary CSS classes and styles to support drag-over visual feedback on the query and tables sections. This includes creating overlay styles that display "Drop to create the table" when files are dragged over these sections. Review the existing drop-zone styles and create similar but distinct styles for the expanded zones to maintain visual consistency.

### Phase 2: Core Implementation
Implement the drag-and-drop event handlers for the query section and tables section. This involves:
1. Adding dragover, dragleave, and drop event listeners to both sections
2. Managing drag state to show/hide the visual overlay
3. Preventing default browser behavior for drag events
4. Reusing the existing `handleFileUpload()` function to process dropped files
5. Adding appropriate CSS classes during drag operations for visual feedback

### Phase 3: Integration
Ensure the new drag-and-drop zones work seamlessly with existing upload functionality. The modal upload should continue to work, and all file validation, error handling, and success messages should function identically regardless of which drop zone is used. Test edge cases like dragging multiple files, dragging non-supported file types, and dragging files between different sections.

## Step by Step Tasks

### 1. Review existing drag-and-drop implementation
- Read `app/client/src/main.ts` focusing on `initializeFileUpload()` and `handleFileUpload()`
- Understand the current drag-and-drop event flow in the modal
- Identify reusable code patterns

### 2. Design CSS for expanded drag zones
- Open `app/client/src/style.css`
- Create new CSS classes for drag-over states on query-section and tables-section
- Add styles for the "Drop to create the table" overlay that appears during drag
- Ensure visual consistency with existing drop-zone styles
- Use semi-transparent overlays to indicate drop zones clearly

### 3. Implement drag-and-drop for Query Section
- Modify `app/client/src/main.ts` to add drag event listeners to the query-section element
- Handle dragover event to show the overlay and apply CSS classes
- Handle dragleave event to hide the overlay
- Handle drop event to process the file using existing `handleFileUpload()` function
- Prevent default browser behavior to avoid navigation

### 4. Implement drag-and-drop for Tables Section
- Add drag event listeners to the tables-section element
- Implement the same event handlers as the query section
- Ensure consistent behavior between both drop zones
- Handle edge cases like dragging over child elements

### 5. Add visual feedback overlays
- Create overlay elements dynamically or use CSS pseudo-elements
- Display "Drop to create the table" text centered in the overlay
- Ensure overlays only appear when files are being dragged (not for text or other drag operations)
- Make overlays visually distinct but not obtrusive

### 6. Test file type detection and error handling
- Verify that only .csv, .json, and .jsonl files trigger the drop zones
- Test that dropping unsupported files shows appropriate error messages
- Ensure dragging text or links doesn't trigger the drop zone
- Verify file validation works identically to modal upload

### 7. Create E2E test file
- Read `.claude/commands/test_e2e.md` and `.claude/commands/e2e/test_basic_query.md` to understand the E2E test format
- Create `.claude/commands/e2e/test_expanded_drag_drop.md` following the established pattern
- Include test steps for dragging files onto both query section and tables section
- Add verification steps for visual feedback and successful table creation
- Specify screenshots to capture before, during, and after drag-and-drop operations

### 8. Manual testing of all upload paths
- Test modal upload to ensure it still works
- Test dragging onto query section
- Test dragging onto tables section
- Test dragging between sections
- Test with different file types (.csv, .json, .jsonl)
- Verify success messages and table list updates correctly

### 9. Run validation commands
- Execute all validation commands listed below to ensure zero regressions
- Fix any issues that arise during validation
- Ensure E2E test passes completely

## Testing Strategy
### Unit Tests
No new unit tests are required for this feature as it's primarily frontend UI enhancement. The existing backend unit tests for file upload (`app/server/tests/`) should continue to pass without modification.

### Edge Cases
- **Multiple file drag**: Dragging multiple files at once should only process the first file (or show an error message)
- **Unsupported file types**: Dragging non-.csv/.json/.jsonl files should not trigger drop zone activation
- **Rapid zone switching**: Dragging from query section to tables section should update the visual feedback appropriately
- **Drag cancellation**: Pressing ESC or dragging outside the window should remove the overlay
- **Child element hover**: Dragging over child elements within the sections should maintain the drag-over state
- **Existing modal interaction**: Opening the modal while a drag is in progress should handle gracefully
- **Mobile/touch devices**: While drag-and-drop typically doesn't work on mobile, the existing upload button should remain functional

## Acceptance Criteria
- Users can drag .csv, .json, or .jsonl files onto the Query Section and see "Drop to create the table" overlay
- Users can drag files onto the Available Tables Section and see the same overlay
- Dropping a file on either section successfully uploads it and creates a table
- Visual feedback (overlay with text) appears immediately when dragging a valid file over either section
- Visual feedback disappears when dragging away from the section
- File validation and error handling work identically to the existing modal upload
- All existing upload functionality (modal, browse button, sample data) continues to work unchanged
- Success messages and table list updates occur after successful drop
- The UI remains responsive and provides clear feedback throughout the drag operation
- E2E test passes and captures screenshots showing the feature in action

## Validation Commands
Execute every command to validate the feature works correctly with zero regressions.

- Read `.claude/commands/test_e2e.md`, then read and execute the new `.claude/commands/e2e/test_expanded_drag_drop.md` test file to validate the drag-and-drop functionality works on both sections.
- `cd app/server && uv run pytest` - Run server tests to validate the feature works with zero regressions
- `cd app/client && bun tsc --noEmit` - Run frontend TypeScript checks to validate the feature works with zero regressions
- `cd app/client && bun run build` - Run frontend build to validate the feature works with zero regressions

## Notes
- The implementation should be lightweight and avoid creating complex state management. Use simple CSS classes and DOM manipulation.
- Preserve the existing modal upload functionality completely - this feature is additive, not a replacement.
- Consider using `event.dataTransfer.types` to detect if the drag contains files before showing the overlay to avoid triggering on text drags.
- The overlay should have a high z-index to ensure it appears above all content in the section.
- Use pointer-events CSS property carefully to ensure the overlay doesn't interfere with detecting dragleave events.
- The "Drop to create the table" text should be easily localizable if internationalization is added in the future.
- Consider adding a subtle animation or transition when the overlay appears/disappears for polish.
- Document this feature in the README.md usage section to inform users of this capability.
