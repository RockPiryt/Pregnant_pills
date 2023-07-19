from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask import Flask, render_template, redirect, url_for, flash
from config import config_dict #Dict with configurations name
from fpdf import FPDF
from forms import AddPillForm, DelPillForm, AddUserForm


#--------------Create app
app = Flask(__name__)
app.config.from_object(config_dict['development'])
db = SQLAlchemy(app)
app.app_context().push()




from sqlalchemy.sql import func
######################### MODELS##########################
class Pill(db.Model):
    __tablename__ = 'pills'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    choose_pill = db.Column(db.String(100))
    amount = db.Column(db.Integer, nullable=False)
    type_pill = db.Column(db.String(40))
    week_start = db.Column(db.Integer)
    week_end = db.Column(db.Integer)
    add_date = db.Column(db.DateTime(timezone=True), server_default=func.now())
    reason = db.Column(db.Text)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))

    def __init__(self, name, choose_pill, amount, type_pill, week_start, week_end, add_date, reason, user_id):
        self.name = name
        self.choose_pill = choose_pill
        self.amount = amount
        self.type_pill = type_pill
        self.week_start = week_start
        self.week_end = week_end
        self.add_date = add_date
        self.reason = reason
        self.user_id = user_id

    def __repr__(self):
        return f'Pill name:{self.name}'


class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.Text, nullable=False)
    surname = db.Column(db.Text)
    preg_week = db.Column(db.Integer)

    pills = db.relationship('Pill', backref='user', lazy='dynamic')

    def __init__(self, name, surname, preg_week):
        self.name = name
        self.surname = surname
        self.preg_week = preg_week

    def __repr__(self):
        return f'Username: {self.name}, Surname: {self.surname}, Pregnant week: {self.preg_week}'

    def report_pills(self):
        for pill in self.pills:
            return pill
############ MAIN VIEWS###################
@app.route('/')
def index():
    # db.create_all()
    return render_template('home.html')


##################USER VIEWS####################
@app.route('/add_user', methods=['GET', 'POST'])
def add_user():

    #Create list with pregnant weeks
    week_preg = list(range(1,41))
    form = AddUserForm()

    if form.validate_on_submit():
        name = form.name.data
        surname = form.surname.data
        preg_week = form.preg_week.data
        user = User(name, surname, preg_week)

        db.session.add(user)
        db.session.commit()
        return redirect(url_for('user', user_primary_key=user.id))
    return render_template('add_user.html', form=form, preg_list_whole=week_preg)


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

# db = SQLAlchemy()
# db.init_app(app)
# migrate=Migrate()
# migrate.init_app(app, db)

# # # THIS WILL CREATE THE SCHEMA INTO THE DATABASE (only needs to be done when first creating the database)
# with app.app_context():
#     db.create_all()