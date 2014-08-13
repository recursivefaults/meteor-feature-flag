if Meteor.isServer
    flagHandlers = {}
    FeatureFlag = {}
    FeatureFlag.registerFlagHandler = (identifier, handler) ->
       flagHandlers[identifier] = handler
    FeatureFlag.featureFlag = (flagType) ->
        flags = Meteor.settings.featureFlags || {}
        val = flags[flagType]
        return false if !val?
        for identifier, handler of flagHandlers
            return true if handler(val) == true
        return false

    ###
    # Add a feature flag handler for email domains
    #
    # This would look like  {flag: ['gmail.com']} or {flag: 'gmail.com'}
    ###
    FeatureFlag.registerFlagHandler("email-domains", (val) ->
        return false if !val.email_domains?
        user = Meteor.user()
        return false if !user?
        email = getEmail(user)
        email = [email] if !_.isArray(email)
        return false if !email?
        filterset = if _.isArray(val.email_domains) then val.email_domains else [val.email_domains]
        for e in email
            valid = (item for item in filterset when e.search(item) > 0)
            return true if valid.length > 0
        return false
    )
    ###
    # Add a feature flag for users based on email
    #
    # This would look like {flag: ['bob@loblaw.com']} or {flag:
    # 'support@faceblock.com'}
    ###
    FeatureFlag.registerFlagHandler('users', (val) ->
        return false if !val.users?
        user = Meteor.user()
        return false if !user?
        email = getEmail(user)
        email = [email] if !_.isArray(email)
        return false if !email?
        filterset = if _.isArray(val.users) then val.users else [val.users]
        valid = []
        for e in email
            return true if _.contains(filterset, e)
        return false
    )
    ###
    # Simple boolean flag for features
    #
    # This would look like {flag: true} or {flag: false}
    ###
    FeatureFlag.registerFlagHandler('onOff', (val) ->
        return val if val == true or val == false
        return false
    )

    getEmail = (user) ->
        if user.emails?
            _.pluck(user.emails, 'address')
        else if user.services?.google?
            [user.services.google.email]

  Meteor.methods
      flagsForUser: () ->
        final = {}
        flags = Meteor.settings.featureFlags || {}
        for k, v of flags
            final[k] = FeatureFlag.featureFlag(k)
        return final
  return FeatureFlag
