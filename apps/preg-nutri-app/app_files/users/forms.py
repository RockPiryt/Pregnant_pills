
from flask_wtf import FlaskForm
from wtforms import StringField,SelectField, SubmitField, EmailField, PasswordField
from flask_wtf import FlaskForm
from wtforms.validators import InputRequired,DataRequired


class RegisterUserForm(FlaskForm):
    name = StringField(label=' ', validators=[DataRequired()])
    surname = StringField(label=' ', validators=[DataRequired()])
    preg_week_form = SelectField(label=' ', coerce=int, validators=[InputRequired()])
    email = EmailField(label='', validators=[DataRequired()])
    password = PasswordField(label='', validators=[DataRequired()])
    submit = SubmitField(label='Register')

class LoginUserForm(FlaskForm):
    email = EmailField(label='', validators=[DataRequired()])
    password = PasswordField(label='', validators=[DataRequired()])
    submit = SubmitField(label='Login')