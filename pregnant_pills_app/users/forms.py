
from flask_wtf import FlaskForm
from wtforms import StringField,SelectField, SubmitField
from flask_wtf import FlaskForm
from wtforms.validators import InputRequired


class AddUserForm(FlaskForm):
    name = StringField('Add name: ')
    surname = StringField('Add surname: ')
    preg_week_form = SelectField(u'Add actual pregnant week: ', coerce=int, validators=[InputRequired()])
    submit = SubmitField('Add User')