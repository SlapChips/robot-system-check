from docx import Document

# Sample test results data (replace with your parsed data)
test_results = [
    {"name": "Test Case 1", "status": "Pass", "duration": "1s"},
    {"name": "Test Case 2", "status": "Fail", "duration": "2s"},
    # Add more test results as needed
]

# Create a new Word document
doc = Document()

# Add a title to the document
doc.add_heading('Robot Framework Test Results', level=1)

# Create a table for test results
table = doc.add_table(rows=1, cols=3)
table.style = 'Table Grid'  # Apply a table style (optional)

# Add table headers
table_headers = table.rows[0].cells
table_headers[0].text = 'Test Case'
table_headers[1].text = 'Status'
table_headers[2].text = 'Duration'

# Populate the table with test results
for test_result in test_results:
    row_cells = table.add_row().cells
    row_cells[0].text = test_result['name']
    row_cells[1].text = test_result['status']
    row_cells[2].text = test_result['duration']

# Save the Word document
doc.save('robot_test_results.docx')
