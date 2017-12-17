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

my $input-data = {
    password => 'qaz'
};

if my $valid-data = $validator.validate($input-data) {
    #  $valid-data is clean and does contain only fields which have validation and have passed it
    $valid-data.say;
} else {
    my $errors = $validator.errors();
    $errors.say;
}