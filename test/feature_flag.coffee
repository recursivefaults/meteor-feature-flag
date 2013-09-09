###
# Scaffolding tests
###
Tinytest.add "FeatureFlag - isServer Test", (test) ->
    test.equal(Meteor.isServer, true, "Meteor should be testing on server")

Tinytest.add "FeatureFlag - Import Test", (test) ->
    test.equal(FeatureFlag?, true, "FeatureFlag object should be available")

Tinytest.add "FeatureFlag - Configuration Test ", (test) ->
    test.equal(FeatureFlag.featureFlag("waffles"), false, "Gracefully return false for invalid flag")

Tinytest.add "FeatureFlag - Flag with no handler returns false", (test) ->
    Meteor.settings["featureFlags"] = {"monkeys": "Something"}
    test.equal(FeatureFlag.featureFlag("monkeys"), false, "Invalid handler should return false")
###
# Register new handler
###
Tinytest.add "FeatureFlag - Add new handler", (test) ->
    FeatureFlag.registerFlagHandler('monkey', (flag) ->
        return true if flag.monkey?
        return false
    )
    Meteor.settings['featureFlags'] = {'waffles': monkey: {}}
    test.equal(FeatureFlag.featureFlag('waffles'), true, "New handler should return true")
    Meteor.settings['featureFlags'] = {'waffles': bananas: {}}
    test.equal(FeatureFlag.featureFlag('waffles'), false, "New handler should return false")

###
# Flag on/off tests
###
Tinytest.add "FeatureFlag - onOff Test", (test) ->
    Meteor.settings["featureFlags"] = {"waffles": true}
    test.equal(FeatureFlag.featureFlag("waffles"), true, "User test should pass")

Tinytest.add "FeatureFlag - onOff Test (Negative)", (test) ->
    Meteor.settings["featureFlags"] = {"waffles": false}
    test.equal(FeatureFlag.featureFlag("waffles"), false, "User test should be false")
    Meteor.settings["featureFlags"] = {"waffles": 3}
    test.equal(FeatureFlag.featureFlag("waffles"), false, "User test should be false")

    Meteor.settings["featureFlags"] = {"waffles": "Monkeys"}
    test.equal(FeatureFlag.featureFlag("waffles"), false, "User test should be false")

###
# User feature flag handler tests
###
Tinytest.add "FeatureFlag - user Test", (test) ->
    Meteor.settings["featureFlags"] = {"waffles": users: 'bob@loblaw.com'}
    Meteor.user = () ->
        {emails: [address: 'bob@loblaw.com']}
    test.equal(FeatureFlag.featureFlag("waffles"), true, "bob@loblaw.com should be valid")
    Meteor.user = () ->
        {emails: [{address: 'lawblog@loblaw.com'}, {address: 'bob@loblaw.com'}]}
    test.equal(FeatureFlag.featureFlag("waffles"), true, "Emails other than first should be valid")

    Meteor.user = () ->
        {services: google: email:'bob@loblaw.com'}
    test.equal(FeatureFlag.featureFlag("waffles"), true, "bob@loblaw.com should be valid (Google)")

Tinytest.add "FeatureFlag - user Test (Negative)", (test) ->
    Meteor.settings["featureFlags"] = {"waffles": users: 'support@faceblock.com'}
    Meteor.user = () ->
        {emails: [address: 'bob@loblaw.com']}
    test.equal(FeatureFlag.featureFlag("waffles"), false, "bob@loblaw.com should NOT be valid")
    Meteor.user = () ->
        {emails: [{address: 'lawblog@loblaw.com'}, {address: 'bob@loblaw.com'}]}
    test.equal(FeatureFlag.featureFlag("waffles"), false, "Multiple emails that don't match fails")
    Meteor.user = () ->
        {services: google: email:'bob@loblaw.com'}
    test.equal(FeatureFlag.featureFlag("waffles"), false, "bob@loblaw.com should NOT be valid (Google)")

###
# Email domain tests
###
Tinytest.add "FeatureFlag - Email Domain test", (test) ->
    Meteor.settings["featureFlags"] = {"waffles": email_domains: 'loblaw.com'}
    Meteor.user = () ->
        {emails: [address: 'bob@loblaw.com']}
    test.equal(FeatureFlag.featureFlag("waffles"), true, "bob@loblaw.com should be valid")
    Meteor.user = () ->
        {emails: [{address: 'lawblog@lawblog.com'}, {address: 'bob@loblaw.com'}]}
    test.equal(FeatureFlag.featureFlag("waffles"), true, "Emails other than first should be valid")

    Meteor.user = () ->
        {emails: [{address: 'bob@loblaw.com'},{address: 'lawblog@lawblog.com'}]}
    test.equal(FeatureFlag.featureFlag("waffles"), true, "Emails other than first should be valid")
    Meteor.user = () ->
        {services: google: email:'bob@loblaw.com'}
    test.equal(FeatureFlag.featureFlag("waffles"), true, "bob@loblaw.com should be valid (Google)")
Tinytest.add "FeatureFlag - Email Domain test (Array)", (test) ->
    Meteor.settings['featureFlags'] = {"waffles": email_domains: ['faceblock.com', 'loblaw.com']}
    Meteor.user = () ->
        emails: [ {address: "bob@loblaw.com"}]
    test.equal(FeatureFlag.featureFlag("waffles"), true, "multiple email domains should be fine")
    Meteor.user = () ->
        emails: [ {address: "bob@faceblock.com"}]
    test.equal(FeatureFlag.featureFlag("waffles"), true, "multiple email domains should be fine")
    Meteor.user = () ->
        emails: [ {address: "george@michael.com"}]
    test.equal(FeatureFlag.featureFlag("waffles"), false, "deny when multiple domains fail to match")

Tinytest.add "FeatureFlag - Email Domain test (Negative)", (test) ->
    Meteor.settings["featureFlags"] = {"waffles": email_domains: 'faceblock.com'}
    Meteor.user = () ->
        {emails: [address: 'bob@loblaw.com']}
    test.equal(FeatureFlag.featureFlag("waffles"), false, "bob@loblaw.com should NOT be valid")
    Meteor.user = () ->
        {emails: [{address: 'lawblog@gmail.com'}, {address: 'bob@loblaw.com'}]}
    test.equal(FeatureFlag.featureFlag("waffles"), false, "Multiple emails that don't match fails")
    Meteor.user = () ->
        {services: google: email:'bob@loblaw.com'}
    test.equal(FeatureFlag.featureFlag("waffles"), false, "bob@loblaw.com should NOT be valid (Google)")
