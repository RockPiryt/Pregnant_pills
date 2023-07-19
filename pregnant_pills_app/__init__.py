from flask import Flask, render_template
from config import config_dict #Dict with configurations name
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
# from pregnant_pills_app.models import User, Pill
from fpdf import FPDF




#--------------Create app
app = Flask(__name__)
app.config.from_object(config_dict['testing'])
db = SQLAlchemy(app)
migrate = Migrate(app,db)
app.app_context().push()


# -----------------------------------Register Blueprints
from pregnant_pills_app.users.views import users_blueprint
from pregnant_pills_app.pills.views import pills_blueprint

app.register_blueprint(users_blueprint, url_prefix="/pregnant-user")
app.register_blueprint(pills_blueprint, url_prefix="/pregnant-pill")


############ MAIN VIEWS###################
@app.route('/')
def index():
    db.create_all()
    return render_template('home.html')


################## PDF VIEWS####################
@app.route('/pdf_create/<int:user_primary_key>', methods=['GET', 'POST'])
def pdf_create(user_primary_key):
    pass
    # pdf_report = PDF_report(filename='pills_user_pk.pdf')
    # user = User.query.get_or_404(user_primary_key)
    # pdf_report.generate_list(user)
    # return (f'PDF report was created. PDF filename: pills_user_pk.pdf')


# ############ PDF REPORTS#######################
# class PDF_report():

#     def __init__(self, filename):
#         self.filename = filename

#     def generate_list(self, user):
#         # tu słownik z tabletkami klasa
#         pills = Pill.query.filter_by(user_id=user.id).all()
#         # muszę wyciągnąc name zeby był string bo tak to cała klase mi wyciąga
#         # pill = pills[2]
#         # for pill in pills:
#         #     return pill
#         # user_list_pills = user.report_pills()

#         pdf = FPDF(orientation='P', unit='pt', format='A4')
#         pdf.add_page()

#         # Title
#         pdf.set_font(family='Arial', size=24, style='B')
#         pdf.cell(w=0, h=80, txt='User pills during pregnant',
#                  border=1, align='C', ln=1)

#         # User info
#         pdf.set_font(family='Arial', size=18, style='B')
#         pdf.cell(w=100, h=50, txt='Username:', border=1)
#         pdf.cell(w=100, h=50, txt=user.name, border=1, ln=1)

#         # Pills info
#         pdf.set_font(family='Arial', size=18)
#         pdf.cell(w=100, h=50, txt='Pills information:', border=1)
#         for pill in pills:
#             pdf.cell(w=200, h=200, txt=pill.name, border=1, ln=1)

#         pdf.output(self.filename)


############ ERRORS################
# bad_request - wrong data in request
@app.errorhandler(400)
def bad_request(e):
    return render_template('400.html'), 400

# unauthorized
@app.errorhandler(401)
def unauthorized(e):
    return render_template('401.html'), 401

# page_not_found = no record in db
@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404

# unsupported_media
@app.errorhandler(415)
def unsupported_media(e):
    return render_template('415.html'), 415

# internal_server_error
@app.errorhandler(500)
def internal_server_error(e):
    return render_template('500.html'), 500


################################################
if __name__ == '__main__':
    app.run(debug=True)
