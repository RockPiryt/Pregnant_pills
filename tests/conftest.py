import pytest
from pregnant_pills_app import app, db
from pregnant_pills_app.models import User

@pytest.fixture
def test_app():
    app.config.from_object('config.config_dict["testing"]')
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
def new_user():
    user = User(name="TestUser", email="test@example.com")
    db.session.add(user)
    db.session.commit()
    return user