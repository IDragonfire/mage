"use strict"

reactive = angular.module('mage.reactive', ['mage.hosts'])

queryStringFromParams = (params) ->
  queryString = ""
  appendToQueryString = (keyValue) ->
    queryString = if queryString != "" then "#{queryString}&#{keyValue}" else keyValue

  angular.forEach params, (value, key) ->
    appendToQueryString("#{key}=#{value}")

  queryString


reactive.factory 'MageReactiveConnection', ($q, Hosts) ->
  
  MageReactiveConnection = (ns) ->
    this.connected = false
    # indicates graceful disconnect
    this.graceful = false
    this.socket = undefined
    this.ns = ns

  MageReactiveConnection.prototype = Object.create(EventEmitter.prototype)

  MageReactiveConnection.prototype.connect = (params={}) ->
    dfd = $q.defer()
    self = this

    on_message = (msg) ->
      type = msg.type
      payload = JSON.parse(msg.payload)

      if(type)
        self.emit type, payload

    on_connect = ->
      self.socket.of(self.ns).on 'message', on_message
      self.socket.of(self.ns).on 'disconnect', on_disconnect
      self.connected = true
      dfd.resolve(self)

    on_error = ->
      console.error "Could not establish connection to mage-reactive (#{Hosts.reactive}#{self.ns})"
      dfd.reject()

    on_disconnect = ->
      unless self.graceful then console.warn "Disconnected from mage-reactive"
      else self.graceful = false
      self.connected = false


    this.socket = io.connect("#{Hosts.reactive}#{this.ns}", {
      query: queryStringFromParams(params)
      'force new connection': true
    })

    this.socket.of(this.ns)
      .on('error', on_error)
      .on('connect_failed', on_error)
      .on('connect', on_connect)

    dfd.promise

  MageReactiveConnection.prototype.disconnect = ->
    this.graceful = true
    this.socket.disconnect()

  return MageReactiveConnection
  

reactive.service 'MageReactive', (MageReactiveConnection) ->
  connect = (ns, params) ->
    new MageReactiveConnection(ns).connect(params)

  return {
    connect: connect
  }

