# Assertion and mock frameworks
chai = require "chai"
should = chai.should()
sinon = require "sinon"
sinonChai = require "sinon-chai"
chai.use sinonChai

services = require "../build"

describe "Configuration", ->
  it "should return the HTTP Microservice class", (done) ->
    httpService = new services.HttpMicroService
      name: "testApi"
      host: "localhost"
      port: 3000

    httpService.constructor.name.should.be.equal "HttpMicroService"
    done()

  it "should configurate an HTTP Microservice", (done) ->
    services.set 
      testApi:
        host: "localhost"
        port: 3000
        type: "http"

    should.exist services.get()["testApi"]
    should.exist services.get("testApi")
    
    testApi = services.get("testApi")
    
    testApi.constructor.name.should.be.equal "HttpMicroService"
    testApi.name.should.be.equal "testApi"
    testApi.host.should.be.equal "localhost"
    testApi.port.should.be.equal 3000
    testApi.type.should.be.equal "http"

    done()

  it "should configurate an HTTPS Microservice", (done) ->
    services.set 
      testApi:
        host: "localhost"
        port: 3000
        type: "https"

    should.exist services.get()["testApi"]
    should.exist services.get("testApi")
    
    testApi = services.get("testApi")
    
    testApi.constructor.name.should.be.equal "HttpMicroService"
    testApi.name.should.be.equal "testApi"
    testApi.host.should.be.equal "localhost"
    testApi.port.should.be.equal 3000
    testApi.type.should.be.equal "https"
    
    done()

  it "should configurate multiple HTTP(S) Microservices", (done) ->
    services.set 
      testApi1:
        host: "localhost"
        port: 3000
        type: "http"
      testApi2:
        host: "localhost"
        port: 3001
        type: "https"

    should.exist services.get()["testApi1"]
    should.exist services.get()["testApi2"]
    should.exist services.get("testApi1")
    should.exist services.get("testApi2")
    
    done()

