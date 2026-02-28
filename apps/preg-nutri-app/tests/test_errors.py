def test_404_page(client):
    response = client.get('/nonexistent-page')
    assert response.status_code == 404
    assert b"Page Not Found" in response.data