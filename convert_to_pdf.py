#!/usr/bin/env python3
"""
Convert markdown to PDF - Simple robust approach
"""
import os
from pathlib import Path
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import cm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib import colors
from reportlab.lib.enums import TA_JUSTIFY

def strip_markdown(text):
    """Remove markdown formatting and return plain text"""
    # Remove bold/italic markers
    text = text.replace('**', '')
    text = text.replace('*', '')
    text = text.replace('`', '')
    # Remove links
    text = text.replace('[', '').replace(']', '')
    # Remove extra spaces
    text = ' '.join(text.split())
    return text

def convert_markdown_to_pdf(md_file, output_pdf):
    """Convert markdown to PDF with simple plain text approach"""
    
    with open(md_file, 'r', encoding='utf-8') as f:
        md_content = f.read()
    
    doc = SimpleDocTemplate(
        output_pdf,
        pagesize=A4,
        rightMargin=1.5*cm,
        leftMargin=1.5*cm,
        topMargin=2*cm,
        bottomMargin=1.5*cm,
        title="Parkino Documentation",
        author="Parkino Team"
    )
    
    styles = getSampleStyleSheet()
    
    title_style = ParagraphStyle(
        'Title',
        parent=styles['Heading1'],
        fontSize=22,
        textColor=colors.HexColor('#0B2A4A'),
        spaceAfter=15,
        fontName='Helvetica-Bold'
    )
    
    heading2_style = ParagraphStyle(
        'H2',
        parent=styles['Heading2'],
        fontSize=14,
        textColor=colors.HexColor('#0B2A4A'),
        spaceAfter=10,
        spaceBefore=10,
        fontName='Helvetica-Bold'
    )
    
    heading3_style = ParagraphStyle(
        'H3',
        parent=styles['Heading3'],
        fontSize=11,
        textColor=colors.HexColor('#1E3A5F'),
        spaceAfter=8,
        spaceBefore=8,
        fontName='Helvetica-Bold'
    )
    
    body_style = ParagraphStyle(
        'Body',
        parent=styles['BodyText'],
        fontSize=10,
        alignment=TA_JUSTIFY,
        spaceAfter=10
    )
    
    content = []
    
    # Title page
    content.append(Spacer(1, 2*cm))
    content.append(Paragraph("Parkino Mobile App", title_style))
    content.append(Spacer(1, 0.5*cm))
    content.append(Paragraph("Documentation Complete du Projet", heading2_style))
    content.append(Spacer(1, 0.3*cm))
    content.append(Paragraph("Date: 29 Mai 2026", body_style))
    content.append(Spacer(1, 2*cm))
    
    # Process markdown
    lines = md_content.split('\n')
    buffer = []
    
    for line in lines:
        stripped = line.strip()
        
        if not stripped:
            if buffer:
                text = ' '.join(buffer)
                text = strip_markdown(text)
                if text.strip():
                    para = Paragraph(text, body_style)
                    content.append(para)
                buffer = []
            content.append(Spacer(1, 0.3*cm))
        elif stripped.startswith('# '):
            if buffer:
                text = ' '.join(buffer)
                text = strip_markdown(text)
                if text.strip():
                    para = Paragraph(text, body_style)
                    content.append(para)
                buffer = []
            title_text = strip_markdown(stripped[2:])
            content.append(Paragraph(title_text, heading2_style))
        elif stripped.startswith('## '):
            if buffer:
                text = ' '.join(buffer)
                text = strip_markdown(text)
                if text.strip():
                    para = Paragraph(text, body_style)
                    content.append(para)
                buffer = []
            heading_text = strip_markdown(stripped[3:])
            content.append(Paragraph(heading_text, heading3_style))
        elif stripped.startswith('### '):
            if buffer:
                text = ' '.join(buffer)
                text = strip_markdown(text)
                if text.strip():
                    para = Paragraph(text, body_style)
                    content.append(para)
                buffer = []
            heading_text = strip_markdown(stripped[4:])
            content.append(Paragraph(heading_text, heading3_style))
        elif stripped == '---':
            if buffer:
                text = ' '.join(buffer)
                text = strip_markdown(text)
                if text.strip():
                    para = Paragraph(text, body_style)
                    content.append(para)
                buffer = []
            content.append(Spacer(1, 0.5*cm))
        else:
            buffer.append(stripped)
    
    # Final buffer
    if buffer:
        text = ' '.join(buffer)
        text = strip_markdown(text)
        if text.strip():
            para = Paragraph(text, body_style)
            content.append(para)
    
    # Footer
    content.append(Spacer(1, 1*cm))
    footer_text = "Documentation generee le 29 Mai 2026"
    content.append(Paragraph(footer_text, ParagraphStyle('Footer', parent=styles['Normal'], fontSize=8, textColor=colors.grey)))
    
    # Build PDF
    print("Converting to PDF...")
    try:
        doc.build(content)
        size_kb = os.path.getsize(output_pdf) / 1024
        print(f"Success! PDF created: {output_pdf} ({size_kb:.1f} KB)")
        return True
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    project_dir = Path(__file__).parent
    md_file = project_dir / "PROJECT_DOCUMENTATION.md"
    pdf_file = project_dir / "PROJECT_DOCUMENTATION.pdf"
    
    if not md_file.exists():
        print(f"Error: {md_file} not found")
        exit(1)
    
    success = convert_markdown_to_pdf(str(md_file), str(pdf_file))
    exit(0 if success else 1)
