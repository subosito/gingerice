# Gingerice [![Gem Version](https://badge.fury.io/rb/gingerice.png)](http://badge.fury.io/rb/gingerice) [![Build Status](https://travis-ci.org/subosito/gingerice.png)](https://travis-ci.org/subosito/gingerice) [![Coverage Status](https://coveralls.io/repos/subosito/gingerice/badge.png)](https://coveralls.io/r/subosito/gingerice) [![Dependency Status](https://gemnasium.com/subosito/gingerice.png)](https://gemnasium.com/subosito/gingerice) [![Code Climate](https://codeclimate.com/github/subosito/gingerice.png)](https://codeclimate.com/github/subosito/gingerice)

Ruby wrapper of Ginger Proofreader which corrects spelling and grammar mistakes based on the context of complete sentences by comparing each sentence to billions of similar sentences from the web.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gingerice'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install gingerice
```

## Usage

```ruby
require 'gingerice'

text = 'The smelt of fliwers bring back memories.'

parser = Gingerice::Parser.new
parser.parse text

```

```
# output:

{
           "text" => "The smelt of fliwers bring back memories.",
         "result" => "The smell of flowers brings back memories.",
    "corrections" => [
        [0] {
                  "text" => "smelt",
               "correct" => "smell",
            "definition" => nil
        },
        [1] {
                  "text" => "fliwers",
               "correct" => "flowers",
            "definition" => "a plant cultivated for its blooms or blossoms"
        },
        [2] {
                  "text" => "bring",
               "correct" => "brings",
            "definition" => nil
        }
    ]
}
```

This gem also provides executable which can be executed:

```bash
$ gingerice "Edwards will be sck yesterday"
```

```
# output:

Edwards was sick yesterday
```

Or if you want verbose output you can add `--verbose` or `-v` argument:

```bash
$ gingerice --verbose "Edwards will be sck yesterday"
```

```
# output:

{
           "text" => "Edwards will be sck yesterday",
         "result" => "Edwards was sick yesterday",
    "corrections" => [
        [0] {
                  "text" => "will be",
               "correct" => "was",
            "definition" => nil
        },
        [1] {
                  "text" => "sck",
               "correct" => "sick",
            "definition" => "affected by an impairment of normal physical or mental function"
        }
    ]
}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Thanks

Thank you for [Ginger Proofreader](http://www.gingersoftware.com/) for such awesome service. Hope they will keep it free :)

