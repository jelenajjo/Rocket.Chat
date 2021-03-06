Meteor.startup ->
	UserPresence.awayTime = 300000
	UserPresence.start()
	Meteor.subscribe("activeUsers")

	Session.setDefault('flexOpened', false)
	Session.setDefault('AvatarRandom', 0)

	window.lastMessageWindow = {}
	window.lastMessageWindowHistory = {}

	@defaultUserLanguage = ->
		lng = window.navigator.userLanguage || window.navigator.language || 'en'
		# Fix browsers having all-lowercase language settings eg. pt-br, en-us
		re = /([a-z]{2}-)([a-z]{2})/
		if re.test lng
			lng = lng.replace re, (match, parts...) -> return parts[0] + parts[1].toUpperCase()
		return lng

	languageComputation = Tracker.autorun ->
		if Meteor.user()?.language
			userLanguage = Meteor.user().language
			languageComputation.stop()
		else
			userLanguage = defaultUserLanguage()
		localStorage.setItem("userLanguage", userLanguage)

		userLanguage = userLanguage.split('-').shift()
		TAPi18n.setLanguage(userLanguage)

		filename = "/moment-locales/#{userLanguage.toLowerCase()}.js"
		if filename isnt '/moment-locales/en.js'
			$.getScript filename, (data) ->
				moment.locale(userLanguage)
