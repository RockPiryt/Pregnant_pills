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
    name = db.Column(db.Text)
    amount = db.Column(db.Integer)
    date_week = db.Column(db.Integer)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))

    def __init__(self, name, amount, date_week, user_id):
        self.name = name
        self.amount = amount
        self.date_week = date_week
        self.user_id = user_id

    def __repr__(self):
        return f'Pill name:{self.name}, amount: {self.amount}, pregnant week: {self.date_week} add by {self.user_id}'


class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.Text)
    pills = db.relationship('Pill', backref='user', lazy='dynamic')

    def __init__(self, name):
        self.name = name
    
    def __repr__(self):
        return f'Username: {self.name}'




############PDF REPORTS#######################
class PDF_report():

    def __init__(self, filename):
        self.filename = filename

    def generate(self, user, list_pill):
        pass

    pdf = FPDF(orientation='P', unit='pt', format='A4')
    pdf.add_page()

    #Title
    pdf.set_font(family='Arial', size=24, style='B')
    pdf.cell(w=0, h=80, txt='User pills during pregnant', border=1, align='C', ln=1)

    #User info
    pdf.set_font(family='Arial', size=18, style='B')
    pdf.cell(w=100, h=50, txt='Username:', border=1)
    pdf.cell(w=100, h=50, txt='Paulina', border=1, ln=1)

    #Pills info
    pdf.set_font(family='Arial', size=18)
    pdf.cell(w=100, h=50, txt='Pill name:', border=1)
    pdf.cell(w=100, h=50, txt='Nospa', border=1, ln=1)

    pdf.output('pills.pdf')

    



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
        date_week = form.date_week.data
        user_id = form.user_id.data

        pill = Pill(name, amount, date_week, user_id)
        db.session.add(pill)
        db.session.commit()
        return redirect(url_for('list_pill'))
    return render_template('add_pill.html', form=form)

@app.route('/list_pill')
def list_pill():
    pills = Pill.query.all()
    return render_template('list_pill.html', pills=pills)

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
        user=User(name)
        db.session.add(user)
        db.session.commit()
        return redirect(url_for('add_pill'))
    return render_template('add_user.html', form=form)

if __name__ == '__main__':
    app.run(debug=True)



