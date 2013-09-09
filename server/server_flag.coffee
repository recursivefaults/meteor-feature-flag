if Meteor.isServer
    flags = {} || Meteor.settings.featureFlags
    flagHandlers = {}
    @FeatureFlag = {}
    @FeatureFlag.registerFlagHandler = (identifier, handler) ->
        flagHandlers[identifier] = handler
    @FeatureFlag.featureFlag = (flagType) ->
        val = flags[flagType]
        for identifier, handler in flagHandlers
            return true if handler(val) == true
        return false

    ###
    # Add a feature flag handler for email domains
    #
    # This would look like  {flag: ['gmail.com']} or {flag: 'gmail.com'}
    ###
    @FeatureFlag.registerFlagHandler("email-domains", (val) ->
        user = Meteor.user()
        return false if !user?
        email = getEmail(user)
        return false if !email?
        filterset = if _.isArray(val.email_domains) then val.email_domains else [val.email_domains]
        valid = (item for item in filterset when email.search(item) > 0)
        if valid.length > 0 then return true else return false
    )
    ###
    # Add a feature flag for users based on email
    #
    # This would look like {flag: ['bob@loblaw.com']} or {flag:
    # 'support@faceblock.com'}
    ###
    @FeatureFlag.registerFlagHandler('users', (val) ->
        user = Meteor.user()
        return false if !user?
        email = getEmail(user)
        return false if !email?
        filterset = if _.isArray(val.users) then val.users else [val.users]
        valid = (item for item in filterset when email == item)
        if valid.length > 0 then return true else return false

    )
    ###
    # Simple boolean flag for features
    #
    # This would look like {flag: true} or {flag: false}
    ###
    @FeatureFlag.registerFlagHandler('onOff', (val) ->
        return val
    )

    getEmail = (user) ->
        if user.emails?
            user.emails[0].address
        else if user.services?.google?
            user.services.google.email

  Meteor.methods(
      flagsForUser: () ->
        final = {}
        for k, v of flags
            final[k] = @FeatureFlag.featureFlag(k)
        return final
  )
