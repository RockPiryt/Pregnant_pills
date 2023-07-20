from pregnant_pills_app import db
from pregnant_pills_app.models import User
from pregnant_pills_app.users.forms import RegisterUserForm, LoginUserForm
from flask import redirect, render_template, url_for, Blueprint, flash

from pregnant_pills_app import login_manager
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import login_user

users_blueprint = Blueprint(
    "users", __name__, template_folder="templates/users")


@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

################## USER VIEWS####################
@users_blueprint.route('/register_user', methods=['GET', 'POST'])
def register_user():
    '''Add new user to database'''

    # Create list with pregnant weeks
    week_num = list(range(1, 41))
    preg_week = []
    for week in week_num:
        preg_week.append(f"{week} pregnant week")

    # Forming list of tuples
    week_choices = [(week_num[n-1], preg_week[n-1]) for n in week_num]
    # print(week_choices)#[(1, '1 pregnant week'), (2, '2 pregnant week'),.....]
    register_form = RegisterUserForm()
    register_form.preg_week_form.choices = week_choices

    if register_form.validate_on_submit():
        name = register_form.name.data
        surname = register_form.surname.data
        preg_week_form = register_form.preg_week_form.data
        email_form = register_form.email.data
        password_form = register_form.password.data

        #Check if user exists in database
        existing_user = User.query.filter_by(email=email_form).first()
        if existing_user:
            flash("You have already signed up with that email, log in please! ")
            return redirect(url_for('users.login'))
        
        # Hash and salt password
        hash_salt_password = generate_password_hash(password=password_form, method="pbkdf2:sha256", salt_length=8)
        new_user = User(name, 
                    surname, 
                    preg_week_form, 
                    email_form, 
                    hash_salt_password
                    )
        # Add user info to db
        db.session.add(new_user)
        db.session.commit()

        login_user(new_user)
        return redirect(url_for('users.user', user_primary_key=new_user.id))
    return render_template('register_user.html', html_form=register_form)


@users_blueprint.route('/<int:user_primary_key>/user/')
def user(user_primary_key):
    '''Show information about user'''

    user = User.query.get_or_404(user_primary_key)
    return render_template('user.html', user=user, user_primary_key=user.id)


@users_blueprint.route('/all_users')
def all_users():
    '''Show all users in databse for admin'''

    users = User.query.all()
    return render_template('all_users.html', users=users)

@users_blueprint.route('/login-user')
def login():
    '''Login existing user'''

    login_form = LoginUserForm()
    return render_template('login_user.html', html_form=login_form)
