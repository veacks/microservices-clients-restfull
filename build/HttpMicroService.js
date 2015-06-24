(function() {
  "use strict";
  var HttpMicroService, Q, http, https, querystring, reqTypes, _, _PerformRequest;

  http = require("http");

  https = require("https");

  reqTypes = {
    http: http,
    https: https
  };

  querystring = require("querystring");

  Q = require("q");

  _ = require("underscore");


  /*
   * @private _PerformRequest
   * @param {object} options - Request options
   * @param {object} def - Deffered promise
   * @param {function} cb - Callback
   */

  _PerformRequest = function(reqType, options, def, cb) {
    var req;
    req = reqTypes[reqType].request(options, function(res) {
      var body;
      res.setEncoding("utf-8");
      console.log(res.statusCode);
      body = "";
      res.on('data', function(d) {
        return body += d;
      });
      return res.on('end', function() {
        var parsed;
        parsed = JSON.parse(body);
        if (res.statusCode === 200) {
          def.resolve(parsed);
          if (cb != null) {
            cb(null, parsed);
          }
        } else {
          def.reject(parsed);
          if (cb != null) {
            return cb(parsed);
          }
        }
      });
    });
    req.end();
    return req.on('error', function(e) {
      var error;
      error = {
        status: 500,
        error: e
      };
      def.reject(error);
      if (cb != null) {
        return cb(error);
      }
    });
  };


  /*
   * @class HttpMicroService
   * @description Request perform for microservices
   */

  module.exports = HttpMicroService = (function() {

    /*
     * @constructor
     * @param {object} opts - Configuration options
     * @option {string} name - Name of the service
     * @option {string} host - Host of the microservice
     * @option {string} port - Port of the microservice
     * @option {string} [type="https"] - Type of connection
     * @option {object} [headers={ "Content-Type": "application/json" }] - Common headers
     */
    function HttpMicroService(opts) {
      this.name = opts.name;
      this.host = opts.host;
      this.port = opts.port;
      this.type = opts.type || "https";
      this.commonHeaders = headers || {
        "Content-Type": "application/json"
      };
    }


    /*
     * Perform a GET request accross the RestMicroService 
     * @method get
     * @param {string} action - Action
     * @param {object} data - Query parameters
     * @param {callback} callback - Callback
     * @return promise
     */

    HttpMicroService.prototype.get = function(action, data, cb) {
      var def, endpoint, headers, options;
      def = Q.defer();
      if (typeof data === "function") {
        cb = data;
        data = null;
      }
      endpoint = action;
      if (data != null) {
        endpoint += "?" + querystring.stringify(data);
      }
      headers = _.extend({}, this.commonHeaders, {
        "Content-Type": "application/json"
      });
      options = {
        host: this.host,
        port: this.port,
        path: endpoint,
        method: "GET",
        headers: headers
      };
      _PerformRequest(this.type, def, cb || null);
      return def.promise;
    };


    /*
     * Perform a POST request accross the RestMicroService 
     * @method post
     * @param {string} action - Action
     * @param {object} data - Post data
     * @param {callback} callback - Callback
     * @return promise
     */

    HttpMicroService.prototype.post = function(action, data, cb) {
      var dataString, headers, options;
      Q.defer();
      dataString = JSON.stringify(data);
      headers = _.extend({}, this.commonHeaders, {
        "Content-Type": "application/json",
        "Content-Length": dataString.length
      });
      options = {
        host: this.host,
        port: this.port,
        path: action,
        method: "POST",
        headers: headers
      };
      _PerformRequest(options, def, cb);
      return def.promise;
    };


    /*
     * Perform a PUT request accross the RestMicroService 
     * @method put
     * @param {string} action - Action
     * @param {object} data - Post data
     * @param {callback} callback - Callback
     * @return promise
     */

    HttpMicroService.prototype.put = function(action, datas, cb) {
      var dataString, headers, options;
      Q.defer();
      dataString = JSON.stringify(data);
      headers = _.extend({}, this.commonHeaders, {
        "Content-Type": "application/json",
        "Content-Length": dataString.length
      });
      options = {
        host: this.host,
        port: this.port,
        path: action,
        method: "PUT",
        headers: headers
      };
      _PerformRequest(this.type, options, def, cb);
      return def.promise;
    };


    /*
     * Perform a PATCH request accross the RestMicroService 
     * @method update
     * @param {string} action - Action
     * @param {object} data - Post data
     * @param {callback} callback - Callback
     * @return promise
     */

    HttpMicroService.prototype.patch = function(action, data, cb) {
      var dataString, headers, options;
      Q.defer();
      dataString = JSON.stringify(data);
      headers = _.extend({}, this.commonHeaders, {
        "Content-Type": "application/json",
        "Content-Length": dataString.length
      });
      options = {
        host: this.host,
        port: this.port,
        path: action,
        method: "PATCH",
        headers: headers
      };
      _PerformRequest(this.type, options, def, cb);
      return def.promise;
    };


    /*
     * Perform a DELETE request accross the RestMicroService 
     * @method delete
     * @param {string} action - Action
     * @param {object} data - Query parameters
     * @param {callback} callback - Callback
     * @return promise
     */

    HttpMicroService.prototype["delete"] = function(action, data, cb) {
      var endpoint, headers, options;
      Q.defer();
      if (typeof data === "function") {
        cb = data;
        data = null;
      }
      endpoint = action;
      if (data != null) {
        endpoint += "?" + querystring.stringify(data);
      }
      headers = _.extend({}, this.commonHeaders, {
        "Content-Type": "application/json"
      });
      options = {
        host: this.host,
        port: this.port,
        path: endpoint,
        method: "DELETE",
        headers: headers
      };
      _PerformRequest(this.type, options, def, cb);
      return def.promise;
    };

    return HttpMicroService;

  })();

}).call(this);
