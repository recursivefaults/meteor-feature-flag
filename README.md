meteor-feature-flag
===================

Simple feature flags for Meteor applications


Usage
-----
In your templates you can use the `featureFlag` handlebars helper
enable/disable certain areas or features of your application.

This would look something like this

`{{#featureFlag "newFeature"}}
<!--- whatever new feature is --!>
{{/featureFlag}}`

Configuration
-------------

### Server
The server is where most of the configuration for this lives. This, while
slightly less convenient is a little safer to do.

The feature flagging configuration should be stored
Meteor.settings.featureFlag. That means that whenever you use this package, you
should run Meteor with a settings file to actually have feature flagging work.

Now, by default we packaged a few simple feature flag options, but it's likely
you may have some more application specific needs. So we created a way for you
to add new ways to feature flag.

To do this, you can call the `FeatureFlag.registerFeatureFlag` method which
takes two parameters: `identifier` and `handler`. The identifier is just an
internal identifier. The handler is the function that will actually do the
flagging. It accepts one parameter which is the json object representing those
feature flags.

For example, if you have a feature flag configuration that looks like this
`featureFlags: { "adminWidget": {"users": "bob@loblaw.com"}}`
Then the handler will be called with the first parameter being populated with:
`{"users": "bob@loblaw.com"}`

It is your responsibility to verify that the type of feature flagging is valid
for your handler. Only return true if you want your handler to enable that
feature. Return false otherwise

