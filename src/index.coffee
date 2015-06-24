"use strict"

HttpMicroService = require "./HttpMicroService"
#RpcMicroservice = require "./RpcMicroservice"

###
# @private services
# @description Store the microservices internaly
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
      serviceConf.name = serviceKey
      switch
        when serviceConf.type.match /http(s)?/
          services[serviceKey] = new HttpMicroService serviceConf
        when serviceConf.type is "rpc"
          services[serviceKey] = new RpcMicroservice serviceConf
        else
          return new Error "Service type not covered"

  ###
  # @method get
  # @description Get the services by name or globally
  # @param {object} config - Services Configuration
  ###
  get: (name) ->
    if name?
      return services[name]
    return services

  ###
  # @member HttpMicroService - Direct access to the class HttpMicroService
  ###
  HttpMicroService: HttpMicroService