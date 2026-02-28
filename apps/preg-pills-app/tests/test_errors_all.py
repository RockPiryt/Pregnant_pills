def test_400_error(client):
    response = client.get('/non_existing_route')
    # w normalnym projekcie możesz stworzyć endpoint testowy, który rzuca abort(400)
    assert response.status_code == 400
 

def test_401_error(client):
    @client.application.route("/unauthorized_test")
    def unauthorized_route():
        from flask import abort
        abort(401)
    response = client.get("/unauthorized_test")
    assert response.status_code == 401
    assert b"401" in response.data

def test_404_error(client):
    response = client.get("/non_existing_page")
    assert response.status_code == 404
    assert b"Page Not Found" in response.data

def test_415_error(client):
    @client.application.route("/unsupported_media_test", methods=["POST"])
    def unsupported_media_route():
        from flask import abort
        abort(415)
    response = client.post("/unsupported_media_test")
    assert response.status_code == 415
    assert b"415" in response.data

def test_500_error(client):
    @client.application.route("/internal_error_test")
    def internal_error_route():
        raise Exception("Test internal server error")
    response = client.get("/internal_error_test")
    assert response.status_code == 500
    assert b"500" in response.data