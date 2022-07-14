package YS::Core;
use Mo qw(xxx);
use YAMLScript::Util;

sub define {
    my ($self, $ns) = @_;

    [
        add =>
        2 => sub { $_[0] + $_[1] },
        op => '+',
    ],
    [
        sub =>
        2 => sub { $_[0] - $_[1] },
        op => '-',
    ],
    [
        mul =>
        2 => sub { $_[0] * $_[1] },
        op => '*',
    ],
    [
        div =>
        2 => sub { $_[0] / $_[1] },
        op => '/',
    ],

    [
        conj =>
        2 => sub {
            my ($list, $val) = @_;
            push @$list, $val;
            return $list;
        },
    ],

    [
        def =>
        2 => sub {
            my ($var, $val) = @_;
            $ns->{$var} = $val;
            return $var;
        },
    ],

    [
        do =>
        _ => sub {
            $_->call for @_;
        },
        macro => 1,
    ],

    [
        for =>
        _ => sub {
            my ($list, @stmt) = @_;
            $list = $self->val($list);
            for (@$list) {
                $ns->{_} = $_;
                for my $stmt (@stmt) {
                    $stmt->call;
                }
            }
            delete $ns->{_};
            return;
        },
        macro => 1,
    ],

    [
        len =>
        1 => sub {
            my ($string) = @_;
            return length $string;
        },
    ],

    [
        range =>
        2 => sub {
            my ($min, $max) = @_;
            return [ $min .. $max ];
        },
        op => '..',
    ],

    [
        say =>
        1 => sub {
            my ($string) = @_;
            local $ns->{foo} = 1;
            $string = $self->val($string);
            print $string . "\n";
        },
    ],
}

1;
