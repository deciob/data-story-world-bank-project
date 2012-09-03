'''Production WSGI app. Run with gunicorn.'''
import logging
from logging.handlers import TimedRotatingFileHandler

from datastory import app

app.config.update({
        'SECRET_KEY': '3\r\xe2f\xd4\xa1\x94V\xccC\xf1i\xa6t\xe9\x01\x1fIh^*)\xcaX',
        'SQLALCHEMY_DATABASE_URI': 'postgresql:///data-story',
        })


def filelog(filename, level):
    path = "/var/log/data-story/%s.log" % filename
    handler = TimedRotatingFileHandler(
        filename=path,
        when="D",
        interval=5,
        backupCount=4)
    handler.setLevel(level)
    return handler

app.logger.addHandler(filelog("info", logging.INFO))
app.logger.addHandler(filelog("error", logging.ERROR))

application = app.wsgi_app

if __name__ == '__main__':
    app.run()
