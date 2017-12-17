use Service::Base;

class Service::Notes::List is Service::Base {
    has %.validation-rules;

    method execute(%data) {
        return $.context<storage>;
    }
}