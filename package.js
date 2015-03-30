Package.describe({
  name: "pfafman:photo-up",
  summary: "Upload a photo to the client with resize, crop and preview",
  version: "0.2.0_1",
  git: "https://github.com/pfafman/meteor-photo-up.git"
});

Package.on_use(function(api, where) {
  api.versionsFrom("METEOR@1.0.4");

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
    'lib/photoUp.coffee'
  ], 'client');


});


Package.on_test(function(api) {
  api.use("pfafman:photo-up", 'client');
  api.use(['tinytest', 'test-helpers', 'coffeescript'], 'client');
  //api.add_files('photo-up-tests.coffee', 'client');
});
