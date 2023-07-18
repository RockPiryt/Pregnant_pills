import os
# from os.path import join, dirname
from dotenv import load_dotenv, find_dotenv
from flask import Flask, render_template, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from fpdf import FPDF
from forms import AddPillForm, DelPillForm, AddUserForm
from models import User, Pill

# ------------------------Get secrets
load_dotenv(find_dotenv())
SECRET_KEY_VAR = os.getenv("secret_key")


app = Flask(__name__)
app.config['SECRET_KEY'] = SECRET_KEY_VAR

# ---------------------- DATABASES
# #SQLite database
# basedir = os.path.abspath(os.path.dirname(__file__))
# app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + \
#     os.path.join(basedir, 'pill_db.sqlite')

# PostgreSQL database
username_postdb = os.getenv("postgreSQL_username")
password_postdb = os.getenv("postgreSQL_password")
database_postdb = os.getenv("postgreSQL_database")
host_postdb = os.getenv("postgreSQL_host")
app.config['SQLALCHEMY_DATABASE_URI'] = f"postgresql://{username_postdb}:{password_postdb}@{host_postdb}/{database_postdb}"

app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
Migrate(app, db)
app.app_context().push()


############ MAIN VIEWS###################
@app.route('/')
def index():
    db.create_all()
    return render_template('home.html')


##################USER VIEWS####################
@app.route('/add_user', methods=['GET', 'POST'])
def add_user():
    preg_list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
                 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40]

    form = AddUserForm()

    if form.validate_on_submit():
        name = form.name.data
        surname = form.surname.data
        preg_week = form.preg_week.data
        user = User(name, surname, preg_week)

        db.session.add(user)
        db.session.commit()
        return redirect(url_for('user', user_primary_key=user.id))
    return render_template('add_user.html', form=form, preg_list_whole=preg_list)


@app.route('/<int:user_primary_key>/user/')
def user(user_primary_key):
    # to sortuje po primary key zawsze
    user = User.query.get_or_404(user_primary_key)
    return render_template('user.html', user=user, user_primary_key=user.id)


@app.route('/all_users')
def all_users():
    users = User.query.all()
    return render_template('all_users.html', users=users)


################## PILLS VIEWS####################
@app.route('/add_pill/<int:user_primary_key>', methods=['GET', 'POST'])
def add_pill(user_primary_key):

    form = AddPillForm()
    user = User.query.get_or_404(user_primary_key)

    if form.validate_on_submit():
        name = form.name.data
        choose_pill = form.choose_pill.data
        amount = form.amount.data
        type_pill = form.type_pill.data
        week_start = form.week_start.data
        week_end = form.week_end.data
        add_date = form.add_date.data
        reason = form.reason.data
        user_id = user_primary_key

        pill = Pill(name, choose_pill, amount, type_pill,
                    week_start, week_end, add_date, reason, user_id)
        db.session.add(pill)
        db.session.commit()
        flash(f'You add new pills {pill.name} to your medical diary!')
        return redirect(url_for('add_pill', user_primary_key=user.id))
        # return redirect(url_for('list_pill', user_primary_key=user.id))
    return render_template('add_pill.html', form=form, user_id=user_primary_key, user=user)


@app.route('/list_pill/<int:user_primary_key>')
def list_pill(user_primary_key):
    user = User.query.get_or_404(user_primary_key)
    # user_id to one to many powiązanie
    pills = Pill.query.filter_by(user_id=user.id).all()
    # one_pill = Pill.query.filter(db.and_(Pill.user_id==user.id, Pill.id==pills.id)).all()
    return render_template('list_pill.html', pills=pills, user=user)
    # return render_template('list_pill.html', pills=pills, user=user, one_pill_p_key=one_pill.id)

# @app.route('/del_pill', methods=['GET','POST'])
# def del_pill_by_id():
#     form = DelPillForm()

#     if form.validate_on_submit():
#         id_pill = form.id_pill.data
#         pill = Pill.query.get(id_pill)
#         db.session.delete(pill)
#         db.session.commit()
#         return redirect(url_for('list_pill'))
#     return render_template('del_pill.html', form=form)


@app.route('/<int:one_pill_p_key>/del_pill/', methods=['GET', 'POST'])
def del_pill(one_pill_p_key):
    form = DelPillForm()

    if form.validate_on_submit():
        one_pill_p_key = form.id_pill.data
        pill = Pill.query.get(one_pill_p_key)
        db.session.delete(pill)
        db.session.commit()
        return redirect(url_for('index'))
    return render_template('del_pill.html', form=form)

# @app.post('/<int:one_pill_p_key>/del_pill/') # post oznacza że routa przyjmuje tylko methode POST
# def del_pill(one_pill_p_key):
#     pill = Pill.query.get_or_404(one_pill_p_key)
#     db.session.delete(pill)
#     db.session.commit()
#     return redirect(url_for('list_pill', user_primary_key=user.id))

################## PDF VIEWS####################


@app.route('/pdf_create/<int:user_primary_key>', methods=['GET', 'POST'])
def pdf_create(user_primary_key):
    pdf_report = PDF_report(filename='pills_user_pk.pdf')
    user = User.query.get_or_404(user_primary_key)
    pdf_report.generate_list(user)
    return (f'PDF report was created. PDF filename: pills_user_pk.pdf')


############ PDF REPORTS#######################
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

        # Title
        pdf.set_font(family='Arial', size=24, style='B')
        pdf.cell(w=0, h=80, txt='User pills during pregnant',
                 border=1, align='C', ln=1)

        # User info
        pdf.set_font(family='Arial', size=18, style='B')
        pdf.cell(w=100, h=50, txt='Username:', border=1)
        pdf.cell(w=100, h=50, txt=user.name, border=1, ln=1)

        # Pills info
        pdf.set_font(family='Arial', size=18)
        pdf.cell(w=100, h=50, txt='Pills information:', border=1)
        for pill in pills:
            pdf.cell(w=200, h=200, txt=pill.name, border=1, ln=1)

        pdf.output(self.filename)


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
