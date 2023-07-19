from pregnant_pills_app import db
from pregnant_pills_app.models import User
from pregnant_pills_app.users.forms import AddUserForm
from flask import redirect, render_template, url_for, Blueprint

users_blueprint = Blueprint(
    "users", __name__, template_folder="templates/users")


################## USER VIEWS####################
@users_blueprint.route('/add_user', methods=['GET', 'POST'])
def add_user():
    '''Add new user to database'''

    # Create list with pregnant weeks
    week_num = list(range(1, 41))
    preg_week = []
    for week in week_num:
        preg_week.append(f"{week} pregnant week")

    # Forming list of tuples
    week_choices = [(week_num[n-1], preg_week[n-1]) for n in week_num]
    # print(week_choices)#[(1, '1 pregnant week'), (2, '2 pregnant week'),.....]
    form_add_user = AddUserForm()
    form_add_user.preg_week_form.choices = week_choices

    if form_add_user.validate_on_submit():
        name = form_add_user.name.data
        surname = form_add_user.surname.data
        preg_week_form = form_add_user.preg_week_form.data
        user = User(name, surname, preg_week_form)

        db.session.add(user)
        db.session.commit()
        return redirect(url_for('users.user', user_primary_key=user.id))
    return render_template('add_user.html', html_form=form_add_user)


@users_blueprint.route('/<int:user_primary_key>/user/')
def user(user_primary_key):
    '''Show information about user'''
    user = User.query.get_or_404(user_primary_key)
    return render_template('user.html', user=user, user_primary_key=user.id)


@users_blueprint.route('/all_users')
def all_users():
    users = User.query.all()
    return render_template('all_users.html', users=users)
