from flask import Blueprint, request, jsonify
from flask_socketio import emit, join_room, leave_room
from app.models.user import Message, User
from app import socketio, db

bp = Blueprint('chat', __name__)

@bp.route('/chat/send', methods=['POST'])
def send_message():
    data = request.json
    sender_email = data.get('sender_email')
    recipient_email = data.get('recipient_email')
    content = data.get('content')

    sender = User.query.filter_by(email=sender_email).first()
    recipient = User.query.filter_by(email=recipient_email).first()

    if not sender or not recipient:
        return jsonify({'status': 'failure', 'message': 'User not found'}), 404

    new_message = Message(sender_id=sender.id, recipient_id=recipient.id, content=content)
    db.session.add(new_message)
    db.session.commit()


    socketio.emit('new_message', {
        'sender_email': sender_email,
        'recipient_email': recipient_email,
        'content': content,
        'timestamp': new_message.timestamp.isoformat() 
    }, room=recipient.email)  


    return jsonify({'status': 'success', 'message': 'Message sent successfully'}), 201

@bp.route('/chat/messages', methods=['POST'])
def get_messages():
    data = request.json
    sender_email = data.get('sender_email')
    recipient_email = data.get('recipient_email')

    sender = User.query.filter_by(email=sender_email).first()
    recipient = User.query.filter_by(email=recipient_email).first()

    if not sender or not recipient:
        return jsonify({'status': 'failure', 'message': 'User not found'}), 404

    if sender.email != sender_email or recipient.email != recipient_email:
        return jsonify({'status': 'failure', 'message': 'Invalid user data'}), 400

    messages = Message.query.filter(
        ((Message.sender_id == sender.id) & (Message.recipient_id == recipient.id)) |
        ((Message.sender_id == recipient.id) & (Message.recipient_id == sender.id))
    ).order_by(Message.timestamp).all()

    messages_data = [{
        'sender_email': msg.sender.email,  
        'recipient_email': msg.recipient.email, 
        'content': msg.content,
        'timestamp': msg.timestamp.isoformat()  
    } for msg in messages]

    return jsonify({'status': 'success', 'data': messages_data}), 200

@socketio.on('connect')
def handle_connect():
    print('User connected:', request.sid)

@socketio.on('disconnect')
def handle_disconnect():
    print('User disconnected:', request.sid)

@socketio.on('join')
def handle_join(data):
    user_id = data['user_id']
    join_room(user_id)  
    print(f'User {user_id} has entered the room.')

@socketio.on('leave')
def handle_leave(data):
    user_id = data['user_id']
    leave_room(user_id) 
    print(f'User {user_id} has left the room.')
