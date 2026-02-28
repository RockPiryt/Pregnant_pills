def test_index_page(client):
    """Test index page loads correctly."""
    response = client.get('/')
    assert response.status_code == 200
    assert b'Pregnant' in response.data  