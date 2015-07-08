"use strict"

http = require "http"
https = require "https"

# Store the request types
reqTypes =
  http: http
  https: https

querystring = require "querystring"

Q = require "q"

_ = require "underscore"

###
# @private _PerformRequest
# @param {object} options - Request options
# @param {object} def - Deffered promise
# @param {function} cb - Callback
###
_PerformRequest = (reqType, options, def, cb) ->
  unless reqTypes[reqType]?
    reqType = "https"

  unless options.host?
    error =
      type: 500
      message: "Host required"
    def.reject error
    cb(error) if cb?
    return

  unless options.port?
    error =
      type: 500
      message: "Port required"
    def.reject error
    cb(error) if cb?
    return

  unless options.path?
    error =
      type: 500
      message: "Action required"
    def.reject error
    cb(error) if cb?
    return

  if options.data?
    data = options.data
    delete options.data

  # Perform request
  req = reqTypes[reqType].request options, (res) ->
    res.setEncoding "utf-8"
    #console.log res
    body = ""

    # On each buffer, add to the body
    res.on 'data', (d) ->
      body += d

    res.on 'end', ->
      try
        parsed = JSON.parse body

        if res.statusCode is 200
          def.resolve parsed, res
          cb(null, parsed, res) if cb?
          return
        # Handle an error when status code isnt 200
        else
          def.reject parsed, res
          cb(parsed, res) if cb?

      catch e
        error =
          status: 500
          message: e.toString()
        def.reject error, res
        cb(error, res) if cb?


  if data?
    req.write data
  
  req.end()

  # Request on error
  req.on 'error', (e) ->
    console.log e
    # Create a 500 error if there is an issue with the http(s) api
    error =
      status: 500
      error: e
    
    def.reject error
    
    cb(error) if cb?

###
# @class HttpMicroService
# @description Request perform for microservices
###
module.exports = class HttpMicroService
  ###
  # @constructor
  # @param {object} opts - Configuration options
  # @option {string} name - Name of the service
  # @option {string} host - Host of the microservice
  # @option {string} port - Port of the microservice
  # @option {string} [type="https"] - Type of connection
  # @option {object} [headers={ "Content-Type": "application/json" }] - Common headers
  ###
  constructor: (opts) ->
    @name = opts.name
    @host = opts.host
    @port = opts.port    
    @type = opts.type || "https"
    @commonHeaders = opts.headers || { "Content-Type": "application/json" }

  ###
  # Perform a GET request accross the RestMicroService 
  # @method get
  # @option {string} action - Action
  # @option {object} data - Query parameters
  # @option {object} headers - Additionnal headers for the request
  # @param {callback} callback - Callback
  # @return promise
  ###
  get: (opts, cb = null) ->
    def = Q.defer()

    action = opts.action
    data = opts.data || {}
    headers = opts.headers || {}

    endpoint = action

    if data?
      # Set datas as string
      endpoint += "?"+querystring.stringify data

    # Create headers
    headers = _.extend headers, @commonHeaders

    # Create options for the post
    options =
      host: @host
      port: @port
      path: endpoint
      method: "GET"
      headers: headers

    _PerformRequest @type, options, def

    return def.promise

  ###
  # Perform a GET request accross the RestMicroService 
  # @method get
  # @option {string} action - Action
  # @option {object} data - Query parameters
  # @option {object} headers - Additionnal headers for the request
  # @param {callback} callback - Callback
  # @return promise
  ###
  head: (opts, cb = null) ->
    def = Q.defer()

    action = opts.action
    data = opts.data || {}
    headers = opts.headers || {}

    endpoint = action

    if data?
      # Set datas as string
      endpoint += "?"+querystring.stringify data

    # Create headers
    headers = _.extend headers, @commonHeaders

    # Create options for the post
    options =
      host: @host
      port: @port
      path: endpoint
      method: "HEAD"
      headers: headers

    _PerformRequest @type, options, def

    return def.promise

  ###
  # Perform a POST request accross the RestMicroService 
  # @method post
  # @option {string} action - Action
  # @option {object} data - Body datas
  # @option {object} headers - Additionnal headers for the request
  # @param {callback} callback - Callback
  # @return promise
  ###
  post: (opts, cb = null) ->
    def = Q.defer()

    action = opts.action
    data = opts.data || {}
    headers = opts.headers || {}
    
    dataString = JSON.stringify data

    # Create headers
    headers = _.extend headers, @commonHeaders, {
      "Content-Length": Buffer.byteLength(dataString)
    }

    # Create options for the post
    options =
      host: @host
      port: @port
      path: action
      method: "POST"
      headers: headers
      data: dataString

    _PerformRequest @type, options, def, cb || null

    return def.promise

  ###
  # Perform a PUT request accross the RestMicroService 
  # @method put
  # @option {string} action - Action
  # @option {object} data - Body datas
  # @option {object} headers - Additionnal headers for the request
  # @param {callback} callback - Callback
  # @return promise
  ###
  put: (opts, cb = null) ->
    def = Q.defer()

    action = opts.action
    data = opts.data || {}
    headers = opts.headers || {}
    
    dataString = JSON.stringify data

    # Create headers
    headers = _.extend headers, @commonHeaders, {
      "Content-Length": Buffer.byteLength(dataString)
    }

    # Create options for the post
    options =
      host: @host
      port: @port
      path: action
      method: "PUT"
      headers: headers
      data: dataString

    _PerformRequest @type, options, def, cb || null

    return def.promise

  ###
  # Perform a PATCH request accross the RestMicroService 
  # @method patch
  # @option {string} action - Action
  # @option {object} data - Body datas
  # @option {object} headers - Additionnal headers for the request
  # @param {callback} callback - Callback
  # @return promise
  ###
  patch: (opts, cb = null) ->
    def = Q.defer()

    action = opts.action
    data = opts.data || {}
    headers = opts.headers || {}
    
    dataString = JSON.stringify data

    # Create headers
    headers = _.extend headers, @commonHeaders, {
      "Content-Length": Buffer.byteLength(dataString)
    }

    # Create options for the post
    options =
      host: @host
      port: @port
      path: action
      method: "PATCH"
      headers: headers
      data: dataString

    _PerformRequest @type, options, def, cb || null

    return def.promise

  ###
  # Perform a DELETE request accross the RestMicroService 
  # @method delete
  # @option {string} action - Action
  # @option {object} data - Query parameters
  # @option {object} headers - Additionnal headers for the request
  # @param {callback} callback - Callback
  # @return promise
  ###
  delete: (opts, cb = null) ->
    def = Q.defer()

    action = opts.action
    data = opts.data || {}
    headers = opts.headers || {}

    endpoint = action

    if data?
      # Set datas as string
      endpoint += "?"+querystring.stringify data

    # Create headers
    headers = _.extend headers, @commonHeaders

    # Create options for the post
    options =
      host: @host
      port: @port
      path: endpoint
      method: "DELETE"
      headers: headers

    _PerformRequest @type, options, def, cb || null

    return def.promise