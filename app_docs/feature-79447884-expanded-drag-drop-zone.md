# Expanded Drag-and-Drop Zone

**ADW ID:** 79447884
**Date:** 2026-01-13
**Specification:** specs/issue-5-adw-79447884-sdlc_planner-expand-drag-drop-zone.md

## Overview

Enhanced the file upload experience by expanding drag-and-drop functionality beyond the modal dialog. Users can now drag CSV, JSON, or JSONL files directly onto either the Query Section or Available Tables Section. Visual feedback displays "Drop to create the table" when dragging files over these zones, making uploads more intuitive and reducing required clicks.

## What Was Built

- Expanded drag-and-drop zones covering the Query Section (upper div) and Available Tables Section (lower div)
- Visual overlay with "Drop to create the table" message that appears during drag operations
- Drag counter tracking to properly handle entering/leaving nested elements
- File type detection to only trigger zones when dragging actual files (not text/links)
- Seamless integration with existing file upload functionality
- CSS animations for smooth overlay appearance
- E2E test suite for validating the feature

## Technical Implementation

### Files Modified

- `app/client/src/main.ts`: Added `initializeExpandedDropZones()` function with drag event handlers for both sections (88 lines added)
- `app/client/src/style.css`: Added `.drag-zone-active` styles with overlay, border, and fade-in animation (37 lines added)
- `.claude/commands/e2e/test_expanded_drag_drop.md`: Created comprehensive E2E test specification (53 lines added)

### Key Changes

1. **Drag Counter Tracking**: Implemented separate drag counters (`queryDragCounter`, `tablesDragCounter`) for each section to properly handle dragenter/dragleave events when moving over nested child elements

2. **File Type Detection**: Added `hasFiles()` helper function that checks `e.dataTransfer?.types.includes('Files')` to ensure drop zones only activate when dragging actual files, not text or other content

3. **Visual Feedback System**: Created CSS overlay using `::after` pseudo-element with semi-transparent background (rgba(102, 126, 234, 0.15)), dashed border, and centered text

4. **Event Handler Pattern**: Each drop zone implements four event listeners:
   - `dragenter`: Increment counter and add CSS class on first enter
   - `dragover`: Prevent default and maintain drag state
   - `dragleave`: Decrement counter and remove CSS class when counter reaches zero
   - `drop`: Process file upload via existing `handleFileUpload()` function

5. **Reuse of Existing Logic**: Leveraged the existing `handleFileUpload()` function ensuring identical file validation, error handling, and success messaging across all upload methods

## How to Use

1. **Drag Files onto Query Section**:
   - Open the application
   - Drag a CSV, JSON, or JSONL file over the query input area
   - When the overlay appears with "Drop to create the table", release the file
   - The file will be uploaded and a table will be created

2. **Drag Files onto Tables Section**:
   - Drag a file over the "Available Tables" section (lower part of the page)
   - The same overlay will appear
   - Drop to upload and create the table

3. **Alternative Methods Still Available**:
   - Click "Upload" button to use the modal dialog
   - Use sample data buttons for quick testing
   - All existing upload methods continue to work unchanged

## Configuration

No configuration required. The feature works out-of-the-box with the existing file upload infrastructure.

**Supported file types**: .csv, .json, .jsonl

## Testing

### E2E Testing
Run the comprehensive E2E test suite:
```bash
# Read the test file
cat .claude/commands/e2e/test_expanded_drag_drop.md

# Execute using the test_e2e command
# Follow instructions in .claude/commands/test_e2e.md
```

### Manual Testing
1. Start the application
2. Drag a CSV file onto the query section - verify overlay appears
3. Drop the file - verify table is created
4. Drag a JSON file onto the tables section - verify overlay appears
5. Drop the file - verify table is created
6. Drag text from a document - verify no overlay appears (file detection working)
7. Test modal upload - verify it still works as before

### Validation Commands
```bash
cd app/server && uv run pytest                  # Backend tests
cd app/client && bun tsc --noEmit              # TypeScript checks
cd app/client && bun run build                 # Frontend build
```

## Notes

- **Drag Counter Strategy**: The drag counter pattern solves a common issue where `dragleave` fires when entering child elements. By tracking enter/leave counts, the overlay only disappears when truly leaving the drop zone.

- **Performance**: Uses CSS pseudo-elements for the overlay to avoid DOM manipulation overhead. The `pointer-events: none` CSS property ensures the overlay doesn't interfere with drag event detection.

- **Accessibility**: While drag-and-drop is not keyboard-accessible, the existing "Upload" button remains available for users who cannot use drag-and-drop functionality.

- **Browser Compatibility**: Uses standard Drag and Drop API supported in all modern browsers. Falls back gracefully - if drag events aren't supported, users can still use the upload button.

- **Future Enhancements**: Consider adding multi-file upload support, progress indicators for large files, or drag-to-reorder functionality for query history.

- **Design Decisions**:
  - Only processes the first file if multiple files are dragged (prevents confusion)
  - Overlay uses primary color (--primary-color) for brand consistency
  - Fade-in animation (0.2s) provides polish without feeling sluggish
  - Z-index of 100 ensures overlay appears above content but below modals
