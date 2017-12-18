Language Independent Validation Rules (LIVR) for Perl6
------------------------------------------------------

I've just [ported LIVR to Perl6]
(https://modules.perl6.org/dist/LIVR:cpan:KOORCHIK) . It was really fun to code in Perl6. Moreover, LIVR's test suite allowed me to find a bug in Perl6 Email::Valid, and another one in Rakudo itself. It was even more fun that you not just implemented module but helped other developers to do some testing :)

What is LIVR? LIVR stands for "Language Independent Validation Rules". So, it is like ["Mustache"](https://mustache.github.io/) but in the world of validation. So, LIVR consists of the following parts:

1. [LIVR Specification](http://livr-spec.org/)
2. [Implementations for different languages](http://livr-spec.org/introduction/implementations.html).
3. [Universal test suite](https://github.com/koorchik/LIVR/tree/master/test_suite), that is used for checking that the implementation works properly.

There is LIVR for:

* [Perl 15 \(LIVR 2.0\)](https://github.com/koorchik/Validator-LIVR) available at [CPAN](https://metacpan.org/pod/Validator::LIVR), maintainer [@koorchik](https://github.com/koorchik)
* [Perl 6 \(LIVR 2.0\)](https://github.com/koorchik/perl6-livr) available at [CPAN](https://modules.perl6.org/dist/LIVR:cpan:KOORCHIK), maintainer [@koorchik](https://github.com/koorchik)
* [JavaScript \(LIVR 2.0\)](https://github.com/koorchik/js-validator-livr) available at [npm](https://www.npmjs.com/package/livr), maintainer [@koorchik](https://github.com/koorchik)
* [PHP \(LIVR 2.0\)](https://github.com/WebbyLab/php-validator-livr) available at [packagist](https://packagist.org/packages/validator/livr), maintainer [@WebbyLab](https://github.com/WebbyLab)
* [Python \(LIVR 2.0\)](https://github.com/asholok/python-validator-livr) available at [pypi](https://pypi.python.org/pypi/LIVR), maintainer [@asholok](https://github.com/asholok)
* [OLIFER Erlang \(LIVR 2.0\)](https://github.com/Prots/olifer), maintainer [@Prots](https://github.com/Prots)
* [LIVER Erlang \(LIVR 2.0\)](https://github.com/erlangbureau/liver), maintainer [@erlangbureau](https://github.com/erlangbureau)
* [Java \(LIVR 2.0\)](https://github.com/vlbaluk/java-validator-livr), maintainer [@vlbaluk](https://github.com/vlbaluk)
* [Ruby \(LIVR 0.4, previous version\)](https://github.com/maktwin/ruby-validator-livr) at [rubygems](https://rubygems.org/gems/livr), maintainer [@maktwin](https://github.com/maktwin)


I will give you a short intro about LIVR here but for details, I strongly recommend to read this post ["LIVR - Data Validation Without Any Issues"](http://blog.webbylab.com/language-independent-validation-rules-library/)

## LIVR Intro

Data validation is a very common task. I am sure that every developer faces it again and again. Especially, it is important when you develop a Web application. It is a common rule - never trust user's input. It seems that if the task is so common, there should be tons of libraries. Yes, it is but it is very difficult to find one that is ideal. Some of the libraries are doing too many things (like HTML form generation etc), other libraries are difficult to extend, some does not have hierarchical data support etc.

Moreover, if you are a web developer, you could need the same validation on the server and on the client.

In WebbyLab, mainly we use 3 programming languages - Perl, JavaScript, PHP. So, for us, it was ideal to reuse similar validation approach across languages. 

Therefore, it was decided to create a universal validator that could work across different languages.

### Validator Requirements

After trying tons of validation libraries, we had some vision in our heads about the issues we want to solve. Here are the requirements for the validator:

1. Rules are declarative and language independent. So, rules for validation is just a data structure, not method calls etc. You can transform it, change it as you do this with any other data structure.
2. Any number of rules for each field. 
3. The validator should return together errors for all fields. For example, we want to highlight all errors in a form.
4. Cut out all fields that do not have validation rules described. (otherwise, you cannot rely on your validation, someday you will have a security issue if the validator will not meet this property).
5. Possibility to validate complex hierarchical structures. Especially useful for JSON APIs.
6. Easy to describe and understand validation. 
7. Returns understandable error codes (neither error messages nor numeric codes)
8. Easy to implement own rules (usually you will have several in every project)
9. Rules should be able to change results output ("trim", "nested_object", for example)
10. Multipurpose (user input validation, configs validation etc)
Unicode support.


### LIVR Specification

Since the task was set to create a validator independent of a programming language (some kind of a mustache/handlebars stuff) but within the data validation sphere, we started with the composition of specifications.

The specifications’ objectives are:

1. To standardize the data description format.
2. To describe a minimal set of the validation rules that must be supported by every implementation.
3. To standardize error codes.
4. To be a single basic documentation for all the implementations.
5. To feature a set of testing data that allows checking if the implementation fits the specifications.
6. The basic idea was that the description of the validation rules must look like a data scheme and be as similar to data as possible, but with rules instead of values.

The specification is available here http://livr-spec.org/

This is the basic intro. More details are in the post I've mentioned above.

## LIVR and Perl6

Let's have some fun and play with a code. I will go through several examples, and will provide some internal details after each example. 

*The source code of all examples is [available on GitHub](https://github.com/koorchik/perl6-livr-advent-calendar-post/tree/master/examples)*

At first, install LIVR module for Perl6 from CPAN

```bash
zef install LIVR
```

### Example 1: registration data validation

```perl6
use LIVR;
LIVR::Validator.default-auto-trim(True); # automatically trim all values before validation

my $validator = LIVR::Validator.new(livr-rules => {
    name      => 'required',
    email     => [ 'required', 'email' ],
    gender    => { one_of => ['male', 'female'] },
    phone     => { max_length => 10 },
    password  => [ 'required', {min_length => 10} ],
    password2 => { equal_to_field => 'password' }
});

my $user-data = {
    name      => 'Viktor',
    email     => 'viktor@mail.com',
    gender    => 'male',
    password  => 'mypassword123',
    password2 => 'mypassword123'
}


if my $valid-data = $validator.validate($user-data) {
    #  $valid-data is clean and does contain only fields which have validation and have passed it
    $valid-data.say;
} else {
    my $errors = $validator.errors();
    $errors.say;
}
```

**So, how to understand the rules?**
The idea is very simple. Each rule is a hash. key - name of the validation rules. value - an array of arguments.

For example:

```perl6
{ 
    name  => { required => [] },
    phone => { max_length => [10] }
}
```

but if there is only one argument, you can use a shorter form:

```perl6
{ 
    phone => { max_length => 10 }
}
```

if there are no arguments, you can just pass the name of the rule as string

```perl6
{ 
    name => 'required'
}
```

you can pass a list of rules for a field in an array:

```perl6
{ 
    name => [ 'required', { max_length => 10 } ]
}
```

In this case, rules will be applied one after another. So, in this example, at first, the "required" rule will be applied and "max_length" after that and only if the "required" passed successfully.   

Here is the [details in LIVR spec](http://livr-spec.org/validation-rules/how-it-works.html) 

You can find the list of standard rules [here](http://livr-spec.org/validation-rules.html)

### Example 2: validation of hierarchical data structure

```perl6
use LIVR;

my $validator = LIVR::Validator.new(livr-rules => {
    name  => 'required',
    phone => {max_length => 10},
    address => {'nested_object' => {
        city => 'required', 
        zip  => ['required', 'positive_integer']
    }}
});

my $user-data = {
    name  => "Michael",
    phone => "0441234567",
    address => {
        city => "Kiev", 
        zip  => "30552"
    }
}

if my $valid-data = $validator.validate($user-data) {
    #  $valid-data is clean and does contain only fields which have validation and have passed it
    $valid-data.say;
} else {
    my $errors = $validator.errors();
    $errors.say;
}
```

**What is interesting in this example?**

1. The schema (validation rules) shape looks very similar to the data shape. It is much easier to read than JSON Schema, for example.
2. It seems that nested\_object is a special syntax but it is not. The validator does not make any difference between 'required', 'nested\_object' 'max_length'. So, the core is very tiny and you can introduce a new feature easily with custom rules. 
3. Often you want to reuse complex validation rules like 'address' and it can be done with aliasing.
4. You will receive a hierarchical error message. For example, if you will miss city and name, the error object will look ```{name => 'REQUIRED', address => {city => 'REQUIRED'} }```

**Aliases**

```perl6
use LIVR;

LIVR::Validator.register-aliased-default-rule({
    name  => 'short_address', # names of the rule
    rules => {'nested_object' => {
        city => 'required', 
        zip  => ['required', 'positive_integer']
    }},
    error => 'WRONG_ADDRESS' # custom error (optional)
});

my $validator = LIVR::Validator.new(livr-rules => {
    name    => 'required',
    phone   => {max_length => 10},
    address => 'short_address'
});

my $user-data = {
    name  => "Michael",
    phone => "0441234567",
    address => {
        city => "Kiev", 
        zip  => "30552"
    }
}

if my $valid-data = $validator.validate($user-data) {
    #  $valid-data is clean and does contain only fields which have validation and have passed it
    $valid-data.say;
} else {
    my $errors = $validator.errors();
    $errors.say;
}
```

If you want, you can register aliases only for your validator instance:

```perl6
use LIVR;

my $validator = LIVR::Validator.new(livr-rules => {
    password => ['required', 'strong_password']
});

$validator.register-aliased-rule({
    name  => 'strong_password',
    rules => {min_length => 6},
    error => 'WEAK_PASSWORD'
});

```

### Example 3: data modification, pipelining.

There are rules that can do data modification. Here is the list of them:

* trim
* to_lc
* to_uc
* remove
* leave_only
* default

You can [read details here](http://livr-spec.org/validation-rules/modifiers.html)

With such approach, you can create some sort of pipe.

```perl6
use LIVR;

my $validator = LIVR::Validator.new(livr-rules => {
    email => [ 'trim', 'required', 'email', 'to_lc' ]
});

my $input-data = { email => ' EMail@Gmail.COM ' };
my $output-data = $validator.validate($input-data);

$output-data.say;
```

**What is important here?**

1. As I mentioned before, for the validator there is no difference between any of the rules. It treats "trim", "default", "required", "nested_object" the same way. 
2. Rules are applied one after another. The output of a rule will be passed to the input of the next rule. It is like a bash pipe ```echo ' EMail@Gmail.COM ' | trim | required | email | to_lc```
3. $input-data will be NEVER changed. $output-data is data you use after the validation.

### Example 4: custom rules

You can use aliases as custom rules but sometimes it is not enough. It is absolutely fine to write an own custom rule. You can do almost everything with custom rules. 

Usually,  we have 1-5 custom rules almost in every our project. Moreover, you can organize custom rules as a separate reusable module (even upload it to CPAN).

**So, how to write a custom rule for LIVR?**

Here is the example of 'strong_password'

```perl6
use LIVR;

my $validator = LIVR::Validator.new(livr-rules => {
    password => ['required', 'strong_password']
});

$validator.register-rules( 'strong_password' =>  sub (@rule-args, %builders) {
    # %builders - are rules from original validator
    # to allow you create new validator with all supported rules
    # my $validator = LIVR::Validator.new(livr-rules => $livr).register-rules(%builders).prepare();
    # See "nested_object" rule implementation for example
    # https://github.com/koorchik/perl6-livr/blob/master/lib/LIVR/Rules/Meta.pm6#L5

    # Return closure that will take value and return error
    return sub ($value, $all-values, $output is rw) {
        # We already have "required" rule to check that the value is present
        return if LIVR::Utils::is-no-value($value); # so we skip empty values

        # Return value is a string
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;

        # Return error in case of failed validation
        return 'WEAK_PASSWORD' if $value.chars < 6;

        # Change output value. We want always return value be a string
        $output = $value.Str; 
        return;
    };
});
```

Look at existing rules implementation for more examples:

* [Common rules](https://github.com/koorchik/perl6-livr/blob/master/lib/LIVR/Rules/Common.pm6)
* [Numeric rules](https://github.com/koorchik/perl6-livr/blob/master/lib/LIVR/Rules/Numeric.pm6)
* [String rules](https://github.com/koorchik/perl6-livr/blob/master/lib/LIVR/Rules/String.pm6)
* [Special rules](https://github.com/koorchik/perl6-livr/blob/master/lib/LIVR/Rules/Special.pm6)
* [Modifiers rules](https://github.com/koorchik/perl6-livr/blob/master/lib/LIVR/Rules/Modifiers.pm6)
* [Meta rules](https://github.com/koorchik/perl6-livr/blob/master/lib/LIVR/Rules/Meta.pm6)

### Example 5: Web application

LIVR works great for REST APIs. Usually, a lot of REST APIs have a problem with returning understandable errors. If a user of your API will receive HTTP error 500, it will not help him. Much better when he will get errors like 

```json
{
    "name": "REQUIRED",
    "phone": "TOO_LONG",
    "address": {
        "city": "REQUIRED",
        "zip": "NOT_POSITIVE_INTEGER"
    }
}
```

than just "Server error".

So, let try to do a small web service with 2 endpoints:

1. GET /notes -> get list of notes
2. POST /notes -> create a note

You will need to install Bailador for it:

```bash
zef install Bailador
```

Let's create some services. I prefer "Command" pattern for the services with template method "run". 

We will have 2 services:

* Service::Notes::Create
* Service::Notes::List

Service usage example
```perl6

my %CONTEXT = (storage => my @STORAGE);

my %note = title => 'Note1', text => 'Note text';
my $new-note = Service::Notes::Create.new( context => %CONTEXT ).run(%note);
my $list = Service::Notes::Create.new( context => %CONTEXT ).run({});
```
With context you can inject any dependencies. "run" method accepts data passed by user. 

Here is how the source code of the service for notes creation looks like:

```perl6
use Service::Base;
my $LAST_ID = 0;
class Service::Notes::Create is Service::Base {
    has %.validation-rules = (
        title => ['required', {max_length => 20} ],
        text  => ['required', {max_length => 255} ]
    );

    method execute(%note) {
        %note<id> = $LAST_ID++;
        $.context<storage>.push(%note);
        
        return %note;
    }
}
```

and the Service::Base class:

```perl6
use LIVR;
LIVR::Validator.default-auto-trim(True);

class Service::Base {
    has $.context = {};

    method run(%params) {
        my %clean-data = self!validate(%params);
        return self.execute(%params);
    }

    method !validate($params) {
        return $params unless %.validation-rules.elems;

        my $validator = LIVR::Validator.new(livr-rules => %.validation-rules);

        if my $valid-data = $validator.validate($params) {
            return $valid-data;
        } else {
            die $validator.errors();
        }
    }
}
```

"run" method guarantees that all procedures are kept:
* Data was validated.
* “execute” will be called only after validation.
* “execute” will receive only clean data.
* Throws an exception in case of validation errors.
* Can check permissions before calling “execute”. 
* Can do extra work like caching validator objects, etc.

Here is [the full working example] (https://github.com/koorchik/perl6-livr-advent-calendar-post/tree/master/examples/example5-restapi).

The app is really tiny. 

Run the app:

```bash
perl6 app.pl6
```

Create a note:

```bash
curl -H "Content-Type: application/json" -X POST -d '{"title":"New Note","text":"Some text here"}' http://localhost:3000/notes
```

Check validation:

```bash
curl -H "Content-Type: application/json" -X POST -d '{"title":"","text":""}' http://localhost:3000/notes
```

Get the list of notes:

```bash
curl http://localhost:3000/notes
```

## LIVR links
* [The source code of all examples](https://github.com/koorchik/perl6-livr-advent-calendar-post/tree/master/examples)
* The post ["LIVR - Data Validation Without Any Issues"]*http://blog.webbylab.com/language-independent-validation-rules-library/)
* [LIVR specifications and docs (the latest version – 2.0)](http://livr-spec.org/)
* [Universal test suite](https://github.com/koorchik/LIVR/tree/master/test_suite)
* You can play online with [LIVR Playground](http://webbylab.github.io/livr-playground/)
* You can play online with [LIVR Multi-Language Playground](http://livr-multi-playground.webbylab.com/)

I hope you will like the LIVR. I will appreciate any feedback. 
