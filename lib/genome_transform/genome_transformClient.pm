package genome_transform::genome_transformClient;

use JSON::RPC::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};

use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

genome_transform::genome_transformClient

=head1 DESCRIPTION


A KBase module: genome_transform
This sample module contains one small method - filter_contigs.


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => genome_transform::genome_transformClient::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
        else
        {
	    #
	    # All methods in this module require authentication. In this case, if we
	    # don't have a token, we can't continue.
	    #
	    die "Authentication failed: " . $token->error_message;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 genbank_to_genome

  $return = $obj->genbank_to_genome($genbank_to_genome_params)

=over 4

=item Parameter and return types

=begin html

<pre>
$genbank_to_genome_params is a genome_transform.genbank_to_genome_params
$return is a genome_transform.object_id
genbank_to_genome_params is a reference to a hash where the following keys are defined:
	genbank_shock_ref has a value which is a genome_transform.shock_ref
	genbank_file_path has a value which is a genome_transform.file_path
	workspace has a value which is a genome_transform.workspace_id
	genome_id has a value which is a genome_transform.object_id
	contigset_id has a value which is a genome_transform.object_id
shock_ref is a string
file_path is a string
workspace_id is a string
object_id is a string

</pre>

=end html

=begin text

$genbank_to_genome_params is a genome_transform.genbank_to_genome_params
$return is a genome_transform.object_id
genbank_to_genome_params is a reference to a hash where the following keys are defined:
	genbank_shock_ref has a value which is a genome_transform.shock_ref
	genbank_file_path has a value which is a genome_transform.file_path
	workspace has a value which is a genome_transform.workspace_id
	genome_id has a value which is a genome_transform.object_id
	contigset_id has a value which is a genome_transform.object_id
shock_ref is a string
file_path is a string
workspace_id is a string
object_id is a string


=end text

=item Description



=back

=cut

 sub genbank_to_genome
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function genbank_to_genome (received $n, expecting 1)");
    }
    {
	my($genbank_to_genome_params) = @args;

	my @_bad_arguments;
        (ref($genbank_to_genome_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genbank_to_genome_params\" (value was \"$genbank_to_genome_params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to genbank_to_genome:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'genbank_to_genome');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "genome_transform.genbank_to_genome",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'genbank_to_genome',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method genbank_to_genome",
					    status_line => $self->{client}->status_line,
					    method_name => 'genbank_to_genome',
				       );
    }
}
 


=head2 fasta_to_contig

  $return = $obj->fasta_to_contig($fasta_to_contig_params)

=over 4

=item Parameter and return types

=begin html

<pre>
$fasta_to_contig_params is a genome_transform.fasta_to_contig_params
$return is a genome_transform.object_id
fasta_to_contig_params is a reference to a hash where the following keys are defined:
	fasta_shock_ref has a value which is a genome_transform.shock_ref
	fasta_file_path has a value which is a genome_transform.file_path
	workspace has a value which is a genome_transform.workspace_id
	genome_id has a value which is a genome_transform.object_id
	contigset_id has a value which is a genome_transform.object_id
shock_ref is a string
file_path is a string
workspace_id is a string
object_id is a string

</pre>

=end html

=begin text

$fasta_to_contig_params is a genome_transform.fasta_to_contig_params
$return is a genome_transform.object_id
fasta_to_contig_params is a reference to a hash where the following keys are defined:
	fasta_shock_ref has a value which is a genome_transform.shock_ref
	fasta_file_path has a value which is a genome_transform.file_path
	workspace has a value which is a genome_transform.workspace_id
	genome_id has a value which is a genome_transform.object_id
	contigset_id has a value which is a genome_transform.object_id
shock_ref is a string
file_path is a string
workspace_id is a string
object_id is a string


=end text

=item Description



=back

=cut

 sub fasta_to_contig
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function fasta_to_contig (received $n, expecting 1)");
    }
    {
	my($fasta_to_contig_params) = @args;

	my @_bad_arguments;
        (ref($fasta_to_contig_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"fasta_to_contig_params\" (value was \"$fasta_to_contig_params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to fasta_to_contig:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'fasta_to_contig');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "genome_transform.fasta_to_contig",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'fasta_to_contig',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method fasta_to_contig",
					    status_line => $self->{client}->status_line,
					    method_name => 'fasta_to_contig',
				       );
    }
}
 


=head2 tsv_to_exp

  $return = $obj->tsv_to_exp($tsv_to_exp_params)

=over 4

=item Parameter and return types

=begin html

<pre>
$tsv_to_exp_params is a genome_transform.tsv_to_exp_params
$return is a genome_transform.object_id
tsv_to_exp_params is a reference to a hash where the following keys are defined:
	tsvexp_shock_ref has a value which is a genome_transform.shock_ref
	tsvexp_file_path has a value which is a genome_transform.file_path
	workspace has a value which is a genome_transform.workspace_id
	genome_id has a value which is a genome_transform.object_id
	expMaxId has a value which is a genome_transform.object_id
shock_ref is a string
file_path is a string
workspace_id is a string
object_id is a string

</pre>

=end html

=begin text

$tsv_to_exp_params is a genome_transform.tsv_to_exp_params
$return is a genome_transform.object_id
tsv_to_exp_params is a reference to a hash where the following keys are defined:
	tsvexp_shock_ref has a value which is a genome_transform.shock_ref
	tsvexp_file_path has a value which is a genome_transform.file_path
	workspace has a value which is a genome_transform.workspace_id
	genome_id has a value which is a genome_transform.object_id
	expMaxId has a value which is a genome_transform.object_id
shock_ref is a string
file_path is a string
workspace_id is a string
object_id is a string


=end text

=item Description



=back

=cut

 sub tsv_to_exp
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function tsv_to_exp (received $n, expecting 1)");
    }
    {
	my($tsv_to_exp_params) = @args;

	my @_bad_arguments;
        (ref($tsv_to_exp_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"tsv_to_exp_params\" (value was \"$tsv_to_exp_params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to tsv_to_exp:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'tsv_to_exp');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "genome_transform.tsv_to_exp",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'tsv_to_exp',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method tsv_to_exp",
					    status_line => $self->{client}->status_line,
					    method_name => 'tsv_to_exp',
				       );
    }
}
 


=head2 reads_to_assembly

  $return = $obj->reads_to_assembly($reads_to_assembly_params)

=over 4

=item Parameter and return types

=begin html

<pre>
$reads_to_assembly_params is a genome_transform.reads_to_assembly_params
$return is a genome_transform.object_id
reads_to_assembly_params is a reference to a hash where the following keys are defined:
	reads_shock_ref has a value which is a genome_transform.shock_ref
	reads_handle_ref has a value which is a genome_transform.handle_ref
	reads_type has a value which is a string
	file_path_list has a value which is a reference to a list where each element is a string
	workspace has a value which is a genome_transform.workspace_id
	reads_id has a value which is a genome_transform.object_id
	outward has a value which is a string
	insert_size has a value which is a float
	std_dev has a value which is a float
shock_ref is a string
handle_ref is a string
workspace_id is a string
object_id is a string

</pre>

=end html

=begin text

$reads_to_assembly_params is a genome_transform.reads_to_assembly_params
$return is a genome_transform.object_id
reads_to_assembly_params is a reference to a hash where the following keys are defined:
	reads_shock_ref has a value which is a genome_transform.shock_ref
	reads_handle_ref has a value which is a genome_transform.handle_ref
	reads_type has a value which is a string
	file_path_list has a value which is a reference to a list where each element is a string
	workspace has a value which is a genome_transform.workspace_id
	reads_id has a value which is a genome_transform.object_id
	outward has a value which is a string
	insert_size has a value which is a float
	std_dev has a value which is a float
shock_ref is a string
handle_ref is a string
workspace_id is a string
object_id is a string


=end text

=item Description



=back

=cut

 sub reads_to_assembly
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function reads_to_assembly (received $n, expecting 1)");
    }
    {
	my($reads_to_assembly_params) = @args;

	my @_bad_arguments;
        (ref($reads_to_assembly_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"reads_to_assembly_params\" (value was \"$reads_to_assembly_params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to reads_to_assembly:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'reads_to_assembly');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "genome_transform.reads_to_assembly",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'reads_to_assembly',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method reads_to_assembly",
					    status_line => $self->{client}->status_line,
					    method_name => 'reads_to_assembly',
				       );
    }
}
 


=head2 sra_reads_to_assembly

  $return = $obj->sra_reads_to_assembly($reads_to_assembly_params)

=over 4

=item Parameter and return types

=begin html

<pre>
$reads_to_assembly_params is a genome_transform.reads_to_assembly_params
$return is a genome_transform.object_id
reads_to_assembly_params is a reference to a hash where the following keys are defined:
	reads_shock_ref has a value which is a genome_transform.shock_ref
	reads_handle_ref has a value which is a genome_transform.handle_ref
	reads_type has a value which is a string
	file_path_list has a value which is a reference to a list where each element is a string
	workspace has a value which is a genome_transform.workspace_id
	reads_id has a value which is a genome_transform.object_id
	outward has a value which is a string
	insert_size has a value which is a float
	std_dev has a value which is a float
shock_ref is a string
handle_ref is a string
workspace_id is a string
object_id is a string

</pre>

=end html

=begin text

$reads_to_assembly_params is a genome_transform.reads_to_assembly_params
$return is a genome_transform.object_id
reads_to_assembly_params is a reference to a hash where the following keys are defined:
	reads_shock_ref has a value which is a genome_transform.shock_ref
	reads_handle_ref has a value which is a genome_transform.handle_ref
	reads_type has a value which is a string
	file_path_list has a value which is a reference to a list where each element is a string
	workspace has a value which is a genome_transform.workspace_id
	reads_id has a value which is a genome_transform.object_id
	outward has a value which is a string
	insert_size has a value which is a float
	std_dev has a value which is a float
shock_ref is a string
handle_ref is a string
workspace_id is a string
object_id is a string


=end text

=item Description



=back

=cut

 sub sra_reads_to_assembly
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function sra_reads_to_assembly (received $n, expecting 1)");
    }
    {
	my($reads_to_assembly_params) = @args;

	my @_bad_arguments;
        (ref($reads_to_assembly_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"reads_to_assembly_params\" (value was \"$reads_to_assembly_params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to sra_reads_to_assembly:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'sra_reads_to_assembly');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "genome_transform.sra_reads_to_assembly",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'sra_reads_to_assembly',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method sra_reads_to_assembly",
					    status_line => $self->{client}->status_line,
					    method_name => 'sra_reads_to_assembly',
				       );
    }
}
 
  

sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "genome_transform.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'sra_reads_to_assembly',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method sra_reads_to_assembly",
            status_line => $self->{client}->status_line,
            method_name => 'sra_reads_to_assembly',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for genome_transform::genome_transformClient\n";
    }
    if ($sMajor == 0) {
        warn "genome_transform::genome_transformClient version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 shock_ref

=over 4



=item Description

URL to a shock node containing a data file for upload


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 file_path

=over 4



=item Description

Path to a file containing a data file for upload on the local filesystem


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 file_type

=over 4



=item Description

Type to a file containing a data file for upload on the local filesystem


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 object_id

=over 4



=item Description

Name of an object in the KBase workspace


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 report_id

=over 4



=item Description

Name of an report id


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 outward

=over 4



=item Description

status of the reads pair point outward or not


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 workspace_id

=over 4



=item Description

Name of a KBase workspace


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 reads_type

=over 4



=item Description

Name of a KBase reads type


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 reads_id

=over 4



=item Description

Name of a KBase reads_id


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 file_path_list

=over 4



=item Description

Name of a KBase file_path_list


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 handle_ref

=over 4



=item Description

Name of a KBase handle ref


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 std_dev

=over 4



=item Description

Name of a standard deviation


=item Definition

=begin html

<pre>
a float
</pre>

=end html

=begin text

a float

=end text

=back



=head2 insert_size

=over 4



=item Description

Name of a insert size


=item Definition

=begin html

<pre>
a float
</pre>

=end html

=begin text

a float

=end text

=back



=head2 genbank_to_genome_params

=over 4



=item Description

Input parameters for the "genbank_to_genome" function.

        shock_ref genbank_shock_ref - optional URL to genbank file stored in Shock
        file_path genbank_file_path - optional path to genbank file on local file system
        workspace_id workspace - workspace where object will be saved
        object_id genome_id - workspace ID to which the genome object should be saved
        object_id contigset_id - workspace ID to which the contigs should be saved


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genbank_shock_ref has a value which is a genome_transform.shock_ref
genbank_file_path has a value which is a genome_transform.file_path
workspace has a value which is a genome_transform.workspace_id
genome_id has a value which is a genome_transform.object_id
contigset_id has a value which is a genome_transform.object_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genbank_shock_ref has a value which is a genome_transform.shock_ref
genbank_file_path has a value which is a genome_transform.file_path
workspace has a value which is a genome_transform.workspace_id
genome_id has a value which is a genome_transform.object_id
contigset_id has a value which is a genome_transform.object_id


=end text

=back



=head2 fasta_to_contig_params

=over 4



=item Description

Input parameters for the "fasta_to_contig" function.

        shock_ref shock_ref - optional URL to fasta file stored in Shock
        file_path file_path - optional path to fasta file on local file system
        workspace_id workspace - workspace where object will be saved
        object_id genome_id - workspace ID to which the contigs object should be saved
        object_id contigset_id - workspace ID to which the contigs should be saved


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
fasta_shock_ref has a value which is a genome_transform.shock_ref
fasta_file_path has a value which is a genome_transform.file_path
workspace has a value which is a genome_transform.workspace_id
genome_id has a value which is a genome_transform.object_id
contigset_id has a value which is a genome_transform.object_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
fasta_shock_ref has a value which is a genome_transform.shock_ref
fasta_file_path has a value which is a genome_transform.file_path
workspace has a value which is a genome_transform.workspace_id
genome_id has a value which is a genome_transform.object_id
contigset_id has a value which is a genome_transform.object_id


=end text

=back



=head2 tsv_to_exp_params

=over 4



=item Description

Input parameters for the "exp tsv to exp matirx" function.

        shock_ref shock_ref - optional URL to genbank file stored in Shock
        file_path file_path - optional path to genbank file on local file system
        workspace_id workspace - workspace where object will be saved
        object_id genome_id - workspace ID to which the genome object should be saved
        object_id contigset_id - workspace ID to which the contigs should be saved


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
tsvexp_shock_ref has a value which is a genome_transform.shock_ref
tsvexp_file_path has a value which is a genome_transform.file_path
workspace has a value which is a genome_transform.workspace_id
genome_id has a value which is a genome_transform.object_id
expMaxId has a value which is a genome_transform.object_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
tsvexp_shock_ref has a value which is a genome_transform.shock_ref
tsvexp_file_path has a value which is a genome_transform.file_path
workspace has a value which is a genome_transform.workspace_id
genome_id has a value which is a genome_transform.object_id
expMaxId has a value which is a genome_transform.object_id


=end text

=back



=head2 reads_to_assembly_params

=over 4



=item Description

Input parameters for the "reads to assembly" function.

shock_ref shock_ref - optional URL to genbank file stored in Shock
file_path file_path - optional path to genbank file on local file system
workspace_id workspace - workspace where object will be saved
object_id reads_id - workspace ID to which the genome object should be saved
object_id contigset_id - workspace ID to which the contigs should be saved


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
reads_shock_ref has a value which is a genome_transform.shock_ref
reads_handle_ref has a value which is a genome_transform.handle_ref
reads_type has a value which is a string
file_path_list has a value which is a reference to a list where each element is a string
workspace has a value which is a genome_transform.workspace_id
reads_id has a value which is a genome_transform.object_id
outward has a value which is a string
insert_size has a value which is a float
std_dev has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
reads_shock_ref has a value which is a genome_transform.shock_ref
reads_handle_ref has a value which is a genome_transform.handle_ref
reads_type has a value which is a string
file_path_list has a value which is a reference to a list where each element is a string
workspace has a value which is a genome_transform.workspace_id
reads_id has a value which is a genome_transform.object_id
outward has a value which is a string
insert_size has a value which is a float
std_dev has a value which is a float


=end text

=back



=cut

package genome_transform::genome_transformClient::RpcClient;
use base 'JSON::RPC::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
