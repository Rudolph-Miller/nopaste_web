package Nopaste::Web;
use Mojo::Base 'Mojolicious';

sub startup {
  my $self = shift;

  $self->plugin('PODRenderer');

  my $r = $self->routes;

  $r->get('/')->to('root#index');
}

1;
