# Assertion and mock frameworks
chai = require "chai"
should = chai.should()
sinon = require "sinon"
sinonChai = require "sinon-chai"
chai.use sinonChai

nock = require "nock"

http = require "http"
https = require "https"

HttpMicroService = require "../build/HttpMicroService"

describe "HttpMicroService", ->

  describe "Create a Microservice", ->
    service = {}

    # Test the micro service constructor
    it "Should create an HTTPS Microservice Object with default values", (done) ->
      service = new HttpMicroService
        name: "testApi"
        host: "localhost"
        port: 3000

      service.name.should.be.equal "testApi"
      service.host.should.be.equal "localhost"
      service.port.should.be.equal 3000
      service.type.should.be.equal "https"
      service.commonHeaders.should.be.eql { "Content-Type": "application/json" }
      done()

    it "Should create an HTTP MicroService Object with custom header", (done) ->
      service = new HttpMicroService
        name: "testApi"
        host: "localhost"
        port: 3000
        type: "http"
        headers: {
          "Foo": "bar"
        }
      
      service.type.should.be.equal "http"
      service.commonHeaders.should.be.eql { "Foo": "bar" }

      done()

  describe "Common request check", ->
    # Check host
    # Check port
    # Check action
    # Check wrong type


  describe "GET", ->
    it "Should perform an Https GET request", (done) ->
      nock "https://localhost:3000"
      .matchHeader('Content-Type', 'application/json')
      .matchHeader('Foo', "Bar")
      .get "/controller/page?foo=bar"
      .reply 200, { key: "value" }, {
        'Content-Type': 'application/json'
      }

      service = new HttpMicroService
        name: "testApi"
        host: "localhost"
        port: 3000

      service.get
        action: "/controller/page"
        data:
          foo: "bar"
        headers:
          "Foo": "Bar"

      .catch (err) ->
        should.not.exits err
        done()
      .then (resp) ->
        resp.should.be.eql { key: "value" }
        done()

    it "Should perform an Http GET request", (done) ->
      nock "http://localhost:3000"
      .matchHeader('Content-Type', 'application/json')
      .matchHeader('Foo', "Bar")
      .get "/controller/page?foo=bar"
      .reply 200, { key: "value" }, {
        'Content-Type': 'application/json'
      }

      service = new HttpMicroService
        name: "testApi"
        host: "localhost"
        port: 3000
        type: "http"

      service.get
        action: "/controller/page"
        data:
          foo: "bar"
        headers:
          "Foo": "Bar"

      .catch (err) ->
        should.not.exits err
        done()
      .then (resp) ->
        resp.should.be.eql { key: "value" }
        done()

    it "Should not perform HTTPS if the type is wrong", (done) ->
      nock "https://localhost:3000"
      .matchHeader('Content-Type', 'application/json')
      .matchHeader('Foo', "Bar")
      .get "/controller/page?foo=bar"
      .reply 200, { key: "value" }, {
        'Content-Type': 'application/json'
      }

      service = new HttpMicroService
        name: "testApi"
        host: "localhost"
        port: 3000
        type: "wrong"

      service.get
        action: "/controller/page"
        data:
          foo: "bar"
        headers:
          "Foo": "Bar"
      
      .catch (err) ->
        should.not.exits err
        done()
      .then (resp) ->
        resp.should.be.eql { key: "value" }
        done()

  describe "POST", ->
    it "Should perform an Https POST request", (done) ->
      datasToPost = { foo: "bar" }
      nock "https://localhost:3000"
      .matchHeader('Content-Type', 'application/json')
      .matchHeader('Foo', "Bar")
      
      .matchHeader('Content-Length', JSON.stringify(datasToPost).length)
      
      .filteringRequestBody (body) ->
        body.should.be.equal JSON.stringify(datasToPost)
        return body
      
      .post "/controller"
      
      .reply 200, { id: "0123456789" }, {
        'Content-Type': 'application/json'
      }

      service = new HttpMicroService
        name: "testApi"
        host: "localhost"
        port: 3000

      service.post
        action: "/controller"
        data: datasToPost
        headers:
          "Foo": "Bar"

      .catch (err) ->
        should.not.exits err
        done()
      .then (resp) ->
        resp.should.be.eql { id: "0123456789" }
        done()

  describe "PUT", ->
    it "Should perform an Https PUT request", (done) ->
      datasToPost = { foo: "bar" }
      nock "https://localhost:3000"
      .matchHeader('Content-Type', 'application/json')
      .matchHeader('Foo', "Bar")
      
      .matchHeader('Content-Length', JSON.stringify(datasToPost).length)
      
      .filteringRequestBody (body) ->
        body.should.be.equal JSON.stringify(datasToPost)
        return body
      
      .put "/controller"
      
      .reply 200, { id: "0123456789" }, {
        'Content-Type': 'application/json'
      }

      service = new HttpMicroService
        name: "testApi"
        host: "localhost"
        port: 3000

      service.put
        action: "/controller"
        data: datasToPost
        headers:
          "Foo": "Bar"

      .catch (err) ->
        should.not.exits err
        done()
      .then (resp) ->
        resp.should.be.eql { id: "0123456789" }
        done()

  describe "PATCH", ->
    it "Should perform an Https PATCH request", (done) ->
      datasToPost = { foo: "bar" }
      nock "https://localhost:3000"
      .matchHeader('Content-Type', 'application/json')
      .matchHeader('Foo', "Bar")
      
      .matchHeader('Content-Length', JSON.stringify(datasToPost).length)
      
      .filteringRequestBody (body) ->
        body.should.be.equal JSON.stringify(datasToPost)
        return body
      
      .patch "/controller"
      
      .reply 200, { id: "0123456789" }, {
        'Content-Type': 'application/json'
      }

      service = new HttpMicroService
        name: "testApi"
        host: "localhost"
        port: 3000

      service.patch
        action: "/controller"
        data: datasToPost
        headers:
          "Foo": "Bar"

      .catch (err) ->
        should.not.exits err
        done()
      .then (resp) ->
        resp.should.be.eql { id: "0123456789" }
        done()

  describe "DELETE", ->
    it "Should perform an Https DELETE request", (done) ->
      nock "https://localhost:3000"
      .matchHeader('Content-Type', 'application/json')
      .matchHeader('Foo', "Bar")
      .delete "/controller/page?foo=bar"
      .reply 200, { key: "value" }, {
        'Content-Type': 'application/json'
      }

      service = new HttpMicroService
        name: "testApi"
        host: "localhost"
        port: 3000

      service.delete
        action: "/controller/page"
        data:
          foo: "bar"
        headers:
          "Foo": "Bar"

      .catch (err) ->
        should.not.exits err
        done()
      .then (resp) ->
        resp.should.be.eql { key: "value" }
        done()

