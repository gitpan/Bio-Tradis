package Bio::Tradis::Parser::Fastq;

# ABSTRACT: Basic FastQ parser.


use Moose;

has 'file' => ( is => 'rw', isa => 'Str', required => 1 );
has '_fastq_handle' => (
    is       => 'ro',
    isa      => 'FileHandle',
    required => 0,
    lazy     => 1,
    builder  => '_build__fastq_handle'
);
has '_currentread' => (
    is       => 'rw',
    isa      => 'Str',
    required => 0,
    writer   => '_set_currentread'
);
### Private methods ###

sub _build__fastq_handle {
    my ($self) = @_;
    my $fastqfile = $self->file;

    open( my $fqh, "<", $fastqfile ) or die "Cannot open $fastqfile";
    return $fqh;
}

### Public methods ###


sub next_read {
    my ($self) = @_;
    my $fqh = $self->_fastq_handle;

    my $read = <$fqh>;
    if ( defined($read) ) {
        $self->_set_currentread($read);
        return 1;
    }
    else {
        return 0;
    }
}

sub read_info {
    my ($self) = @_;
    my $fqh = $self->_fastq_handle;

    my @fastq_read;

    # get id
    my $id = $self->_currentread;
    chomp($id);
    $id =~ s/^\@//;
    push( @fastq_read, $id );

    # get sequence
    my $seq = <$fqh>;
    chomp($seq);
    push( @fastq_read, $seq );

    # skip + line
    my $skip = <$fqh>;

    # get quality
    my $qual = <$fqh>;
    chomp($qual);
    push( @fastq_read, $qual );

    return @fastq_read;

}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=pod

=head1 NAME

Bio::Tradis::Parser::Fastq - Basic FastQ parser.

=head1 VERSION

version 1.132190

=head1 SYNOPSIS

Parses fastq files. 
use Bio::Tradis::Parser::Fastq;

   my $pipeline = Bio::Tradis::Parser::Fastq->new(file => 'abc');
   $pipeline->next_read;
   $pipeline->read_info;

=next_read 
Moves to the next read. Returns 1 if read exists, returns 0
if EOF

=read_info 
Returns an array of info for the read in an array.
0 = id
1 = sequence
2 = quality string

=head1 AUTHOR

Carla Cummins <cc21@sanger.ac.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Wellcome Trust Sanger Institute.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
