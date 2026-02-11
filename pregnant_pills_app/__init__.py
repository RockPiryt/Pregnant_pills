import os
from flask import Flask, render_template
from config import config_dict
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager

def create_app():
    app = Flask(__name__)

    env_name = os.getenv("APP_ENV", "development").lower()
    cfg = config_dict.get(env_name, config_dict["development"])
    app.config.from_object(cfg)

    db.init_app(app)
    migrate.init_app(app, db, render_as_batch=True)

    # Create login_manager class
    login_manager.init_app(app)
    login_manager.blueprint_login_views = {
        'pills': '/pregnant-pill/add_pill',
        'users': '/pregnant-user/user',
    }

    # Register Blueprints
    from pregnant_pills_app.users.views import users_blueprint
    from pregnant_pills_app.pills.views import pills_blueprint
    from pregnant_pills_app.errors.views import error_blueprint
    from pregnant_pills_app.report_pdf.views import report_pdf_blueprint

    app.register_blueprint(users_blueprint, url_prefix="/pregnant-user")
    app.register_blueprint(pills_blueprint, url_prefix="/pregnant-pill")
    app.register_blueprint(error_blueprint, url_prefix="/pregnant-errors")
    app.register_blueprint(report_pdf_blueprint, url_prefix="/pregnant-report-pdf")

    @app.route("/")
    def index():
        return render_template("home.html")

    @app.get("/health")
    def health():
        return {"status": "ok"}, 200

    return app

db = SQLAlchemy()
migrate = Migrate()
login_manager = LoginManager()

app = create_app()
