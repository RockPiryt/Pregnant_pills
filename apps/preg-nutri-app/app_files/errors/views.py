from flask import render_template, Blueprint


#------------------------------Register Blueprint
error_blueprint = Blueprint("errors", __name__, template_folder="templates/errors")

#--------------------------------Errors views
#bad_request - wrong data in request
@error_blueprint.app_errorhandler(400)
def bad_request(error):
    return render_template('400.html'), 400

# unauthorized
@error_blueprint.app_errorhandler(401)
def unauthorized(error):
    return render_template('401.html'), 401

# page_not_found = no record in db
@error_blueprint.app_errorhandler(404)
def page_not_found(error):
    return render_template('404.html'), 404

# unsupported_media
@error_blueprint.app_errorhandler(415)
def unsupported_media(error):
    return render_template('415.html'), 415

# internal_server_error
@error_blueprint.app_errorhandler(500)
def internal_server_error(error):
    return render_template('500.html'), 500



