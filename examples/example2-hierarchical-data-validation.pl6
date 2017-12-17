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