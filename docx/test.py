from docx import Document
from docxtpl import DocxTemplate

# # Load the existing .dotx template
# template = DocxTemplate('Cisco-06-2021-v2.41.dotx')

# # Create a context (data) dictionary with your test results
# context = {
#     'test_results': [
#         {'name': 'Test 1', 'status': 'Passed', 'timestamp': '2023-09-28'},
#         {'name': 'Test 2', 'status': 'Failed', 'timestamp': '2023-09-29'},
#         # Add more test results as needed
#     ]
# }

# # Render the template with the context data
# template.render(context)

# # Save the rendered document as a new .docx file
# template.save('rendered_document.docx')

# from docxtpl import DocxTemplate

# doc = DocxTemplate("Cisco-06-2021-v2.41.dotx")
# context = { 'company_name' : "World company" }
# doc.render(context)
# doc.save("generated_doc.docx")

# doc = Document('Cisco-06-2021-v2.41.dotx')
# context = { 'company_name' : "World company" }
# doc.add_heading('The REAL meaning of the universe')
# doc.save('test.docx')

from docx import Document

# Open an existing document
doc = Document('Template.docx')

# Access the section you want to add content to (e.g., the second section)
section = doc.sections[3]

# Add a paragraph to the document (it will be in the specified section)
paragraph = doc.add_paragraph('NEW TEXT HERE')

# Optionally, you can apply styles to the paragraph if needed
# paragraph.style = 'YourStyleName'  # Replace 'YourStyleName' with the desired style name

# Save the modified document
doc.save('demo.docx')
