from flask_wtf import FlaskForm
from wtforms import IntegerField, StringField, SubmitField

class AddPillForm(FlaskForm):
    name = StringField('Pill name: ')
    amount = IntegerField('Amount of pills: ')
    date_week = IntegerField('Pregnant week:')
    user_id = IntegerField('ID_user: ')
    submit = SubmitField('Add pill')


class DelPillForm(FlaskForm):
    id_pill = IntegerField('Add ID_pill')
    submit = SubmitField('Delete pill')


class AddUserForm(FlaskForm):
    name = StringField('Add name: ')
    submit = SubmitField('Add User')