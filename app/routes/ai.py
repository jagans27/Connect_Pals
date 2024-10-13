from flask import Blueprint
from app.services.similarity import calculate_similarity

bp = Blueprint('ai', __name__)

@bp.route('/similarity', methods=['POST'])
def similarity():
    return calculate_similarity()