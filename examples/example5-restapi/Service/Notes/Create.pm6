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
