#!/bin/bash
import xml.etree.ElementTree as ET
from lxml import etree
import zipfile
import os


def unpack_docx(file_out):
    return


def pack_docx(file):
    zip_files = ['Content_Types].xml', '_rels', 'customXml', 'docProps', 'word']
    zip_filename = 'Test__z.docx'
    with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for folder_name in zip_files:
            # Add the contents of the folder to the zip file
            for folder_root, _, folder_files in os.walk(folder_name):
                for file in folder_files:
                    file_path = os.path.join(folder_root, file)
                    arcname = os.path.relpath(file_path, folder_name)
                    zipf.write(file_path, arcname=arcname)
    return


def update_item2_xml(props_dict):

    # Open the XML file
    ET.register_namespace('', 'http://schemas.cisco.com/ASMasterTemplate/additionalProperties')
    tree = ET.parse("./customXml/item2.xml")
    root = tree.getroot()
    preamble = '{http://schemas.cisco.com/ASMasterTemplate/additionalProperties}'
    for p, value in props_dict.items():
        # Construct the element path without a namespace
        element_path = f'.//{preamble}{p}'
        # Find the element without specifying a namespace
        element = root.find(element_path)
        # Check if the element exists before updating
        if element is not None and value is not None:
            print(f'updating {p} with value : {value}')
            element.text = value
        else:
            print(f"Element '{p}' not updated.")
    # Save the updated XML to a new file
    tree.write("./customXml/item2.xml", xml_declaration=True, encoding='utf-8')
    print('Outputing updted changes to ./customXml/item2.xml')


def update_custom_xml(props_dict):
    tree = etree.parse('./docProps/custom.xml')
    tree.getroot().nsmap
    root = tree.getroot()
    # Creating namespace maping from the XML:
    nsmap = {k if k is not None else 'default':v for k,v in root.nsmap.items()}
    for p, value in props_dict.items():
        # Find the element without specifying a namespace
        if value is not None:
            custom_property = root.find(f'default:property[@pid="{p}"]', nsmap)
            if custom_property is not None:
                lpwstr = custom_property.find('.//vt:lpwstr', nsmap)
                if lpwstr is not None:
                    print(f'updating pid={p} with value: {value}')
                    lpwstr.text = value
                else:
                    print(f"lpwstr tag for property pid={p} not found.")
            else:
                print(f'Custom Property pid={p} not found in custom.xml')
        else:
            print(f'No value found for pid={p}')
    tree.write("./docProps/custom.xml", xml_declaration=True, encoding='utf-8')


props_tuple = [
    ('ProjectNameAndCustomerName', 5, 'VF Germany - SDN Controller'),
    ('documentCustomerName', 8, 'VF Germany'),
    ('documentDeliverableName', None, 'Acceptance Test Plan'),
    ('VersionDocument', 20, '1.0'),
    ('documentAuthor', 6, 'Ulfat Butt'),
    ('ChangeAuthority', 4, 'Cisco CX'),
    ('documentDCP', 9, '11239'),
    ('documentPID', 11, '11239'),
    ('documentProject', 12, 'VF STEP Project'),
    ('documentClassification', 7, 'Cisco Highly Confidential'),
    ('documentTheater', 15, 'EMEA'),
    ('documentOrg', 10, 'Cisco CX')
]
file_in = 'Template.docx'
file_out = 'test.docx'
props_dict = {item[0]: item[2] for item in props_tuple}
update_item2_xml(props_dict)
props_dict = {item[1]: item[2] for item in props_tuple}
update_custom_xml(props_dict)