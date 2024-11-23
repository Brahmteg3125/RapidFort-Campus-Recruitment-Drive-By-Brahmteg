from flask import Flask, render_template, request, send_file
import os
from werkzeug.utils import secure_filename
from docx import Document
from docx2pdf import convert
from PyPDF2 import PdfReader, PdfWriter
import io

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['SECRET_KEY'] = 'your_secret_key'

ALLOWED_EXTENSIONS = {'docx'}

def allowed_file(filename):
    return '.' in filename and \
        filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def get_metadata(doc_path):
    doc = Document(doc_path)
    core_properties = doc.core_properties
    metadata = {
        'author': core_properties.author,
        'title': core_properties.title,
        'subject': core_properties.subject,
        'category': core_properties.category,
        'comments': core_properties.comments,
        'created': core_properties.created,
        'last_modified_by': core_properties.last_modified_by,
        'last_printed': core_properties.last_printed,
        'modified': core_properties.modified,
        'revision': core_properties.revision,
        'version': core_properties.version
    }
    return metadata

@app.route('/', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        # Check for file part in request
        if 'file' not in request.files:
            return 'No file part', 400
        file = request.files['file']
        # Check for empty filename
        if file.filename == '':
            return 'No selected file', 400
        # Validate file
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            upload_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
            file.save(upload_path)
            metadata = get_metadata(upload_path)
            return render_template('result.html', metadata=metadata, filename=filename)
        else:
            return 'Invalid file type', 400
    return render_template('index.html')

@app.route('/download/<filename>', methods=['GET', 'POST'])
def download_file(filename):
    upload_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    pdf_filename = filename.rsplit('.', 1)[0] + '.pdf'
    pdf_path = os.path.join(app.config['UPLOAD_FOLDER'], pdf_filename)
    convert(upload_path, pdf_path)

    if request.method == 'POST':
        password = request.form.get('password')
        if password:
            # Add password protection
            pdf_reader = PdfReader(pdf_path)
            pdf_writer = PdfWriter()
            for page in pdf_reader.pages:
                pdf_writer.add_page(page)
            pdf_writer.encrypt(user_pwd=password, owner_pwd=None, use_128bit=True)
            protected_pdf = io.BytesIO()
            pdf_writer.write(protected_pdf)
            protected_pdf.seek(0)
            os.remove(pdf_path)
            return send_file(protected_pdf, as_attachment=True, download_name=pdf_filename)
        else:
            return send_file(pdf_path, as_attachment=True)
    return render_template('download.html', filename=filename)

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
