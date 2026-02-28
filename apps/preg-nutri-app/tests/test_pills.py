from flask_login import login_user
from pregnant_pills_app.models import Pill, User

def test_category_pill_get(client, new_user):
    with client.session_transaction() as sess:
        sess['user_id'] = new_user.id
    
    response = client.get('/pregnant-pill/category_pill')
    assert response.status_code == 200
    assert b'CategoryPillForm' in response.data 

def test_add_pill_post(client, new_user):
    with client.session_transaction() as sess:
        sess['user_id'] = new_user.id
    
    response = client.post(
        '/pregnant-pill/add_pill?html_category_pill=vitamins',
        data={
            'name': 'Vitamin C',
            'amount': 1,
            'reason': 'Immune boost',
            'date_start': '2025-10-01',
            'date_end': '2025-10-10'
        },
        follow_redirects=True
    )
    assert response.status_code == 200
    pill = Pill.query.filter_by(name='Vitamin C', user_id=new_user.id).first()
    assert pill is not None