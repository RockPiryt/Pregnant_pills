def test_create_user(new_user):
    user = new_user
    assert user.id is not None  
    assert user.name == "TestUser"
    assert user.surname == "TestSurname"
    assert user.email == "test@example.com"
    assert user.preg_week == 12
    assert user.password == "testpassword"