from flask import request, jsonify
from app import model
from app.models.user import User, Friendship 
import numpy as np
from sentence_transformers import util

def calculate_similarity():
    data = request.json
    user_email = data.get('email')

    if not user_email:
        return jsonify({'status': 'failure', 'data': None, 'message': 'Email is required'}), 400

    user = User.query.filter_by(email=user_email).first()
    if not user:
        return jsonify({'status': 'failure', 'data': None, 'message': 'User not found'}), 404

    friendships = Friendship.query.filter(
        (Friendship.requester_id == user.id) |
        (Friendship.recipient_id == user.id)
    ).all()

    friendship_status = {}
    for friendship in friendships:
        if friendship.status == 'accepted':
            friendship_status[friendship.requester_id] = 'friends'
            friendship_status[friendship.recipient_id] = 'friends'
        elif friendship.requester_id == user.id:
            friendship_status[friendship.recipient_id] = 'request'
        elif friendship.recipient_id == user.id:
            friendship_status[friendship.requester_id] = 'pending'

    other_users = User.query.filter(User.id != user.id).all()

    if not other_users:
        return jsonify({'status': 'success', 'data': [], 'message': 'No other users to compare against'}), 200

    def combine_details(user):
        return f"{user.age or ''} {user.intro or ''} {user.job or ''} {user.country or ''} {user.area or ''} {user.description or ''}"

    user_details = combine_details(user)
    other_user_details = [combine_details(other_user) for other_user in other_users]

    user_embedding = model.encode([user_details], convert_to_tensor=True)
    other_user_embeddings = model.encode(other_user_details, convert_to_tensor=True)

    cosine_similarities = util.pytorch_cos_sim(user_embedding, other_user_embeddings)
    sorted_indices = np.argsort(-cosine_similarities[0])

    results = []
    for i in sorted_indices:
        other_user = other_users[i]
        similarity_score = cosine_similarities[0][i].item()
        matching_percentage = similarity_score * 100

        if friendship_status.get(other_user.id) != 'friends':
            results.append({
                'user': {
                    'name': other_user.name,
                    'email': other_user.email,
                    'age': other_user.age,
                    'intro': other_user.intro,
                    'job': other_user.job,
                    'country': other_user.country,
                    'area': other_user.area,
                    'description': other_user.description,
                    'gender': other_user.gender,
                    'friendshipStatus': friendship_status.get(other_user.id, 'none') 
                },
                'matching_percentage': matching_percentage,
            })

    return jsonify({'status': 'success', 'data': results[:6], 'message': 'Fetched successfully'}), 200
