placid
======

Placid is an ActiveRecord-ish model using a REST API for storage. The REST API
can be any backend you choose or create yourself, provided it follows some basic
conventions.

Installation
------------

    $ gem install placid

Usage
-----

Define a subclass with the name of your REST model:

    class Person < Placid::Model
    end

and you'll get these class methods, and their REST equivalents:

    Person.list              # GET     /people
    Person.create(attrs)     # POST    /person      (attrs)
    Person.find(id)          # GET     /person/:id
    Person.destroy(id)       # DELETE  /person/:id
    Person.update(id, attrs) # PUT     /person/:id  (attrs)

By default, placid assumes that your REST API is running on `localhost`. To
change this, set:

    Placid::Config.rest_url = 'http://my.rest.host:8080'

Each model has a field that is used for uniquely identifying instances. This
would be called the "primary key" in a relational database. If you don't
specify the name of the field, `id` is assumed. If your model uses a
different field name, you can specify it like this:

    class Person < Placid::Model
      unique_id :email
    end

The `Placid::Model` base class includes helper methods for basic HTTP requests.
You can use these from any model instance, or call them from custom methods you
define on your model. For example:

    class Person < Placid::Model
      unique_id :email

      def add_phone(phone_number)
        put(model, id, 'add_phone', phone_number)
      end
    end

    jenny = Person.new(:email => 'jenny@example.com')

    jenny.add_phone('867-5309')
    # Same as:
    jenny.put('person', 'jenny@example.com', 'add_phone', '867-5309')


License
-------

The MIT License

Copyright (c) 2012 Society for Human Resource Management

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

