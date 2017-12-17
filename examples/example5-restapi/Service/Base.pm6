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