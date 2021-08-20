Package.describe({
  name: "pfafman:photo-up",
  summary: "Upload a photo to the client with resize, crop and preview",
  version: "0.5.2_2",
  git: "https://github.com/pfafman/meteor-photo-up.git"
});

Package.onUse(function(api, where) {
  
  api.use([
    //'less',
    'underscore',
    'templating',
    'blaze',
    'jquery',
    'coffeescript',
    'reactive-var',
  ], 'client');


  // Jcrop
  api.addFiles([
    'lib/Jcrop/jquery.Jcrop.js',
    'lib/Jcrop/jquery.Jcrop.css'
  ], 'client');

  api.addAssets([
    'lib/Jcrop/Jcrop.gif'
  ], 'client');

   // JavaScript-Load-Image
  api.addFiles([
    'lib/load-image/load-image.js',
    //'lib/load-image/load-image-ios.js',
    'lib/load-image/load-image-meta.js',
    'lib/load-image/load-image-exif.js',
    'lib/load-image/load-image-exif-map.js',
    'lib/load-image/load-image-orientation.js',
    ], 'client');


  api.addFiles([
    //'lib/photoUp.less',
    'lib/photoUp.css',
    'lib/photoUp.html',
    'lib/photoUp.coffee',
  ], 'client');


  api.use([
    'softwarerero:accounts-t9n@2.1.0',
    'coffeescript',
  ], ["client", "server"]);

  api.addFiles([
    'lib/t9n/en.coffee',
    'lib/t9n/es.coffee',
    'lib/t9n/it.coffee',
    'lib/t9n/de.coffee',
    'lib/t9n/cs.coffee',
    'lib/t9n/sk.coffee',
    'lib/t9n/pt_BR.coffee'
  ], ["client", "server"]);

});


Package.onTest(function(api) {
  api.use("pfafman:photo-up", 'client');
  api.use(['tinytest', 'test-helpers', 'coffeescript'], 'client');
  //api.add_files('photo-up-tests.coffee', 'client');
});
