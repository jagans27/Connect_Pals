from flask import Blueprint, request, jsonify
from app.models.user import User, Friendship, Message
from app import db, socketio

bp = Blueprint('user', __name__)

@bp.route('/users', methods=['GET'])
def get_all_users():
    users = User.query.all() 
    users_data = []
    
    for user in users:
        users_data.append({
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'age': user.age,
            'intro': user.intro,
            'job': user.job,
            'country': user.country,
            'area': user.area,
            'description': user.description,
            'gender': user.gender
        })

    return jsonify({'status': 'success', 'data': users_data}), 200

@bp.route('/friends/request', methods=['POST'])
def send_friend_request():
    data = request.json
    requester = User.query.filter_by(email=data['requester_email']).first()
    recipient = User.query.filter_by(email=data['recipient_email']).first()

    if not requester or not recipient:
        return jsonify({'status': 'failure', 'message': 'User not found'}), 404

    existing_request = Friendship.query.filter_by(requester_id=requester.id, recipient_id=recipient.id).first()
    if existing_request:
        return jsonify({'status': 'failure', 'message': 'Friendship request already sent'}), 409

    new_request = Friendship(requester_id=requester.id, recipient_id=recipient.id)
    db.session.add(new_request)
    db.session.commit()

    send_initial_messages(requester, recipient)


    return jsonify({
        'status': 'success',
        'message': 'Friendship request sent',
        'data': {
            'requester': {
                'id': requester.id,
                'name': requester.name,
                'email': requester.email,
                'age': requester.age,
                'intro': requester.intro,
                'job': requester.job,
                'country': requester.country,
                'area': requester.area,
                'description': requester.description,
                'gender': requester.gender
            },
            'recipient': {
                'id': recipient.id,
                'name': recipient.name,
                'email': recipient.email,
                'age': recipient.age,
                'intro': recipient.intro,
                'job': recipient.job,
                'country': recipient.country,
                'area': recipient.area,
                'description': recipient.description,
                'gender': recipient.gender
            }
        }
    }), 201

def send_initial_messages(requester, recipient):
    requester_message = "Hey! Let’s kick off this friendship with a fun chat!"
    recipient_message = "Hey there! I’m all ears. What would you like to talk about?"

    new_message_from_requester = Message(sender_id=requester.id, recipient_id=recipient.id, content=requester_message)
    db.session.add(new_message_from_requester)
    db.session.commit()

    socketio.emit('new_message', {
        'sender_email': requester.email,
        'recipient_email': recipient.email,
        'content': requester_message,
        'timestamp': new_message_from_requester.timestamp.isoformat()
    }, room=recipient.email)

    print(f"Socket emitted message from {requester.email} to {recipient.email}")

    new_message_from_recipient = Message(sender_id=recipient.id, recipient_id=requester.id, content=recipient_message)
    db.session.add(new_message_from_recipient)
    db.session.commit()

    socketio.emit('new_message', {
        'sender_email': recipient.email,
        'recipient_email': requester.email,
        'content': recipient_message,
        'timestamp': new_message_from_recipient.timestamp.isoformat()
    }, room=requester.email)

    print(f"Socket emitted message from {recipient.email} to {requester.email}")

@bp.route('/friends/accept', methods=['POST'])
def accept_friend_request():
    data = request.json
    recipient = User.query.filter_by(email=data['recipient_email']).first()
    requester = User.query.filter_by(email=data['requester_email']).first()

    if not requester or not recipient:
        return jsonify({'status': 'failure', 'message': 'User not found'}), 404

    friendship = Friendship.query.filter_by(requester_id=requester.id, recipient_id=recipient.id, status='pending').first()
    if not friendship:
        return jsonify({'status': 'failure', 'message': 'No pending friendship request found'}), 404

    friendship.status = 'accepted'
    db.session.commit()

    return jsonify({
        'status': 'success',
        'message': 'Friendship request accepted',
        'data': {
            'requester': {
                'id': requester.id,
                'name': requester.name,
                'email': requester.email,
                'age': requester.age,
                'intro': requester.intro,
                'job': requester.job,
                'country': requester.country,
                'area': requester.area,
                'description': requester.description,
                'gender': requester.gender
            },
            'recipient': {
                'id': recipient.id,
                'name': recipient.name,
                'email': recipient.email,
                'age': recipient.age,
                'intro': recipient.intro,
                'job': recipient.job,
                'country': recipient.country,
                'area': recipient.area,
                'description': recipient.description,
                'gender': recipient.gender
            }
        }
    }), 200

@bp.route('/friends/pending-requests', methods=['POST'])
def get_pending_friend_requests():
    data = request.json
    user_email = data.get('email')
    user = User.query.filter_by(email=user_email).first()

    if not user:
        return jsonify({'status': 'failure', 'message': 'User not found'}), 404

    pending_requests = Friendship.query.filter_by(recipient_id=user.id, status='pending').all()

    requests_data = []
    for req in pending_requests:
        requester = User.query.get(req.requester_id)
        requests_data.append({
            'requester': {
                'id': requester.id,
                'name': requester.name,
                'email': requester.email,
                'age': requester.age,
                'intro': requester.intro,
                'job': requester.job,
                'country': requester.country,
                'area': requester.area,
                'description': requester.description,
                'gender': requester.gender
            }
        })

    return jsonify({'status': 'success', 'data': requests_data}), 200
@bp.route('/friends/list', methods=['POST'])
def get_friends_list():
    data = request.json
    user_email = data.get('email')
    user = User.query.filter_by(email=user_email).first()

    if not user:
        return jsonify({'status': 'failure', 'message': 'User not found'}), 404

    friendships = Friendship.query.filter(
        (Friendship.requester_id == user.id) | (Friendship.recipient_id == user.id)
    ).all()

    friends_data = []
    for friendship in friendships:
        if friendship.status == 'accepted':
            friend_id = friendship.recipient_id if friendship.requester_id == user.id else friendship.requester_id
            friend = User.query.get(friend_id)
            friends_data.append({
                'id': friend.id,
                'name': friend.name,
                'email': friend.email,
                'age': friend.age,
                'intro': friend.intro,
                'job': friend.job,
                'country': friend.country,
                'area': friend.area,
                'description': friend.description,
                'gender': friend.gender,
                'friendshipStatus': 'friends'
            })
        elif friendship.status == 'pending':
            friend_id = friendship.recipient_id if friendship.requester_id == user.id else friendship.requester_id
            friend = User.query.get(friend_id)
            friends_data.append({
                'id': friend.id,
                'name': friend.name,
                'email': friend.email,
                'age': friend.age,
                'intro': friend.intro,
                'job': friend.job,
                'country': friend.country,
                'area': friend.area,
                'description': friend.description,
                'gender': friend.gender,
                'friendshipStatus': 'pending'
            })

    return jsonify({'status': 'success', 'data': friends_data}), 200

@bp.route('/users/search', methods=['POST'])
def search_users():
    data = request.get_json() 
    query = data.get('query', '')
    user_email = data.get('email', '') 

    current_user = User.query.filter_by(email=user_email).first()
    if not current_user:
        return jsonify({'status': 'error', 'message': 'User not found'}), 404

    if query == "":
        users = User.query.filter(User.id != current_user.id).all()
    else:
        users = User.query.filter(
            User.name.ilike(f'%{query}%'),
            User.id != current_user.id
        ).all()

    friendships = Friendship.query.filter(
        (Friendship.requester_id == current_user.id) |
        (Friendship.recipient_id == current_user.id)
    ).all()

    friendship_status = {}
    for friendship in friendships:
        if friendship.requester_id == current_user.id:
            friendship_status[friendship.recipient_id] = 'request'
        elif friendship.recipient_id == current_user.id:
            friendship_status[friendship.requester_id] = 'pending'
        
        if friendship.status == 'accepted':
            friendship_status[friendship.requester_id] = 'friends'
            friendship_status[friendship.recipient_id] = 'friends'

    users_data = []
    for user in users:
        users_data.append({
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'age': user.age,
            'intro': user.intro,
            'job': user.job,
            'country': user.country,
            'area': user.area,
            'description': user.description,
            'gender': user.gender,
            'friendshipStatus': friendship_status.get(user.id, 'none') 
        })

    return jsonify({'status': 'success', 'data': users_data}), 200
