Package.describe({
    "summary": "Add feature flagging to Meteor"
});

Package.on_use(function (api) {
    api.use('coffeescript', ['server', 'client']);
    api.use(['deps','ui','templating', 'jquery'], 'client');
    api.use('underscore', 'server');
    api.use('accounts-base', ['client'])
    api.add_files('server/server_flag.coffee', 'server')
    api.add_files('client/client_flag.coffee', 'client')
    if (typeof api.export !== 'undefined'){ 
        api.export('FeatureFlag', 'server');
    }
  
});

Package.on_test(function(api) {
    api.use('coffeescript', ['server', 'client']);
    api.use(['meteor-feature-flag',"tinytest", "test-helpers"])
    api.use('underscore', 'server');
    api.add_files('test/feature_flag.coffee', 'server')
});
