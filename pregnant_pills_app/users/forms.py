
from flask_wtf import FlaskForm
from wtforms import StringField,SelectField, SubmitField, EmailField
from flask_wtf import FlaskForm
from wtforms.validators import InputRequired,DataRequired


class AddUserForm(FlaskForm):
    name = StringField(label=' ', validators=[DataRequired()])
    surname = StringField(label=' ', validators=[DataRequired()])
    preg_week_form = SelectField(label=' ', coerce=int, validators=[InputRequired()])
    email = EmailField(label='', validators=[DataRequired()])
    submit = SubmitField(label='Register')