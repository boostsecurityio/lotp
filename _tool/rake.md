---
title: rake
tags:
- cli
- eval-sh
- config-file
references:
- https://ruby.github.io/rake/doc/rakefile_rdoc.html
files: ['Rakefile', '*.rake']
purl: pkg:gem/rake
---

Rake is a tool similar to Make, but in Ruby. Instead of a `Makefile`, it uses a `Rakefile` written in Ruby. Unlike Make, Rake will look for a `Rakefile` in the current directory or any parent directories:
> When issuing the `rake` command in a terminal, Rake will look for a Rakefile in the current directory. If a Rakefile is not found, it will search parent directories until one is found.
> As far as rake is concerned, all tasks are run from the directory in which the Rakefile resides.

In Ruby on Rails projects, Rake tasks defined in `lib/tasks/*.rake` are [loaded by default](https://github.com/rails/rails/blob/6260b6b0c82eb41264f37acda3ab866e658bb1d6/railties/lib/rails/generators/rails/app/templates/Rakefile.tt#L1-L6).

Rake is sometimes invoked fom the Rails CLI. Some Rails commands are in fact Rake tasks and will force the evaluation of the `Rakefile` and Rake tasks:
```
rails db:create
rails assets:precompile
```
