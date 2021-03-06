Template.body.onRendered ->

	dataLayerComputation = Tracker.autorun ->
		w = window
		d = document
		s = 'script'
		l = 'dataLayer'
		i = RocketChat.settings.get 'API_Analytics'
		if Match.test(i, String) and i.trim() isnt ''
			dataLayerComputation?.stop()
			do (w,d,s,l,i) ->
				w[l] = w[l] || []
				w[l].push {'gtm.start': new Date().getTime(), event:'gtm.js'}
				f = d.getElementsByTagName(s)[0]
				j = d.createElement(s)
				dl = if l isnt 'dataLayer' then '&l=' + l else ''
				j.async = true
				j.src = '//www.googletagmanager.com/gtm.js?id=' + i + dl
				f.parentNode.insertBefore j, f

	metaLanguageComputation = Tracker.autorun ->
		if RocketChat.settings.get 'Meta:language'
			metaLanguageComputation?.stop()
			Meta.set
				name: 'http-equiv'
				property: 'content-language'
				content: RocketChat.settings.get 'Meta:language'
			Meta.set
				name: 'name'
				property: 'language'
				content: RocketChat.settings.get 'Meta:language'

	metaFBComputation = Tracker.autorun ->
		if RocketChat.settings.get 'Meta:fb:app_id'
			metaFBComputation?.stop()
			Meta.set
				name: 'property'
				property: 'fb:app_id'
				content: RocketChat.settings.get 'Meta:fb:app_id'

	metaRobotsComputation = Tracker.autorun ->
		if RocketChat.settings.get 'Meta:robots'
			metaRobotsComputation?.stop()
			Meta.set
				name: 'name'
				property: 'robots'
				content: RocketChat.settings.get 'Meta:robots'

	metaGoogleComputation = Tracker.autorun ->
		if RocketChat.settings.get 'Meta:google-site-verification'
			metaGoogleComputation?.stop()
			Meta.set
				name: 'name'
				property: 'google-site-verification'
				content: RocketChat.settings.get 'Meta:google-site-verification'

	metaMSValidateComputation = Tracker.autorun ->
		if RocketChat.settings.get 'Meta:msvalidate.01'
			metaMSValidateComputation?.stop()
			Meta.set
				name: 'name'
				property: 'msvalidate.01'
				content: RocketChat.settings.get 'Meta:msvalidate.01'

	if Meteor.isCordova
		$(document.body).addClass 'is-cordova'


Template.main.helpers

	logged: ->
		if Meteor.userId()?
			$('html').addClass("noscroll").removeClass("scroll")
			return true
		else
			$('html').addClass("scroll").removeClass("noscroll")
			return false

	subsReady: ->
		return not Meteor.userId()? or (FlowRouter.subsReady('userData', 'activeUsers'))

	hasUsername: ->
		return Meteor.userId()? and Meteor.user().username?

	flexOpened: ->
		console.log 'layout.helpers flexOpened' if window.rocketDebug
		return 'flex-opened' if Session.equals('flexOpened', true)

	flexOpenedRTC1: ->
		console.log 'layout.helpers flexOpenedRTC1' if window.rocketDebug
		return 'layout1' if Session.equals('rtcLayoutmode', 1)

	flexOpenedRTC2: ->
		console.log 'layout.helpers flexOpenedRTC2' if window.rocketDebug
		return 'layout2' if (Session.get('rtcLayoutmode') > 1)


	myUserInfo: ->
		visualStatus = "online"
		username = Meteor.user()?.username
		switch Session.get('user_' + username + '_status')
			when "away"
				visualStatus = t("away")
			when "busy"
				visualStatus = t("busy")
			when "offline"
				visualStatus = t("invisible")
		return {
			name: Session.get('user_' + username + '_name')
			status: Session.get('user_' + username + '_status')
			visualStatus: visualStatus
			_id: Meteor.userId()
			username: username
		}

Template.main.events
	'click .status': (event) ->
		event.preventDefault()
		AccountBox.setStatus(event.currentTarget.dataset.status)

	'click #avatar': (event) ->
		FlowRouter.go 'changeAvatar'

	'click #settings': (event) ->
		SideNav.setFlex "userSettingsFlex"
		SideNav.openFlex()
		FlowRouter.go 'userSettings'

	'click #logout': (event) ->
		event.preventDefault()
		user = Meteor.user()
		Meteor.logout ->
			FlowRouter.go 'home'
			Meteor.call('logoutCleanUp', user)

	"click .burger": ->
		console.log 'room click .burger' if window.rocketDebug
		chatContainer = $("#rocket-chat")
		menu.toggle()


Template.main.onRendered ->

	# RTL Support - Need config option on the UI
	if isRtl localStorage.getItem "userLanguage"
		$('html').addClass "rtl"

Template.main.rendered = ->
	AccountBox.init()
