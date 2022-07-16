package YAMLScript;
use Mo qw(build default xxx);

our $VERSION = '0.0.8';

use YAMLScript::Compiler;
use YAMLScript::NS;

has from => ();
has file => ();
has yaml => ();
has data => {};

use Carp;

sub BUILD {
    my ($self) = @_;

    if (my $file = $self->file) {
        my $yaml = do {
            open my $fh, '<', $file or die $!;
            my $yaml = do { local $/; <$fh> };
            close $fh;
            $yaml;
        };
        $self->yaml($yaml);
        $self->{from} //= $file;
    }

    if (my $yaml = $self->yaml) {
        my $data = YAML::PP::Load($yaml);
        $self->data($data);
        $self->{from} //= '<YAMLScript string>';
    }
    else {
        die "YAMLScript->new requires 'file' or 'yaml' attribute";
    }
}

sub run {
    my ($self, @args) = @_;

    my $compiler = YAMLScript::Compiler->new(
        space => 'global',
        from => $self->from,
        yaml => $self->yaml,
    );

    my $ns = $compiler->compile;

    ns_push($ns);

    my $arity = @args;
    my $name = "main__$arity";

    my $call = $ns->{$name} or die "Can't find '$name' in ns";
    $call = $call->([@args]);
    $call->call();

    ns_pop;
}

__END__

=pod

=encoding utf-8

=head1 NAME

YAMLScript - Programming in YAML

=head1 SYNOPSIS

File greet.ys:

    #!/usr/bin/env yamlscript

    main(name):
    - for:
      - (..): [1, 5]
      - say: $_) Hello, $name!

Run:

    $ ./greet.ys YAMLScript
    1) Hello, YAMLScript!
    2) Hello, YAMLScript!
    3) Hello, YAMLScript!
    4) Hello, YAMLScript!
    5) Hello, YAMLScript!

=head1 DESCRIPTION

YAMLScript is a programming language encoded in YAML.

See L<https://github.com/ingydotnet/yamlscript#readme> for the current
documentation.

=head1 COPYRIGHT AND LICENSE

Copyright 2022 by Ingy döt Net

This library is free software and may be distributed under the same terms
as perl itself.

=cut