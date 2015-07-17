Package.describe({
  name: "pfafman:photo-up",
  summary: "Upload a photo to the client with resize, crop and preview",
  version: "0.3.1",
  git: "https://github.com/pfafman/meteor-photo-up.git"
});

Package.on_use(function(api, where) {
  api.versionsFrom("METEOR@1.1");

  api.use([
    //'less',
    'underscore',
    'templating',
    'ui',
    'jquery',
    'coffeescript',
    'reactive-var',
  ], 'client');


  // Jcrop
  api.add_files([
    'lib/Jcrop/jquery.Jcrop.js',
    'lib/Jcrop/jquery.Jcrop.css',
    'lib/Jcrop/Jcrop.gif'
  ], 'client');

   // JavaScript-Load-Image
  api.add_files([
    'lib/load-image/load-image.js',
    'lib/load-image/load-image-ios.js',
    'lib/load-image/load-image-meta.js',
    'lib/load-image/load-image-exif.js',
    'lib/load-image/load-image-exif-map.js',
    'lib/load-image/load-image-orientation.js',
    ], 'client');


  api.add_files([
    //'lib/photoUp.less',
    'lib/photoUp.css',
    'lib/photoUp.html',
    'lib/photoUp.coffee',
  ], 'client');


  api.use([
    'softwarerero:accounts-t9n@1.1.3',
  ], ["client", "server"]);

  api.add_files([
    'lib/t9n/en.coffee',
    'lib/t9n/it.coffee',
    'lib/t9n/de.coffee',
    'lib/t9n/cs.coffee',
    'lib/t9n/sk.coffee',
  ], ["client", "server"]);

});


Package.on_test(function(api) {
  api.use("pfafman:photo-up", 'client');
  api.use(['tinytest', 'test-helpers', 'coffeescript'], 'client');
  //api.add_files('photo-up-tests.coffee', 'client');
});
