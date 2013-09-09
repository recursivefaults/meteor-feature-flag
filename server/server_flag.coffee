if Meteor.isServer
    flags = {} || Meteor.settings.featureFlags

    @featureFlag = (flag) ->

       val = flags[flag]
       return true if val is null or val is undefined
       user = Meteor.user()
       filterset = []
       final = false

       if val.email_domains?
           logger.info "Flag #{flag} on email"
           return false if !user?
           email = getEmail user
           return false if !email?
           filterset = if _.isArray(val.email_domains) then val.email_domains else [val.email_domains]
           valid = (item for item in filterset when email.search(item) > 0)
           final = true if valid.length > 0
      if val.schools?
           logger.info "Flag #{flag} on schools"
           return false if !user?
           filterset = if _.isArray(val.schools) then val.schools else [val.schools]
           for school in user.schools
               valid = (item for item in filterset when item is school.name)
           final = true if valid.length > 0
      if val.users?
           logger.info "Flag #{flag} for specific users"
           return false if !user?
           email = getEmail user
           return false if !email?
           filterset = if _.isArray(val.users) then val.users else [val.users]
           valid = (item for item in filterset when email == item)
           final = true if valid.length > 0
      if val == "admins"
           logger.info "Flag #{flag} on admins"
           return user?.rights?.admin? == true
      if val == true or val == false
           logger.info "Flag #{flag} on/off"
           return val
      return final

    getEmail = (user) ->
        if user.emails?
            user.emails[0].address
        else if user.services?.google?
            user.services.google.email

    flagsForUser = () ->
        final = {}
        for k, v of flags
            final[k] = featureFlag(k)
        return final

  Meteor.methods(
      flagsForUser: () ->
          return flagsForUser()
  )
