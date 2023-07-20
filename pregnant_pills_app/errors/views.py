from flask import render_template, Blueprint

#------------------------------Register Blueprint
error_blueprint = Blueprint("errors", __name__, template_folder="templates/errors")

#--------------------------------Errors views
# bad_request - wrong data in request
@error_blueprint.errorhandler(400)
def bad_request(e):
    return render_template('400.html'), 400

# unauthorized
@error_blueprint.errorhandler(401)
def unauthorized(e):
    return render_template('401.html'), 401

# page_not_found = no record in db
@error_blueprint.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404

# unsupported_media
@error_blueprint.errorhandler(415)
def unsupported_media(e):
    return render_template('415.html'), 415

# internal_server_error
@error_blueprint.errorhandler(500)
def internal_server_error(e):
    return render_template('500.html'), 500

