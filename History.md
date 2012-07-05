Placid History
==============

0.0.5
-----

- Raise JSONParseError on bad responses instead of returning {}
- Add `data` attribute to JSONParseError to see what failed to parse


0.0.4
-----

- Remove get/post/put/delete convenience methods
- Side effect: avoid Hashie::Mash doing unwanted `delete` calls


0.0.3
-----

- Raise RestConnectionError when REST connection is refused
- Use ActiveSupport's Array#extract_options! method


0.0.2
-----

- Fix bug with Model#list so it returns model instances, not Mashes


0.0.1
-----

- Initial release
- Basic models and CRUD methods

