from pregnant_pills_app import app, db
from pregnant_pills_app.models import User, Pill
from flask import flash, redirect, render_template, url_for, Blueprint
from pregnant_pills_app.pills.forms import AddPillForm, DelPillForm

pills_blueprint = Blueprint("pills", __name__, template_folder="templates/pills")

################## PILLS VIEWS####################
@pills_blueprint.route('/add_pill/<int:user_primary_key>', methods=['GET', 'POST'])
def add_pill(user_primary_key):

    form = AddPillForm()
    user = User.query.get_or_404(user_primary_key)

    if form.validate_on_submit():
        name = form.name.data
        choose_pill = form.choose_pill.data
        amount = form.amount.data
        type_pill = form.type_pill.data
        week_start = form.week_start.data
        week_end = form.week_end.data
        add_date = form.add_date.data
        reason = form.reason.data
        user_id = user_primary_key

        pill = Pill(name, choose_pill, amount, type_pill,
                    week_start, week_end, add_date, reason, user_id)
        db.session.add(pill)
        db.session.commit()
        flash(f'You add new pills {pill.name} to your medical diary!')
        return redirect(url_for('add_pill', user_primary_key=user.id))
        # return redirect(url_for('list_pill', user_primary_key=user.id))
    return render_template('add_pill.html', form=form, user_id=user_primary_key, user=user)


@pills_blueprint.route('/list_pill/<int:user_primary_key>')
def list_pill(user_primary_key):
    user = User.query.get_or_404(user_primary_key)
    # user_id to one to many powiązanie
    pills = Pill.query.filter_by(user_id=user.id).all()
    # one_pill = Pill.query.filter(db.and_(Pill.user_id==user.id, Pill.id==pills.id)).all()
    return render_template('list_pill.html', pills=pills, user=user)
    # return render_template('list_pill.html', pills=pills, user=user, one_pill_p_key=one_pill.id)

# @app.route('/del_pill', methods=['GET','POST'])
# def del_pill_by_id():
#     form = DelPillForm()

#     if form.validate_on_submit():
#         id_pill = form.id_pill.data
#         pill = Pill.query.get(id_pill)
#         db.session.delete(pill)
#         db.session.commit()
#         return redirect(url_for('list_pill'))
#     return render_template('del_pill.html', form=form)


@pills_blueprint.route('/<int:one_pill_p_key>/del_pill/', methods=['GET', 'POST'])
def del_pill(one_pill_p_key):
    form = DelPillForm()

    if form.validate_on_submit():
        one_pill_p_key = form.id_pill.data
        pill = Pill.query.get(one_pill_p_key)
        db.session.delete(pill)
        db.session.commit()
        return redirect(url_for('index'))
    return render_template('del_pill.html', form=form)

# @app.post('/<int:one_pill_p_key>/del_pill/') # post oznacza że routa przyjmuje tylko methode POST
# def del_pill(one_pill_p_key):
#     pill = Pill.query.get_or_404(one_pill_p_key)
#     db.session.delete(pill)
#     db.session.commit()
#     return redirect(url_for('list_pill', user_primary_key=user.id))