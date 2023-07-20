
from flask import Blueprint
from fpdf import FPDF
from pregnant_pills_app.models import User, Pill

#------------------------------Register Blueprint
report_pdf_blueprint = Blueprint("report_pdf", __name__, template_folder="templates/report_pdf")


#-------------------------------PDF_report function
class PDF_report():

    def __init__(self, filename):
        self.filename = filename

    def generate_list(self, user):
        # tu słownik z tabletkami klasa
        pills = Pill.query.filter_by(user_id=user.id).all()
        # muszę wyciągnąc name zeby był string bo tak to cała klase mi wyciąga
        # pill = pills[2]
        # for pill in pills:
        #     return pill
        # user_list_pills = user.report_pills()

        pdf = FPDF(orientation='P', unit='pt', format='A4')
        pdf.add_page()

        #-----------------------------------Title
        pdf.set_font(family='Arial', size=24, style='B')
        pdf.cell(w=0, h=80, txt='User pills during pregnant',
                 border=1, align='C', ln=1)

        #---------------------------------User info
        pdf.set_font(family='Arial', size=18, style='B')
        pdf.cell(w=100, h=50, txt='Username:', border=1)
        pdf.cell(w=100, h=50, txt=user.name, border=1, ln=1)

        #-----------------------------------Pills info
        pdf.set_font(family='Arial', size=18)
        pdf.cell(w=100, h=50, txt='Pills information:', border=1)
        for pill in pills:
            pdf.cell(w=200, h=200, txt=pill.name, border=1, ln=1)

        pdf.output(self.filename)


#------------------------------Views
@report_pdf_blueprint.route('/pdf_create/<int:user_primary_key>', methods=['GET', 'POST'])
def pdf_create(user_primary_key):
    pdf_report = PDF_report(filename='pills_user_pk.pdf')
    user = User.query.get_or_404(user_primary_key)
    pdf_report.generate_list(user)
    return (f'PDF report was created. PDF filename: pills_user_pk.pdf')

