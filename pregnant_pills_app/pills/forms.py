from flask_wtf import FlaskForm
from wtforms import (IntegerField, StringField, SubmitField,
                    RadioField, TextAreaField)
from wtforms.validators import DataRequired

class CategoryPillForm(FlaskForm):
    type_pill = RadioField('Choose type: ', 
                        choices=[('Routine', 'Everyday pill'),('Special', 'Special pill')])
    submit = SubmitField('Choose type')

class PillForm(FlaskForm):
    name = StringField(label=' ')
    amount = IntegerField(label=' ', validators=[DataRequired()])
    date_start = StringField(label=' ')
    date_end = StringField(label=' ')
    reason = TextAreaField(label=' ')
    submit = SubmitField('Add pill')

# class OldPillForm(FlaskForm):
#     choose_pill = SelectField(u'Choose pill from our database', choices=[('Apap', 'L_Apap'), ('Nospa', 'L_Nospa'), ('Pregna', 'L_Pregna'), ('Reflug', 'L_Reflug')])
#     add_date = DateTimeField('Choose date:')




