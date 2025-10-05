def test_404_page(client):
    response = client.get('/nonexistent-page')
    assert response.status_code == 404
    assert b'404' in response.data