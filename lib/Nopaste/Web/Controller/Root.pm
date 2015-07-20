package Nopaste::Web::Controller::Root;
use Mojo::Base 'Mojolicious::Controller';
use Formvalidator::Lite;
use HTML::FillInForm::Lite;
use Data::GUID::URLSafe;
use Text::VimColor;
use Encode;

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
        );
    }

    my $entry = $self->app->db->insert('entry', {
        id => Data::GUID->new->as_base64_urlsafe,
        title => $self->req->param('title'),
        body => $self->req->param('body')
    });

    $self->redirect_to('/paste/' . $entry->id);
}

sub paste {
    my $self = shift;
    my $entry = $self->app->db->single('entry', { id => $self->stash->{id} });
    unless ( $entry ) {
        returt $self->render_not_found;
    }

    my $syntax = Text::VimColor->new(
        filetype => 'perl',
        string => Encode::encode_utf8( $entry->body )
    );
    $self->stash->{code} = Encode::decode_utf8($syntax->html);
    $self->stash->{entry} = $entry;
}

1;
