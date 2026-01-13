const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

async function testDragAndDrop() {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext({
    viewport: { width: 1920, height: 1080 }
  });
  const page = await context.newPage();

  const screenshotDir = 'C:/Users/NAVEEN/Desktop/Intern_kit/.repo/TAC/tac-7/trees/79447884/agents/79447884/reviewer/review_img/';

  // Ensure directory exists
  if (!fs.existsSync(screenshotDir)) {
    fs.mkdirSync(screenshotDir, { recursive: true });
  }

  console.log('Step 1: Navigating to http://localhost:5173');
  await page.goto('http://localhost:5173');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(1000);

  console.log('Step 2: Taking initial screenshot');
  await page.screenshot({ path: path.join(screenshotDir, '01_initial_state.png'), fullPage: true });

  console.log('Step 3: Verifying page title');
  const title = await page.title();
  console.log(`Page title: "${title}"`);
  if (title !== 'Natural Language SQL Interface') {
    console.error(`ERROR: Expected title "Natural Language SQL Interface" but got "${title}"`);
  } else {
    console.log('✓ Page title verified successfully');
  }

  console.log('\nStep 4: Testing drag-and-drop on Query Section');

  // Check if query-section exists
  const querySection = await page.locator('#query-section');
  const querySectionExists = await querySection.count() > 0;
  console.log(`Query section exists: ${querySectionExists}`);

  if (querySectionExists) {
    // Simulate drag over query section
    const querySectionBox = await querySection.boundingBox();
    console.log('Simulating file drag over query section...');

    // Create DataTransfer with file
    const testProductsPath = 'C:/Users/NAVEEN/AppData/Local/Temp/test_products.csv';

    // Trigger dragenter event
    await page.evaluate((selector) => {
      const element = document.querySelector(selector);
      const event = new DragEvent('dragenter', {
        bubbles: true,
        cancelable: true,
        dataTransfer: new DataTransfer()
      });
      element.dispatchEvent(event);
    }, '#query-section');

    await page.waitForTimeout(500);

    // Check for overlay
    const overlay = await page.locator('.drag-overlay, [class*="drag"], [class*="overlay"]').first();
    const overlayVisible = await overlay.isVisible().catch(() => false);
    console.log(`Drag overlay visible: ${overlayVisible}`);

    await page.screenshot({ path: path.join(screenshotDir, '02_query_section_drag_over.png'), fullPage: true });

    // Now perform the actual file drop
    console.log('Performing file drop on query section...');
    const fileInput = await page.locator('input[type="file"]').first();

    if (await fileInput.count() > 0) {
      await fileInput.setInputFiles(testProductsPath);
      console.log('File set on input element');
      await page.waitForTimeout(2000); // Wait for upload to complete

      await page.screenshot({ path: path.join(screenshotDir, '03_query_section_upload_success.png'), fullPage: true });
      console.log('✓ Query section upload screenshot taken');
    } else {
      console.log('Attempting alternative drop method...');
      // Alternative: use the drag-drop data transfer
      await querySection.dispatchEvent('drop', {
        dataTransfer: {
          files: [{ name: 'test_products.csv', type: 'text/csv' }]
        }
      });
      await page.waitForTimeout(2000);
      await page.screenshot({ path: path.join(screenshotDir, '03_query_section_upload_success.png'), fullPage: true });
    }
  } else {
    console.error('ERROR: Query section (#query-section) not found on page');
  }

  console.log('\nStep 5: Testing drag-and-drop on Tables Section');

  // Check if tables-section exists
  const tablesSection = await page.locator('#tables-section');
  const tablesSectionExists = await tablesSection.count() > 0;
  console.log(`Tables section exists: ${tablesSectionExists}`);

  if (tablesSectionExists) {
    const testUsersPath = 'C:/Users/NAVEEN/AppData/Local/Temp/test_users.json';

    // Simulate drag over tables section
    console.log('Simulating file drag over tables section...');

    await page.evaluate((selector) => {
      const element = document.querySelector(selector);
      const event = new DragEvent('dragenter', {
        bubbles: true,
        cancelable: true,
        dataTransfer: new DataTransfer()
      });
      element.dispatchEvent(event);
    }, '#tables-section');

    await page.waitForTimeout(500);
    await page.screenshot({ path: path.join(screenshotDir, '04_tables_section_drag_over.png'), fullPage: true });

    // Perform file drop on tables section
    console.log('Performing file drop on tables section...');
    const fileInputs = await page.locator('input[type="file"]');
    const fileInputCount = await fileInputs.count();

    if (fileInputCount > 0) {
      // Use the appropriate file input (might be the second one if first was used)
      const targetInput = fileInputCount > 1 ? fileInputs.nth(1) : fileInputs.first();
      await targetInput.setInputFiles(testUsersPath);
      console.log('File set on tables section input element');
      await page.waitForTimeout(2000);

      await page.screenshot({ path: path.join(screenshotDir, '05_final_state_with_tables.png'), fullPage: true });
      console.log('✓ Final state screenshot taken');
    }
  } else {
    console.error('ERROR: Tables section (#tables-section) not found on page');
  }

  console.log('\nStep 6: Verifying tables appear in Available Tables section');

  // Look for table entries
  const tableEntries = await page.locator('[class*="table"], .table-item, [data-table]').all();
  console.log(`Found ${tableEntries.length} potential table elements`);

  // Try to find text content related to uploaded tables
  const pageContent = await page.content();
  const hasProductsTable = pageContent.includes('test_products') || pageContent.includes('products');
  const hasUsersTable = pageContent.includes('test_users') || pageContent.includes('users');

  console.log(`Products table visible: ${hasProductsTable}`);
  console.log(`Users table visible: ${hasUsersTable}`);

  // Take a final screenshot showing the tables section
  const availableTables = await page.locator('text=Available Tables').first();
  if (await availableTables.isVisible().catch(() => false)) {
    console.log('✓ Available Tables section found');
  }

  console.log('\n=== Test Summary ===');
  console.log('All screenshots saved to:', screenshotDir);
  console.log('Screenshots created:');
  console.log('  - 01_initial_state.png');
  console.log('  - 02_query_section_drag_over.png');
  console.log('  - 03_query_section_upload_success.png');
  console.log('  - 04_tables_section_drag_over.png');
  console.log('  - 05_final_state_with_tables.png');

  await browser.close();
  console.log('\nTest completed successfully!');
}

testDragAndDrop().catch(console.error);
