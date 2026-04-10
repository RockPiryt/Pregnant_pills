import os
from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager
from dotenv import load_dotenv

db = SQLAlchemy()
migrate = Migrate()
login_manager = LoginManager()


def create_app():


    app = Flask(
        __name__,
        static_folder="static",
        static_url_path="/baby/static"
    )
    #___________________Config app w zależności od środowiska_________________
    # Wczytanie zmiennych ENV(production, testing, development) + ścieżki do db
    env_name = os.getenv("APP_ENV", "development").lower() # określenie env
    if env_name == "development":
        load_dotenv()

    database_url = os.getenv("DATABASE_URL")

    from config import config_dict
    cfg = config_dict.get(env_name) # wybor config na podstawie nazwy env
    if not cfg:
        raise RuntimeError(f"Invalid APP_ENV: {env_name}. Allowed values: development, testing, production.") # zabezpieczenie przed błedną nazwa np prod zamiast production
    
    app.config.from_object(cfg)# zastosownaie config

    # Wymagania dot. db uri w zleżności od env
    if (env_name == "production" or env_name == "testing") and not database_url:
        raise RuntimeError("DATABASE_URL is required")

    if env_name == "development" and not database_url:
        basedir = os.path.abspath(os.path.dirname(__file__))
        database_url = "sqlite:///" + os.path.join(basedir, "local.db")

    app.config["SQLALCHEMY_DATABASE_URI"] = database_url

    #__________________________________________________________
    db.init_app(app)
    migrate.init_app(app, db, render_as_batch=True)

    # Create login_manager class
    login_manager.init_app(app)
    login_manager.blueprint_login_views = {
        'users': '/baby/pregnant-user/user',
    }

    # Register Blueprints
    from app_files.users.views import users_blueprint
    from app_files.errors.views import error_blueprint

    app.register_blueprint(users_blueprint, url_prefix="/baby")
    app.register_blueprint(error_blueprint, url_prefix="/baby/pregnant-errors")

    @app.route("/baby")
    def index():
        return render_template("home.html")

    @app.get("/baby/health")
    def health():
        return {"status": "ok"}, 200

    return app


app = create_app()
