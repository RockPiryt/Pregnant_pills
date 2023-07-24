from pregnant_pills_app import db
from pregnant_pills_app.models import Pill
from flask import flash, redirect, render_template, url_for, Blueprint, request
from pregnant_pills_app.pills.forms import  CategoryPillForm, PillForm
from flask_login import login_required, current_user


pills_blueprint = Blueprint("pills", __name__, template_folder="templates/pills")

################## PILLS VIEWS####################
@pills_blueprint.route('/category_pill', methods=['GET', 'POST'])
@login_required
def category_pill():
    '''User choose  pill category by form.'''

    #Create form with 2 categories
    category_form = CategoryPillForm()
    if category_form.validate_on_submit():
        category_pill = category_form.type_pill.data
        return redirect(url_for('pills.add_pill', html_category_pill=category_pill))
    return render_template('category_pill_form.html', html_form=category_form, logged_in=current_user.is_authenticated,)

@pills_blueprint.route('/add_pill', methods=['GET', 'POST'])
@login_required
def add_pill():
    '''Add pill to database'''

    pill_form = PillForm()
    if pill_form.validate_on_submit():
        #Get information from form
        name = pill_form.name.data
        amount = pill_form.amount.data
        reason = pill_form.reason.data
        date_start = pill_form.date_start.data
        date_end = pill_form.date_end.data
        user_id = current_user.id

        # Get pill type from category form
        type_pill = request.args.get("html_category_pill")

        #Create pill object
        new_pill = Pill(type_pill, name, amount, reason, date_start, date_end, user_id)
        #Add pill to database
        db.session.add(new_pill)
        db.session.commit()
        flash(f'You add new pills {new_pill.name} to your medical diary!')
        #Redirect to list with all user's pills
        return redirect(url_for('pills.list_pill'))
    return render_template('pill_form.html', html_form=pill_form, logged_in=current_user.is_authenticated)

@pills_blueprint.route('/list_pill')
@login_required
def list_pill():
    '''Show list with all user's pills.'''

    pills = Pill.query.filter_by(user_id=current_user.id).all()
    return render_template('list_pill.html', pills=pills, html_current_user=current_user, logged_in=current_user.is_authenticated)


@pills_blueprint.route('/delete-pill', methods=['GET', 'POST'])
def del_pill():
    '''Delete pill from database'''

    # Get pill from database to delete
    id_pill_to_del = request.args.get("del_pill_id")
    pill_to_del = Pill.query.get(id_pill_to_del)
    db.session.delete(pill_to_del)
    db.session.commit()
    return redirect(url_for('pills.list_pill'))

