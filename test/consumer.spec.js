/*
 * node-rdkafka - Node.js wrapper for RdKafka C/C++ library
 *
 * Copyright (c) 2016 Blizzard Entertainment
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE.txt file for details.
 */

const binary = require('@mapbox/node-pre-gyp');
const path = require('path');
const binding_path = binary.find(path.resolve(path.join(__dirname,'../package.json')));
const addon = require(binding_path);
var t = require('assert');

var client;
var defaultConfig = {
  'client.id': 'kafka-mocha',
  'group.id': 'kafka-mocha-grp',
  'metadata.broker.list': 'localhost:9092'
};

module.exports = {
  'Consumer': {
    'afterEach': function() {
      client = null;
    },
    'cannot be set without a topic config': function() {
      t.throws(function() {
        client = new addon.KafkaConsumer(defaultConfig);
      });
    },
    'can be given a topic config': function() {
      client = new addon.KafkaConsumer(defaultConfig, {});
    },
    'throws us an error if we provide an invalid configuration value': function() {
      t.throws(function() {
        client = new addon.KafkaConsumer({
          'foo': 'bar'
        });
      }, 'should throw because the key is invalid1');
    },
    'throws us an error if topic config is given something invalid': function() {
      t.throws(function() {
        client = new addon.KafkaConsumer(defaultConfig, { 'foo': 'bar' });
      });
    },
    'ignores function arguments for global configuration': function() {
      client = new addon.KafkaConsumer({
        'event_cb': function() {},
        'group.id': 'mocha-test'
      }, {});
      t.ok(client);
    },
    'ignores function arguments for topic configuration': function() {
      client = new addon.KafkaConsumer(defaultConfig, {
        'partitioner_cb': function() {}
      });
    }
  },
  'KafkaConsumer client': {
    'beforeEach': function() {
      client = new addon.KafkaConsumer(defaultConfig, {});
    },
    'afterEach': function() {
      client = null;
    },
    'is an object': function() {
      t.equal(typeof(client), 'object');
    },
    'requires configuration': function() {
      t.throws(function() {
        return new addon.KafkaConsumer();
      });
    },
    'has necessary methods from superclass': function() {
      var methods = ['connect', 'disconnect', 'setToken', 'configureCallbacks', 'getMetadata'];
      methods.forEach(function(m) {
        t.equal(typeof(client[m]), 'function', 'Client is missing ' + m + ' method');
      });
    },
    'has necessary bindings for librdkafka 1:1 binding': function() {
      var methods = ['assign', 'unassign', 'subscribe'];
      methods.forEach(function(m) {
        t.equal(typeof(client[m]), 'function', 'Client is missing ' + m + ' method');
      });
    }
  },
};
