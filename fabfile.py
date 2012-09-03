from fabric.api import run, local, cd, hosts, put


def stage():
    local("git push live master:staging")


def build():
    local("hem build")


@hosts('data-story@data-story.org:712')
def deploy():
    build()
    stage()
    with cd("git"):
        run("git merge --ff-only staging")
    put("public/application.js", "/tmp/application.js")
    run("mv /tmp/application.js static/application.js")
    run("kill -HUP `cat /home/data-story/gunicorn.pid`")
