Package.describe({
    "summary": "Add feature flagging to Meteor"
});

Package.on_use(function (api) {
    api.use('coffeescript', ['server', 'client']);
    api.use('jquery', 'client');
    api.use('underscore', 'server');
    api.add_files('server/server_flag.coffee', 'server')
    api.add_files('client/client_flag.coffee', 'client')
});
