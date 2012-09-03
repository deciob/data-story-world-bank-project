import json
import requests
from functools import wraps

from models import app, db, Config, User
from flask import (request, session, current_app, render_template, Response)
from sqlalchemy.orm.exc import NoResultFound


def _json_response(response):
    return current_app.response_class(
        json.dumps(response),
        mimetype="application/json")


def get_user():
    if 'id' not in session or 'email' not in session:
        return None

    return (User.query
            .filter(User.id == session['id'])
            .filter(User.email == session['email'])
            .first())


def with_user(view):
    @wraps(view)
    def inner(*args, **kwargs):
        user = get_user()
        if user is None:
            return Response(status=403)
        return view(user, *args, **kwargs)
    return inner


@app.route('/')
def home():
    configs = Config.query.order_by(Config.timestamp.desc()).limit(6).all()
    return render_template('index.html', user=get_user(), configs=configs)
    
    
@app.route('/vote')
def vote():
    #configs = Config.query.order_by(Config.timestamp.desc()).limit(6).all()
    return render_template('vote.html')



@app.route('/v1/app')
def edit():
    return render_template(
        'app.html',
        user=get_user(),
        debug=current_app.debug)


@app.route('/login', methods=["POST"])
def login():
    if not request.form['assertion']:
        return Response("No assertion", status=400)

    response = requests.post(
        'https://browserid.org/verify',
        {'audience': request.headers['ORIGIN'],
         'assertion': request.form['assertion']})
    verify = json.loads(response.text)

    if verify['status'] != "okay":
        return Response("Login failed", status=403)

    try:
        user = User.query.filter(User.email == verify['email']).one()
    except NoResultFound:
        user = User(verify['email'])
        db.session.add(user)
        db.session.commit()

    session['id'] = user.id
    session['email'] = user.email
    return user.email


@app.route('/logout', methods=["POST"])
def logout():
    del session['id']
    del session['email']
    return Response(status=200)


@app.route('/config/', methods=["GET", "POST"])
@with_user
def config_list(user):
    if request.method == "GET":
        configs = [c.json() for c in user.configs]
        return _json_response(configs)
    elif request.method == "POST":
        if request.json is None:
            return Response(status=400)
        c = Config(user, request.json)
        db.session.add(c)
        db.session.commit()
        return _json_response(c.json())


@app.route('/config/<cid>', methods=["GET", "PUT", "DELETE"])
@with_user
def config_item(user, cid):
    config = (Config.query
              .filter(Config.user_id == user.id)
              .filter(Config.id == cid))
    if request.method == "PUT":
        if request.json is None:
            return Response(status=400)
        try:
            config = config.one()
            config.update(request.json)
        except NoResultFound:
            config = Config(user, request.json)
            db.session.add(config)
        db.session.commit()
        return _json_response(config.json())
    elif request.method == "DELETE":
        try:
            db.session.delete(config.one())
            db.session.commit()
        except NoResultFound:
            pass
        return Response(status=200)
    elif request.method == "GET":
        return _json_response(config.first_or_404().json())


@app.route('/user/<uid>/<cid>')
def user_item(uid, cid):
    config = (Config.query
              .filter(Config.user_id == uid)
              .filter(Config.id == cid))
    return _json_response(config.first_or_404().json())


if __name__ == '__main__':
    # debug settings
    app.config['SECRET_KEY'] = "debugkey"

    db.create_all()
    app.run(host="localhost", port=5000, debug=True)
