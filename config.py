import os
# from os.path import join, dirname
from dotenv import load_dotenv, find_dotenv

# ---------Get secrets form .env file
load_dotenv(find_dotenv())

#----------Create Config class for app
class Config(object):
    SECRET_KEY = os.getenv("secret_key")
    SQLALCHEMY_DATABASE_URI = ''  # DevelopmentConfig or TestingConfig add URI to database
    SQLALCHEMY_TRACK_MODIFICATIONS = False

#---------Configuration for Developing - host:localhost (PostgreSQL database on local server)
class DevelopmentConfig(Config):
    # PostgreSQL database
    username_postdb = os.getenv("postgreSQL_username")
    password_postdb = os.getenv("postgreSQL_password")
    database_postdb = os.getenv("postgreSQL_database")
    host_postdb = os.getenv("postgreSQL_host")
    SQLALCHEMY_DATABASE_URI= f"postgresql://{username_postdb}:{password_postdb}@{host_postdb}/{database_postdb}"
    DEBUG = True

# -------------------------Configuration for testing (SQLite database)
class TestingConfig(Config):
    # #SQLite database
    basedir = os.path.abspath(os.path.dirname(__file__))
    SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(basedir, 'pill_db.sqlite')
    DEBUG = True
    TESTING = True

#---------Configuration for production (PostgreSQL database - AWS RDS)
class ProductionConfig(Config):
    AWS_DB_HOST = os.getenv('DB_HOST')
    AWS_DB_USERNAME = os.getenv('DB_USERNAME')
    AWS_DB_PASSWORD = os.getenv('DB_PASSWORD')
    AWS_DB_NAME = os.getenv('DB_NAME')

# ----------------------Config dict
config_dict = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig
}