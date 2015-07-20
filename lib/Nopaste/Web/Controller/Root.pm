package Nopaste::Web::Controller::Root;
use Mojo::Base 'Mojolicious::Controller';
use Formvalidator::Lite;
use HTML::FillInForm::Lite;

sub index {
    my $self = shift;
    $self->render();
}

sub post {
    my $self = shift;
    my $validator = FormValidator::Lite->new($self->req);

    $validator->set_message(
        'title.not_null' => 'Title is Empty.',
        'body.not_null' => 'Body is Empty.'
    );

    my $res = $validator->check(
        title => [qw/NOT_NULL/],
        body => [qw/NOT_NULL/]
    );

    if ($validator->has_error) {
        my @messages = $validator->get_error_messages;
        $self->stash->{error_messages} = \@messages;

        my $html = $self->render_to_string('root/index');
        return $self->render(
            text => HTML::FillInForm::Lite->fill(\$html, $self->req->params),
            format => 'html'
        )
    }
}


1;
