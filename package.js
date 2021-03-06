Package.describe({
  summary: "Extending publish method",
  version: '1.0.1',
  name: 'giangndm:pubsub-extended',
  git: 'https://github.com/spidercpsf/meteor-pubsub-extended.git'
});

Package.onUse(function (api) {
  api.versionsFrom('METEOR@1.2.1');

  // Core dependencies.
  api.use([
    'coffeescript',
    'underscore',
    'mongo',
    'ddp',
    'ejson',
    'mongo-id'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:fiber-utils@0.6.0'
  ]);

  api.addFiles([
    'static_publish.js',
    'livedata_server.js',
    'server.coffee'
  ], 'server');

  api.addFiles([
    'client.coffee'
  ], 'client');
});

Package.onTest(function (api) {
  // Core dependencies.
  api.use([
    'coffeescript',
    'underscore',
    'mongo'
  ]);

  // Internal dependencies.
  api.use([
    'giangndm:pubsub-extended'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:classy-test@0.2.23'
  ]);

  api.add_files([
    'tests.coffee'
  ]);
});
