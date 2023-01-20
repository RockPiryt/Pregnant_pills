from flask_wtf import FlaskForm
from wtforms import IntegerField, StringField, SubmitField, RadioField

class AddPillForm(FlaskForm):
    name = StringField('Pill name: ')
    amount = IntegerField('Amount of pills: ')
    type_pill = StringField('Add type: ')
    week_start = IntegerField('Pregnant week_start:')
    week_end = IntegerField('Pregnant week_end:')
    reason = StringField('Reason: ')
    user_id = IntegerField('ID_user: ')
    submit = SubmitField('Add pill')

class DelPillForm(FlaskForm):
    id_pill = IntegerField('Add ID_pill')
    submit = SubmitField('Delete pill')


class AddUserForm(FlaskForm):
    name = StringField('Add name: ')
    surname = StringField('Add surname: ')
    preg_week = IntegerField('Add actual pregnant week: ')

    submit = SubmitField('Add User')
