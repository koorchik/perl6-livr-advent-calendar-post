use LIVR;

my $validator = LIVR::Validator.new(livr-rules => {
    email => [ 'trim', 'required', 'email', 'to_lc' ]
});

my $input-data = { email => ' EMail@Gmail.COM ' };
my $output-data = $validator.validate($input-data);

$output-data.say;