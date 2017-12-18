use lib '.';

use Bailador;
use Service::Notes::Create;
use Service::Notes::List;

my %CONTEXT = storage => my @STORAGE;

sub run-sevice($service-class, %params) {
    my $result = $service-class.new( context => %CONTEXT ).run(%params);

    return to-json({ status => 1, data => $result });

    CATCH {
        when X::AdHoc {
            my $error = $_.payload;
            return to-json({ status => 0, error => $error });
        }
    }
}

get '/notes' => sub {
    run-sevice(Service::Notes::List, {});
}

post '/notes' => sub {
    my $data = from-json(request.body);
    run-sevice(Service::Notes::Create, $data);
}

### Add some test data
Service::Notes::Create.new( context => %CONTEXT ).run({title => 'My first note', text => 'Some text here'});
Service::Notes::Create.new( context => %CONTEXT ).run({title => 'My second note', text => 'Some text here 2'});

baile();

### Several curl command to check the API
# Create note
# curl -H "Content-Type: application/json" -X POST -d '{"title":"New Note","text":"Some text here"}' http://localhost:3000/notes

# Check validation
# curl -H "Content-Type: application/json" -X POST -d '{"title":"","text":""}' http://localhost:3000/notes

# Get list of notes
# curl http://localhost:3000/notes