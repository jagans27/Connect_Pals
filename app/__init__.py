from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from sentence_transformers import SentenceTransformer
from flask_socketio import SocketIO
from flask_cors import CORS 

db = SQLAlchemy()
socketio = SocketIO(cors_allowed_origins='*',async_mode='eventlet') 
model = SentenceTransformer('all-MiniLM-L6-v2')

def create_app():
    app = Flask(__name__)
    app.config.from_object('config.Config')

    CORS(app, resources={r"/*": {"origins": "*"}})

    db.init_app(app)
    socketio.init_app(app)

    from .routes import ai, auth, user, chat
    app.register_blueprint(ai.bp)
    app.register_blueprint(auth.bp)
    app.register_blueprint(user.bp)
    app.register_blueprint(chat.bp)

    with app.app_context():
        db.create_all()
        print("-_-DB CREATED-_-")

    return app
