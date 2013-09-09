if Meteor.isClient
    Handlebars.registerHelper('featureFlag', (flag,options) ->
        flags = Session.get('flags')
        if flags and flag of flags and flags[flag] == true
            options.fn(@)
    )
    Deps.autorun () ->
        if Meteor.userId()?
            #Set your flagging
            Meteor.call('flagsForUser', (err, results) ->
                Session.set('flags', results)
            )
