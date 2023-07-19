from pregnant_pills_app import db
from sqlalchemy.sql import func


######################### MODELS##########################
class Pill(db.Model):
    __tablename__ = 'pills'
    __table_args__ = {'extend_existing': True}
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
    __table_args__ = {'extend_existing': True}
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

    # def __repr__(self):
    #     if self.type_pill == 'special':
    #         return f'Date: {self.week_start}, Pill name:{self.name}, amount: {self.amount}, (reason:{self.reason})'
    #     else:
    #         return f'Date: {self.week_start} - {self.week_end}, Pill name:{self.name}, amount: {self.amount}'
