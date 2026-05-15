import pytest
from app import app

@pytest.fixture
def client():
    # This sets up a "virtual" version of your app for testing
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_hello_world(client):
    """Test that the home page returns the correct greeting."""
    response = client.get('/')
    assert response.status_code == 200
    assert b"Hello, JUDITH!" in response.data