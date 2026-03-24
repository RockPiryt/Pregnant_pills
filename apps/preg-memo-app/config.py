import os
from dotenv import load_dotenv

# Load .env only for development
if os.getenv("APP_ENV") == "development":
    load_dotenv()

class Config(object):
    SECRET_KEY = os.getenv("SECRET_KEY", "secret_flask")
    SQLALCHEMY_TRACK_MODIFICATIONS = False

# sqlite for development
class DevelopmentConfig(Config):
    basedir = os.path.abspath(os.path.dirname(__file__))
    SQLALCHEMY_DATABASE_URI = os.getenv(
        "DATABASE_URL",
        "sqlite:///" + os.path.join(basedir, "pill_db_admin.sqlite")
    )
    DEBUG = True

# Postgres in Cluster
class TestingConfig(Config):
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL")
    DEBUG = True
    TESTING = True

# AWS RDS
class ProductionConfig(Config):
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL")

config_dict = {
    "development": DevelopmentConfig,
    "testing": TestingConfig,
    "production": ProductionConfig,
}
