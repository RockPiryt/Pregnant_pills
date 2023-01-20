import os
from flask import Flask, render_template, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from forms import AddPillForm, DelPillForm, AddUserForm
from fpdf import FPDF


app = Flask(__name__)
app.config['SECRET_KEY']='4piers.teach.4Sows.3convex'

###############DATABASE SQLITE#####################

basedir = os.path.abspath(os.path.dirname(__file__))
app.config['SQLALCHEMY_DATABASE_URI'] ='sqlite:///'+os.path.join(basedir, 'pill_db.sqlite')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
Migrate(app, db)

#########################MODELS##########################

class Pill(db.Model):
    __tablename__ = 'pills'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.Text, nullable=False)
    amount = db.Column(db.Integer, nullable=False)
    type_pill = db.Column(db.Text)
    week_start = db.Column(db.Integer, nullable=False)
    week_end = db.Column(db.Integer)
    reason = db.Column(db.Text)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))

    def __init__(self, name, amount, type_pill, week_start, week_end, reason, user_id):
        self.name = name
        self.amount = amount
        self.type_pill = type_pill
        self.week_start = week_start
        self.week_end = week_end
        self.reason = reason
        self.user_id = user_id

    def __repr__(self):
        if self.type_pill == 'special':
            return f'Date: {self.week_start}, Pill name:{self.name}, amount: {self.amount}, (reason:{self.reason})'
        else:
            return f'Date: {self.week_start} - {self.week_end}, Pill name:{self.name}, amount: {self.amount}'


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
            return(pill)






############PDF REPORTS#######################
class PDF_report():

    def __init__(self, filename):
        self.filename = filename

    def generate(self, user):
        user_list_pills = user.report_pills()

        pdf = FPDF(orientation='P', unit='pt', format='A4')
        pdf.add_page()

        #Title
        pdf.set_font(family='Arial', size=24, style='B')
        pdf.cell(w=0, h=80, txt='User pills during pregnant', border=1, align='C', ln=1)

        #User info
        pdf.set_font(family='Arial', size=18, style='B')
        pdf.cell(w=100, h=50, txt='Username:', border=1)
        pdf.cell(w=100, h=50, txt= user.name, border=1, ln=1)

        #Pills info
        pdf.set_font(family='Arial', size=18)
        pdf.cell(w=100, h=50, txt='Pills information:', border=1)
        pdf.cell(w=200, h=200, txt= user_list_pills , border=1, ln=1)

        pdf.output(self.filename)


############VIEWS FUNCTIONS###################

@app.route('/')
def index():
    return render_template('home.html')

@app.route('/add_pill', methods=['GET','POST'])
def add_pill():

    form = AddPillForm()

    if form.validate_on_submit():
        name = form.name.data
        amount = form.amount.data
        type_pill = form.type_pill.data
        week_start = form.week_start.data
        week_end = form.week_end.data
        reason = form.reason.data
        user_id = form.user_id.data

        pill = Pill(name, amount, type_pill, week_start, week_end, reason, user_id)
        db.session.add(pill)
        db.session.commit()
        return redirect(url_for('list_pill'))
    return render_template('add_pill.html', form=form)

@app.route('/list_pill')
def list_pill():
    pills = Pill.query.filter_by(user_id = 3).all()
    user = User.query.filter_by(id=3).first()
    return render_template('list_pill.html', pills=pills, user=user)

@app.route('/del_pill', methods=['GET','POST'])
def del_pill():
    form = DelPillForm()

    if form.validate_on_submit():
        id_pill = form.id_pill.data
        pill = Pill.query.get(id_pill)
        db.session.delete(pill)
        db.session.commit()
        return redirect(url_for('list_pill'))
    return render_template('del_pill.html', form=form)

@app.route('/add_user', methods=['GET','POST'])
def add_user():

    form = AddUserForm()

    if form.validate_on_submit():
        name = form.name.data
        surname =form.surname.data
        preg_week = form.preg_week.data
        user=User(name, surname, preg_week)

        db.session.add(user)
        db.session.commit()
        return redirect(url_for('add_pill', user_id = user.id))
    return render_template('add_user.html', form=form)

@app.route('/pdf_create', methods=['GET','POST'])
def pdf_create():
    pdf_report = PDF_report(filename='pills.pdf')
    user = User.query.filter_by(id=3).first()
    pdf_report.generate(user)
    return(f'PDF report was created')



if __name__ == '__main__':
    app.run(debug=True)

