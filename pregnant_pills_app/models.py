from pregnant_pills_app import db
# from sqlalchemy.sql import func
from flask_login import UserMixin


######################### MODELS##########################
class Pill(db.Model):
    __tablename__ = 'pills'
    __table_args__ = {'extend_existing': True}
    id = db.Column(db.Integer, primary_key=True)
    type_pill = db.Column(db.String(40))
    name = db.Column(db.String(100))
    amount = db.Column(db.Integer, nullable=False)
    reason = db.Column(db.Text)
    date_start = db.Column(db.Integer)
    date_end = db.Column(db.Integer)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))

    def __init__(self, type_pill, name, amount, reason, date_start, date_end, user_id):
        self.type_pill = type_pill
        self.name = name
        self.amount = amount
        self.reason = reason
        self.date_start = date_start
        self.date_end = date_end
        self.user_id = user_id

    def __repr__(self):
        return f'Pill name:{self.name}'


class User(UserMixin,db.Model):
    __tablename__ = 'users'
    __table_args__ = {'extend_existing': True}
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.Text, nullable=False)
    surname = db.Column(db.Text, nullable=False)
    preg_week = db.Column(db.Integer)
    email = db.Column(db.Text, nullable=False, unique=True)
    password = db.Column(db.String(100))

    pills = db.relationship('Pill', backref='user', lazy='dynamic')

    def __init__(self, name, surname, preg_week, email, password):
        self.name = name
        self.surname = surname
        self.preg_week = preg_week
        self.email = email
        self.password = password

    def __repr__(self):
        return f'Username: {self.name}, Surname: {self.surname}, Pregnant week: {self.preg_week}, Email: {self.email}'

    def report_pills(self):
        for pill in self.pills:
            return pill

    # def __repr__(self):
    #     if self.type_pill == 'special':
    #         return f'Date: {self.week_start}, Pill name:{self.name}, amount: {self.amount}, (reason:{self.reason})'
    #     else:
    #         return f'Date: {self.week_start} - {self.week_end}, Pill name:{self.name}, amount: {self.amount}'


# add_date = db.Column(db.DateTime(timezone=True), server_default=func.now())