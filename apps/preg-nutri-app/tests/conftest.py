import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
import pytest
from pregnant_pills_app import app, db
from pregnant_pills_app.models import User
from config import config_dict


@pytest.fixture
def test_app():
    app.config.from_object(config_dict["testing"])
    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    
    with app.app_context():
        db.create_all()
        yield app
        db.session.remove()
        db.drop_all()

@pytest.fixture
def client(test_app):
    return test_app.test_client()

@pytest.fixture
def new_user(test_app):
    user = User(
        name="TestUser",
        surname="TestSurname",
        email="test@example.com",
        preg_week=12,            
        password="testpassword"  
    )
    db.session.add(user)
    db.session.commit()
    return user