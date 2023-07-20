from flask import Flask, render_template
from config import config_dict #Dict with configurations name
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate



#--------------Create app
app = Flask(__name__)
app.config.from_object(config_dict['testing'])
db = SQLAlchemy(app)
migrate = Migrate(app,db)

app.app_context().push()
# db.create_all()

# -----------------------------------Register Blueprints
from pregnant_pills_app.users.views import users_blueprint
from pregnant_pills_app.pills.views import pills_blueprint
from pregnant_pills_app.errors.views import error_blueprint
from pregnant_pills_app.report_pdf.views import report_pdf_blueprint

app.register_blueprint(users_blueprint, url_prefix="/pregnant-user")
app.register_blueprint(pills_blueprint, url_prefix="/pregnant-pill")
app.register_blueprint(error_blueprint, url_prefix="/pregnant-errors")
app.register_blueprint(report_pdf_blueprint, url_prefix="/pregnant-report-pdf")


#-------------------------------------Main view
@app.route('/')
def index():
    return render_template('home.html')


#-----------------------------------
if __name__ == '__main__':
    app.run(debug=True)