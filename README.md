# Developing on Social Teeth

These instructions are for developing Social Teeth on OS X Lion. It will run on Linux just fine, though some
steps may need tweaking.

## Requirements

* Ruby 1.9.2 with rbenv. [See project](https://github.com/sstephenson/rbenv/) for installation and usage instructions.
* Postgres

## Quick Start

This assumes you have installed rbenv with Ruby 1.9.2-p290, postgres, and that you are a superuser in postgres.

```
$ git clone git://github.com/socialteeth/socialteeth.git
$ cd socialteeth
$ bundle install
$ createdb socialteeth
$ ./script/run_migrations.rb
$ ./script/seed_db_content.rb
$ bundle exec foreman start
```

Now visit http://localhost:8000 and you should be all set.
