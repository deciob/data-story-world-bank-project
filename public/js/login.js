$(function () {
    $("#logout-link").click(function (e) {
        var link = $(this);
        e.preventDefault();
        $.post('/logout', function () {
            location.reload(true);
        });
    });

    $("#login-link, #project-login-link").click(function (e) {
        var link = $(this);
        e.preventDefault();
        navigator.id.get(function(assertion) {
            if (assertion) {
                $.post('/login', {assertion: assertion}, function (email) {
                    location.reload(true);
                });
            } else {
                // Something went wrong.
            }
        });
    });
});
