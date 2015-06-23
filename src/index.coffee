"user strict"

RestfullMicroService = require "RestfullMicroService"

###
# @private services
# @description Store the microservices
###
services = {}

module.exports =
  ###
  # @method set
  # @description Set the services
  # @param {object} config - Services Configuration
  ###
  set: (config) ->
    for serviceKey, serviceConf of config
      services[serviceKey] = new RestfullMicroService serviceConf.host, serviceConf.port, serviceConf.protocol

  ###
  # @method get
  # @description Get the services
  # @param {object} config - Services Configuration
  ###
  get: (name) ->
    if name?
      return services[name]
    return services
