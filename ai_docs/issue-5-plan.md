# Implementation Plan: Increase Drop Zone Surface Area

## Issue #5
**Goal:** Extend drag-and-drop functionality to allow users to drop files on the query section (upper div) and tables section (lower div), not just in the upload modal.

## Current State
- Drag-and-drop only works within the `drop-zone` element inside the upload modal
- Users must click "Upload" button to open modal before they can drag and drop
- The `initializeFileUpload()` function handles drag events only for `#drop-zone`

## Requirements
1. Users can drag and drop files directly on:
   - Query section (`#query-section`) - the upper area with textarea
   - Tables section (`#tables-section`) - the lower area with available tables
2. Visual feedback: UI shows "Drop to create the table" when dragging over these areas
3. Maintain existing functionality in the modal drop zone

## Implementation Steps

### Step 1: Add global drag state tracking
- Add CSS class `global-drag-active` to body when file is being dragged into the page
- Track when files enter/leave the page area

### Step 2: Modify CSS for drop zone overlays
Add new CSS styles in `app/client/src/style.css`:
- `.droppable-section` - base style for sections that accept drops
- `.drop-overlay` - overlay that appears during drag with "Drop to create the table" text
- `.drag-active` - styling when actively dragging over a section

### Step 3: Extend drop zone functionality in main.ts
In `app/client/src/main.ts`:
1. Create new function `initializeGlobalDropZones()` that:
   - Adds drag event listeners to `#query-section` and `#tables-section`
   - Shows overlay with "Drop to create the table" message on dragenter
   - Hides overlay on dragleave/drop
   - Calls existing `handleFileUpload()` on drop

2. Update `initializeFileUpload()` to:
   - Handle dragenter on document to show global drop state
   - Handle dragleave on document to hide drop state when leaving window

### Step 4: Update HTML structure
Add drop overlay elements to the sections in `app/client/index.html`:
- Add `class="droppable-section"` to `#query-section` and `#tables-section`
- Add hidden drop overlay div inside each section

## Files to Modify
1. `app/client/src/style.css` - Add drop zone styles
2. `app/client/src/main.ts` - Add global drop zone initialization
3. `app/client/index.html` - Add droppable-section classes and overlays

## Testing
1. Verify drag-and-drop works on query section
2. Verify drag-and-drop works on tables section
3. Verify modal drop zone still works
4. Verify "Drop to create the table" text appears during drag
5. Verify visual feedback is clear and intuitive
6. Test file upload completes successfully from any drop zone
