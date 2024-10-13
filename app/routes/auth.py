from flask import Blueprint, request, jsonify
from app.models.user import User
from app import db
from werkzeug.security import generate_password_hash, check_password_hash

bp = Blueprint('auth', __name__)

@bp.route('/users/signup', methods=['POST'])
def signup():
    data = request.json
    if User.query.filter_by(email=data['email']).first():
        return jsonify({'status': 'failure', 'data': None, 'message': 'Email already in use'}), 409

    hashed_password = generate_password_hash(data['password'])
    new_user = User(
        name=data['name'],
        email=data['email'],
        password=hashed_password,
        age=data.get('age'),
        intro=data.get('intro'),
        job=data.get('job'),
        country=data.get('country'),
        area=data.get('area'),
        description=data.get('description'),
        gender = data.get('gender')
    )
    db.session.add(new_user)
    db.session.commit()

    return jsonify({'status': 'success', 'data': data}), 201

@bp.route('/users/login', methods=['POST'])
def login():
    data = request.json
    user = User.query.filter_by(email=data['email']).first()

    if user and check_password_hash(user.password, data['password']):
        return jsonify({'status': 'success', 'data': {
            'name': user.name,
            'email': user.email,
            'age': user.age,
            'intro': user.intro,
            'job': user.job,
            'country': user.country,
            'area': user.area,
            'description': user.description,
            'gender' : user.gender
        }}), 200

    return jsonify({'status': 'failure', 'data': None, 'message': 'Invalid email or password'}), 401


@bp.route('/users/update', methods=['PUT'])
def update():
    data = request.json
    user = User.query.filter_by(email=data['email']).first()

    if not user:
        return jsonify({'status': 'failure', 'data': None, 'message': 'User not found'}), 404

    user.name = data.get('name', user.name)
    user.age = data.get('age', user.age)
    user.intro = data.get('intro', user.intro)
    user.job = data.get('job', user.job)
    user.country = data.get('country', user.country)
    user.area = data.get('area', user.area)
    user.description = data.get('description', user.description)
    user.gender = data.get('gender', user.gender)

    if 'password' in data and data['password']:
        user.password = generate_password_hash(data['password'])

    db.session.commit()

    return jsonify({'status': 'success', 'data': {
        'name': user.name,
        'email': user.email,
        'age': user.age,
        'intro': user.intro,
        'job': user.job,
        'country': user.country,
        'area': user.area,
        'description': user.description,
        'gender': user.gender
    }}), 200