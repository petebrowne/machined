Machined
========

### Why another [static](https://github.com/mojombo/jekyll) [site](https://github.com/cloudhead/toto) [generator](https://github.com/petebrowne/massimo)?

Machined is for the developers who know and love [the asset pipeline](http://edgeguides.rubyonrails.org/asset_pipeline.html) of Rails 3.1 and want to develop blazingly fast static websites. It's built from the ground up using [Sprockets 2.0](https://github.com/search?q=sprockets).

Installation
------------

``` bash
$ gem install machined
```

Quick Start
-----------
    
``` bash
$ machined new blog
```

This creates a directory with the default Machined project structure. More on that later. Let's start up the Machined server:

``` bash
$ cd blog
$ bundle install
$ bundle exec machined server
```

Now that the server is running, edit your pages, assets, etc. and view the results. Most static site servers need to recompile the _entire_ site each time a request is made. Machined (well really Sprockets) is smart enough to compile only what you request, so developing is super fast.

Deploying a Static Website
--------------------------

Once you've created your site, it's time to go live. On your production box, you just need to compile the site and let Apache, Nginx, or whatever handle the serving. It'll be fast - damn fast.

``` bash
$ bundle exec machined compile --environment production
```

Diving In
---------

Read the [full documentation](https://github.com/petebrowne/machined/wiki).

Copyright
---------

Copyright (c) 2011 [Peter Browne](http://petebrowne.com). See LICENSE for details.
