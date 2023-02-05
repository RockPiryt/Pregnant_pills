from flask_wtf import FlaskForm
from wtforms import (IntegerField, StringField, SubmitField,
                    RadioField, DateTimeField, BooleanField, 
                    SelectField, TextAreaField)
from wtforms.validators import DataRequired, Email

class AddPillForm(FlaskForm):
    name = StringField('Add Pill name: ')
    choose_pill = SelectField(u'Choose pill from our database', choices=[('Apap', 'L_Apap'), ('Nospa', 'L_Nospa'), ('Pregna', 'L_Pregna'), ('Reflug', 'L_Reflug')])
    amount = IntegerField('Amount of pills: ', validators=[DataRequired()])
    type_pill = RadioField('Choose type: ', 
                        choices=[('Rutine', 'L_Rutine'),('Special', 'L_Special')])
    week_start = IntegerField('Pregnant week_start:')
    week_end = IntegerField('Pregnant week_end:')
    add_date = DateTimeField('Choose date:')
    reason = TextAreaField('Reason: ')
    user_id = IntegerField('ID_user: ')
    submit = SubmitField('Add pill')

class DelPillForm(FlaskForm):
    id_pill = IntegerField('Add ID_pill')
    submit = SubmitField('Delete pill')


class AddUserForm(FlaskForm):
    name = StringField('Add name: ')
    surname = StringField('Add surname: ')
    # email = StringField('Add email:', validators=[Email()])
    preg_week = SelectField(u'Add actual pregnant week: ', choices=[('1', 'L_1'), ('2', 'L_2'), ('3', 'L_3'), ('4', 'L_4'),
                                                                    ('5', 'L_5'), ('6', '6'), ('7', '7'), ('8', 'L_8'),
                                                                    ('9', 'L_9'), ('10', 'L_10'), ('11', 'L_11'), ('12', 'L_12'),])

    submit = SubmitField('Add User')

