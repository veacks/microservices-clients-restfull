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
    var data, error, req;
    if (reqTypes[reqType] == null) {
      reqType = "https";
    }
    if (options.host == null) {
      error = {
        type: 500,
        message: "Host required"
      };
      def.reject(error);
      if (cb != null) {
        cb(error);
      }
      return;
    }
    if (options.port == null) {
      error = {
        type: 500,
        message: "Port required"
      };
      def.reject(error);
      if (cb != null) {
        cb(error);
      }
      return;
    }
    if (options.path == null) {
      error = {
        type: 500,
        message: "Action required"
      };
      def.reject(error);
      if (cb != null) {
        cb(error);
      }
      return;
    }
    if (options.data != null) {
      data = options.data;
      delete options.data;
    }
    req = reqTypes[reqType].request(options, function(res) {
      var body;
      res.setEncoding("utf-8");
      def.promise.response = res;
      body = "";
      res.on('data', function(d) {
        return body += d;
      });
      return res.on('end', function() {
        var e;
        try {
          if ((res.headers['content-type'] != null) && (res.headers['content-type'].match(/json/) != null)) {
            if (body === "") {
              body = "{}";
            }
            body = JSON.parse(body);
          }
          if (res.statusCode === 200) {
            def.resolve(body);
            if (cb != null) {
              cb(null, body, res);
            }
          } else {
            def.reject(body);
            if (cb != null) {
              return cb(body, res);
            }
          }
        } catch (_error) {
          e = _error;
          error = {
            status: 500,
            message: e.toString()
          };
          def.reject(error);
          if (cb != null) {
            return cb(error, res);
          }
        }
      });
    });
    if (data != null) {
      req.write(data);
    }
    req.end();
    return req.on('error', function(e) {
      console.log(e);
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
      this.commonHeaders = opts.headers || {
        "Content-Type": "application/json"
      };
    }


    /*
     * Perform a GET request accross the RestMicroService 
     * @method get
     * @option {string} action - Action
     * @option {object} data - Query parameters
     * @option {object} headers - Additionnal headers for the request
     * @param {callback} callback - Callback
     * @return promise
     */

    HttpMicroService.prototype.get = function(opts, cb) {
      var action, data, def, endpoint, headers, options;
      if (cb == null) {
        cb = null;
      }
      def = Q.defer();
      action = opts.action;
      data = opts.data || {};
      headers = opts.headers || {};
      endpoint = action;
      if (data != null) {
        endpoint += "?" + querystring.stringify(data);
      }
      headers = _.extend(headers, this.commonHeaders);
      options = {
        host: this.host,
        port: this.port,
        path: endpoint,
        method: "GET",
        headers: headers
      };
      _PerformRequest(this.type, options, def);
      return def.promise;
    };


    /*
     * Perform a GET request accross the RestMicroService 
     * @method get
     * @option {string} action - Action
     * @option {object} data - Query parameters
     * @option {object} headers - Additionnal headers for the request
     * @param {callback} callback - Callback
     * @return promise
     */

    HttpMicroService.prototype.head = function(opts, cb) {
      var action, data, def, endpoint, headers, options;
      if (cb == null) {
        cb = null;
      }
      def = Q.defer();
      action = opts.action;
      data = opts.data || {};
      headers = opts.headers || {};
      endpoint = action;
      if (data != null) {
        endpoint += "?" + querystring.stringify(data);
      }
      headers = _.extend(headers, this.commonHeaders);
      options = {
        host: this.host,
        port: this.port,
        path: endpoint,
        method: "HEAD",
        headers: headers
      };
      _PerformRequest(this.type, options, def);
      return def.promise;
    };


    /*
     * Perform a POST request accross the RestMicroService 
     * @method post
     * @option {string} action - Action
     * @option {object} data - Body datas
     * @option {object} headers - Additionnal headers for the request
     * @param {callback} callback - Callback
     * @return promise
     */

    HttpMicroService.prototype.post = function(opts, cb) {
      var action, data, dataString, def, headers, options;
      if (cb == null) {
        cb = null;
      }
      def = Q.defer();
      action = opts.action;
      data = opts.data || {};
      headers = opts.headers || {};
      dataString = JSON.stringify(data);
      headers = _.extend(headers, this.commonHeaders, {
        "Content-Length": Buffer.byteLength(dataString)
      });
      options = {
        host: this.host,
        port: this.port,
        path: action,
        method: "POST",
        headers: headers,
        data: dataString
      };
      _PerformRequest(this.type, options, def, cb || null);
      return def.promise;
    };


    /*
     * Perform a PUT request accross the RestMicroService 
     * @method put
     * @option {string} action - Action
     * @option {object} data - Body datas
     * @option {object} headers - Additionnal headers for the request
     * @param {callback} callback - Callback
     * @return promise
     */

    HttpMicroService.prototype.put = function(opts, cb) {
      var action, data, dataString, def, headers, options;
      if (cb == null) {
        cb = null;
      }
      def = Q.defer();
      action = opts.action;
      data = opts.data || {};
      headers = opts.headers || {};
      dataString = JSON.stringify(data);
      headers = _.extend(headers, this.commonHeaders, {
        "Content-Length": Buffer.byteLength(dataString)
      });
      options = {
        host: this.host,
        port: this.port,
        path: action,
        method: "PUT",
        headers: headers,
        data: dataString
      };
      _PerformRequest(this.type, options, def, cb || null);
      return def.promise;
    };


    /*
     * Perform a PATCH request accross the RestMicroService 
     * @method patch
     * @option {string} action - Action
     * @option {object} data - Body datas
     * @option {object} headers - Additionnal headers for the request
     * @param {callback} callback - Callback
     * @return promise
     */

    HttpMicroService.prototype.patch = function(opts, cb) {
      var action, data, dataString, def, headers, options;
      if (cb == null) {
        cb = null;
      }
      def = Q.defer();
      action = opts.action;
      data = opts.data || {};
      headers = opts.headers || {};
      dataString = JSON.stringify(data);
      headers = _.extend(headers, this.commonHeaders, {
        "Content-Length": Buffer.byteLength(dataString)
      });
      options = {
        host: this.host,
        port: this.port,
        path: action,
        method: "PATCH",
        headers: headers,
        data: dataString
      };
      _PerformRequest(this.type, options, def, cb || null);
      return def.promise;
    };


    /*
     * Perform a DELETE request accross the RestMicroService 
     * @method delete
     * @option {string} action - Action
     * @option {object} data - Query parameters
     * @option {object} headers - Additionnal headers for the request
     * @param {callback} callback - Callback
     * @return promise
     */

    HttpMicroService.prototype["delete"] = function(opts, cb) {
      var action, data, def, endpoint, headers, options;
      if (cb == null) {
        cb = null;
      }
      def = Q.defer();
      action = opts.action;
      data = opts.data || {};
      headers = opts.headers || {};
      endpoint = action;
      if (data != null) {
        endpoint += "?" + querystring.stringify(data);
      }
      headers = _.extend(headers, this.commonHeaders);
      options = {
        host: this.host,
        port: this.port,
        path: endpoint,
        method: "DELETE",
        headers: headers
      };
      _PerformRequest(this.type, options, def, cb || null);
      return def.promise;
    };

    return HttpMicroService;

  })();

}).call(this);
