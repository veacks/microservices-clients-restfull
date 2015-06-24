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
  # Perform request
  req = reqTypes[reqType].request options, (res) ->
    res.setEncoding "utf-8"
    console.log res.statusCode
    
    body = ""

    # On each buffer, add to the body
    res.on 'data', (d) ->
      body += d

    res.on 'end', ->
      parsed = JSON.parse body
      if res.statusCode is 200
        def.resolve parsed
        cb(null, parsed) if cb?
        return
      # Handle an error when status code isnt 200
      else
        def.reject parsed
        cb(parsed) if cb?

  req.end()

  # Request on error
  req.on 'error', (e) ->
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
    @commonHeaders = headers || { "Content-Type": "application/json" }

  ###
  # Perform a GET request accross the RestMicroService 
  # @method get
  # @param {string} action - Action
  # @param {object} data - Query parameters
  # @param {callback} callback - Callback
  # @return promise
  ###
  get: (action, data, cb) ->
    def = Q.defer()

    # Check if datas is a callback 
    if typeof data is "function"
      cb = data
      data = null

    endpoint = action

    if data?
      # Set datas as string
      endpoint += "?"+querystring.stringify data

    # Create headers
    headers = _.extend {}, @commonHeaders, {
      "Content-Type": "application/json"
      }

    # Create options for the post
    options =
      host: @host
      port: @port
      path: endpoint
      method: "GET"
      headers: headers

    _PerformRequest @type, def, cb || null

    return def.promise

  ###
  # Perform a POST request accross the RestMicroService 
  # @method post
  # @param {string} action - Action
  # @param {object} data - Post data
  # @param {callback} callback - Callback
  # @return promise
  ###
  post: (action, data, cb) ->
    Q.defer()
    
    dataString = JSON.stringify data

    # Create headers
    headers = _.extend {}, @commonHeaders, {
      "Content-Type": "application/json"
      "Content-Length": dataString.length
    }

    # Create options for the post
    options =
      host: @host
      port: @port
      path: action
      method: "POST"
      headers: headers

    _PerformRequest options, def, cb

    return def.promise

  ###
  # Perform a PUT request accross the RestMicroService 
  # @method put
  # @param {string} action - Action
  # @param {object} data - Post data
  # @param {callback} callback - Callback
  # @return promise
  ###
  put: (action, datas, cb) ->
    Q.defer()
    
    dataString = JSON.stringify data

    # Create headers
    headers = _.extend {}, @commonHeaders, {
      "Content-Type": "application/json"
      "Content-Length": dataString.length
    }

    # Create options for the post
    options =
      host: @host
      port: @port
      path: action
      method: "PUT"
      headers: headers

    _PerformRequest @type, options, def, cb

    return def.promise

  ###
  # Perform a PATCH request accross the RestMicroService 
  # @method update
  # @param {string} action - Action
  # @param {object} data - Post data
  # @param {callback} callback - Callback
  # @return promise
  ###
  patch: (action, data, cb) ->
    Q.defer()
    
    dataString = JSON.stringify data

    # Create headers
    headers = _.extend {}, @commonHeaders, {
      "Content-Type": "application/json"
      "Content-Length": dataString.length
    }

    # Create options for the post
    options =
      host: @host
      port: @port
      path: action
      method: "PATCH"
      headers: headers

    _PerformRequest @type, options, def, cb

    return def.promise

  ###
  # Perform a DELETE request accross the RestMicroService 
  # @method delete
  # @param {string} action - Action
  # @param {object} data - Query parameters
  # @param {callback} callback - Callback
  # @return promise
  ###
  delete: (action, data, cb) ->
    Q.defer()

    # Check if datas is a callback 
    if typeof data is "function"
      cb = data
      data = null

    endpoint = action

    if data?
      # Set datas as string
      endpoint += "?"+querystring.stringify data

    # Create headers
    headers = _.extend {}, @commonHeaders, {
      "Content-Type": "application/json"
    }

    # Create options for the post
    options =
      host: @host
      port: @port
      path: endpoint
      method: "DELETE"
      headers: headers

    _PerformRequest @type, options, def, cb

    return def.promise