from flask import render_template
from pregnant_pills.erorrs import errors_bp

####TRZEBA ZROBIC BLUEPRINT######



@errors_bp.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404
