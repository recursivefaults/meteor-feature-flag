if Meteor.isClient
    UI.registerHelper('featureFlag', () ->
        flag = @valueOf()
        flags = Session.get('flags')
        if flags and flag of flags and flags[flag] == true
          Template._featureFlag
        else
          null
    )
    Deps.autorun () ->
        if Meteor.userId()?
            #Set your flagging
            Meteor.call('flagsForUser', (err, results) ->
                Session.set('flags', results)
            )
