from docx import Document
import pprint

doc = Document('Template.docx')

prop_customer_name = 'Customer Name and Project/Deliverable Name'
customer_name = 'Some Customer'
doc.custom_properties["edocs.Author"] = "Rene"
custom_props = doc.core_properties.author
print(type(custom_props))
pprint(custom_props)
# doc.save('doc_props.docx')
