import json
from datetime import datetime
from flask import Flask
from flaskext.sqlalchemy import SQLAlchemy

app = Flask(__name__)

# Default test database. It's useful to have it here so we can explore
# the database on the python shell by importing this file.
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:////tmp/test.db'

db = SQLAlchemy(app)


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(250), unique=True)

    def __init__(self, email):
        self.email = email

    def __repr__(self):
        return '<User %d %s>' % (self.id, self.email)


class Config(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    data = db.Column(db.Text)
    shared = db.Column(db.Boolean, default=False)
    front_page = db.Column(db.Boolean, default=False)
    user_id = db.Column(db.Integer, db.ForeignKey(User.id))
    timestamp = db.Column(db.DateTime)

    user = db.relationship(User, backref='configs')

    def json(self):
        d = json.loads(self.data)
        d['id'] = self.id
        d['user_id'] = self.user_id
        d['shared'] = self.shared
        d['front_page'] = self.front_page
        return d

    def update(self, data):
        self.data = json.dumps(data)
        self.shared = data.get('shared')

    def __init__(self, user, data):
        self.user_id = user.id
        self.timestamp = datetime.now()
        self.update(data)
