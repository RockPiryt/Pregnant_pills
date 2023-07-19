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

