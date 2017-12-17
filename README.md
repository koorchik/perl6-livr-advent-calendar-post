Language Independent Validation Rules (LIVR) for Perl6
------------------------------------------------------

I've just [ported LIVR to Perl6](https://modules.perl6.org/dist/LIVR:cpan:KOORCHIK) . It was really fun to code in Perl6. Moreover, LIVR's test suite allowed me find a bug in Perl6 Email::Valid, and another one in Rakudo itself. It was even more fun that you not just implemented module but helped other developers to do some testing :)

What is LIVR? LIVR stands for "Language Independent Validation Rules". So, it is like ["Mustache"](https://mustache.github.io/) but in world of validation. So, LIVR consists of the following parts:

1. [LIVR Specification](http://livr-spec.org/)
2. [Implemetations for different languages](http://livr-spec.org/introduction/implementations.html).
3. [Universal test suite](https://github.com/koorchik/LIVR/tree/master/test_suite), that is used for checking that the implementation works properly.

There is LIVR for

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

## What is LIVR?

Data validation task is very common. I am sure that every developer faces it again an again. Especially, it is important when you develop Web application. It is a common rule - never trust uset input. It seems that if the task is so common, there should be tons of libraries. Yes it is, but it is very diffucult to find one that is ideal. Some of the libraries are do to many things (like HTML form generation etc), other libraries hard to extend, some does not provide hierarchical data validation etc 

Moreover, if you are a web developer, you need the same validation on the server and on the client.

In WebbyLab, mainly we use 3 programming languages - Perl, JavaScript, PHP. So, for us, it was ideal to reuse similar validation approach across languages. 

So, it was decided to create a univeral validator that could work across different languages.


### Validator Requirements

After trying tons of validators, we had some vision in hour heads about the issues we want to solve.

1. Rules are declarative and language independent. So, rules validation is just a data structure, not method calls etc. You can transform it, change it as you this with a common data structure.
2. Any number of rules for each field. 
3. Validator should return together errors for all fields. For example, we want to highlight all errors in a form.
4. Cut out all fields that do not have validation rules described. (otherwise you cannot rely on your validation, someday you will have security issue if the validator will not meet this property).
5. Possibility to validate complex hierarchical structures. It  
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
6. The specifications are available on livr-spec.org
7. The basic idea was that the description of the validation rules must look like a data scheme and be as similar to data as possible, but with rules instead of values.

### Implementations

## LIVR and Perl6

Let's hava some one and play with with code. I will go with several example, and will provide some internal details after each example.

At first, install LIVR module for Perl6

```bash
zef install LIVR
```

#### Example 1: User registration data validation

```perl6
use LIVR;
LIVR::Validator.default-auto-trim(True); # autotrim all values before validation

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

**How to understand the rules?**

The idea is very simple:

Each rule is a hash:

key - name of the validation rules
value - array of arguments 

For example:

```perl6
{ 
    name  => { required => [] },
    phone => { max_length => [10] }
}
```

but if there is only one agrument, you use a shorter form:

```perl6
{ 
    phone => { max_length => 10 }
}
```

if there is no arguments you can just pass the name of the rule

```perl6
{ 
    name => 'required'
}
```

you can pass list of rules for a field in an array:

```perl6
{ 
    name => [ 'required', { max_length => 10 } ]
}
```

In this case rules will be applied one after another. So, in this example, at first the "required" rule will be applied and "max_length" after that and only if the "required" passed successfully.   


Here is the [details in LIVR spec](http://livr-spec.org/validation-rules/how-it-works.html) 

You can find the list of standard rules here - http://livr-spec.org/validation-rules.html

#### Example 2: Validation of hierarchical data structure

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

What is interesting in this example?

1. The schema (validation rules) shape looks very similar to the data shape. It is much easier to read than JSON Schema, for example.
2. It seems that nested\_object is a special syntax but in real it is not. The validator does not make any difference between 'required', 'nested\_object' 'max_length'. So, the core is very tiny and you can introduce new feature with custom rules. 
3. Often you want to reuse complex validation rules like 'address' and it can be done with aliasing.
4. You will receive hierarchical error message. For example, if you will miss city and name, the error object will look ```{name => 'REQUIRED', address => {city => 'REQUIRED'} }```

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

You can register aliases only for you validator instance:

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


### Example 3: Data modification, pipelining.

There are rules that can do data modification. Here is the list of them:

* trim
* to_lc
* to_uc
* remove
* leave_only
* default

You can read details here - http://livr-spec.org/validation-rules/modifiers.html


With such approach you can create some sort of pipe.


```perl6
use LIVR;

my $validator = LIVR::Validator.new(livr-rules => {
    email => [ 'trim', 'required', 'email', 'to_lc' ]
});

my $input-data = { email => ' EMail@Gmail.COM ' };
my $output-data = $validator.validate($input-data);

$output-data.say;
```

What is important here?

1. As I mentioned before, for the validator there is not difference between any of the rules. It treats "trim", "default", "required", "nested_object" the same way. 
2. Rules are applied one after another. Output of a rule will be passed to the input of the next rule. It is like a bash pipe ```echo ' EMail@Gmail.COM ' | trim | required | email | to_lc```
3. $input-data will be NEVER changed. $outpu-data is data you use after the validation.


### Example 4: Custom rules

You can use aliases as custom rules but sometimes it is not enaugh. It is absolutely fine to write a custom rule. You can do almost everything with custom rules. 

Usually, in WebbyLab we have several custom rules almost in every of our project. Moreover, you can organize custom rules as a separate reusable module (even upload it to CPAN).

So, how to write a custom rule for LIVR?

And here is the example of 'strong_password'

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


## LIVR links
- [LIVR - Data Validation Without Any Issues](http://blog.webbylab.com/language-independent-validation-rules-library/)
- [LIVR specifications (the latest version – 2.0)](http://livr-spec.org/)
- [Test suite](https://github.com/koorchik/LIVR/tree/master/test_suite)
- [LIVR Playground](http://webbylab.github.io/livr-playground/)
- [LIVR Multi-Language Playground](http://livr-multi-playground.webbylab.com/)
