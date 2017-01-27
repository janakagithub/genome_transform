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
	html_link has a value which is a genome_transform.object_id
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
	html_link has a value which is a genome_transform.object_id
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

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
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
 


=head2 narrative_genbank_to_genome

  $return = $obj->narrative_genbank_to_genome($narrativeGenbank_to_genome_params)

=over 4

=item Parameter and return types

=begin html

<pre>
$narrativeGenbank_to_genome_params is a genome_transform.narrativeGenbank_to_genome_params
$return is a genome_transform.object_id
narrativeGenbank_to_genome_params is a reference to a hash where the following keys are defined:
	genbank_file_path has a value which is a genome_transform.file_path
	workspace has a value which is a genome_transform.workspace_id
	genome_id has a value which is a genome_transform.object_id
	html_link has a value which is a genome_transform.object_id
file_path is a string
workspace_id is a string
object_id is a string

</pre>

=end html

=begin text

$narrativeGenbank_to_genome_params is a genome_transform.narrativeGenbank_to_genome_params
$return is a genome_transform.object_id
narrativeGenbank_to_genome_params is a reference to a hash where the following keys are defined:
	genbank_file_path has a value which is a genome_transform.file_path
	workspace has a value which is a genome_transform.workspace_id
	genome_id has a value which is a genome_transform.object_id
	html_link has a value which is a genome_transform.object_id
file_path is a string
workspace_id is a string
object_id is a string


=end text

=item Description



=back

=cut

 sub narrative_genbank_to_genome
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function narrative_genbank_to_genome (received $n, expecting 1)");
    }
    {
	my($narrativeGenbank_to_genome_params) = @args;

	my @_bad_arguments;
        (ref($narrativeGenbank_to_genome_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"narrativeGenbank_to_genome_params\" (value was \"$narrativeGenbank_to_genome_params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to narrative_genbank_to_genome:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'narrative_genbank_to_genome');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "genome_transform.narrative_genbank_to_genome",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'narrative_genbank_to_genome',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method narrative_genbank_to_genome",
					    status_line => $self->{client}->status_line,
					    method_name => 'narrative_genbank_to_genome',
				       );
    }
}
 


=head2 genbank_to_genome_GFU

  $return = $obj->genbank_to_genome_GFU($genomeFileUtilInput)

=over 4

=item Parameter and return types

=begin html

<pre>
$genomeFileUtilInput is a genome_transform.genomeFileUtilInput
$return is a genome_transform.object_id
genomeFileUtilInput is a reference to a hash where the following keys are defined:
	file has a value which is a genome_transform.File
	file_path has a value which is a string
	genome_name has a value which is a string
	workspace_name has a value which is a string
	source has a value which is a string
	taxon_wsname has a value which is a string
	taxon_reference has a value which is a string
	release has a value which is a string
	generate_ids_if_needed has a value which is a string
	genetic_code has a value which is an int
	type has a value which is a string
	metadata has a value which is a genome_transform.usermeta
File is a reference to a hash where the following keys are defined:
	path has a value which is a string
	shock_id has a value which is a string
	ftp_url has a value which is a string
usermeta is a reference to a hash where the key is a string and the value is a string
object_id is a string

</pre>

=end html

=begin text

$genomeFileUtilInput is a genome_transform.genomeFileUtilInput
$return is a genome_transform.object_id
genomeFileUtilInput is a reference to a hash where the following keys are defined:
	file has a value which is a genome_transform.File
	file_path has a value which is a string
	genome_name has a value which is a string
	workspace_name has a value which is a string
	source has a value which is a string
	taxon_wsname has a value which is a string
	taxon_reference has a value which is a string
	release has a value which is a string
	generate_ids_if_needed has a value which is a string
	genetic_code has a value which is an int
	type has a value which is a string
	metadata has a value which is a genome_transform.usermeta
File is a reference to a hash where the following keys are defined:
	path has a value which is a string
	shock_id has a value which is a string
	ftp_url has a value which is a string
usermeta is a reference to a hash where the key is a string and the value is a string
object_id is a string


=end text

=item Description



=back

=cut

 sub genbank_to_genome_GFU
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function genbank_to_genome_GFU (received $n, expecting 1)");
    }
    {
	my($genomeFileUtilInput) = @args;

	my @_bad_arguments;
        (ref($genomeFileUtilInput) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"genomeFileUtilInput\" (value was \"$genomeFileUtilInput\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to genbank_to_genome_GFU:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'genbank_to_genome_GFU');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "genome_transform.genbank_to_genome_GFU",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'genbank_to_genome_GFU',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method genbank_to_genome_GFU",
					    status_line => $self->{client}->status_line,
					    method_name => 'genbank_to_genome_GFU',
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

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
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

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
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
	rnaSeqMetaData has a value which is a reference to a hash where the key is a string and the value is a genome_transform.rnaSeqMeta
	workspace has a value which is a genome_transform.workspace_id
	reads_id has a value which is a genome_transform.object_id
	outward has a value which is a string
	insert_size has a value which is a float
	std_dev has a value which is a float
shock_ref is a string
handle_ref is a string
rnaSeqMeta is a reference to a hash where the following keys are defined:
	domain has a value which is a string
	platform has a value which is a string
	sample_id has a value which is a string
	condition has a value which is a string
	source has a value which is a string
	Library_type has a value which is a string
	publication_Id has a value which is a string
	external_source_date has a value which is a string
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
	rnaSeqMetaData has a value which is a reference to a hash where the key is a string and the value is a genome_transform.rnaSeqMeta
	workspace has a value which is a genome_transform.workspace_id
	reads_id has a value which is a genome_transform.object_id
	outward has a value which is a string
	insert_size has a value which is a float
	std_dev has a value which is a float
shock_ref is a string
handle_ref is a string
rnaSeqMeta is a reference to a hash where the following keys are defined:
	domain has a value which is a string
	platform has a value which is a string
	sample_id has a value which is a string
	condition has a value which is a string
	source has a value which is a string
	Library_type has a value which is a string
	publication_Id has a value which is a string
	external_source_date has a value which is a string
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

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
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
	rnaSeqMetaData has a value which is a reference to a hash where the key is a string and the value is a genome_transform.rnaSeqMeta
	workspace has a value which is a genome_transform.workspace_id
	reads_id has a value which is a genome_transform.object_id
	outward has a value which is a string
	insert_size has a value which is a float
	std_dev has a value which is a float
shock_ref is a string
handle_ref is a string
rnaSeqMeta is a reference to a hash where the following keys are defined:
	domain has a value which is a string
	platform has a value which is a string
	sample_id has a value which is a string
	condition has a value which is a string
	source has a value which is a string
	Library_type has a value which is a string
	publication_Id has a value which is a string
	external_source_date has a value which is a string
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
	rnaSeqMetaData has a value which is a reference to a hash where the key is a string and the value is a genome_transform.rnaSeqMeta
	workspace has a value which is a genome_transform.workspace_id
	reads_id has a value which is a genome_transform.object_id
	outward has a value which is a string
	insert_size has a value which is a float
	std_dev has a value which is a float
shock_ref is a string
handle_ref is a string
rnaSeqMeta is a reference to a hash where the following keys are defined:
	domain has a value which is a string
	platform has a value which is a string
	sample_id has a value which is a string
	condition has a value which is a string
	source has a value which is a string
	Library_type has a value which is a string
	publication_Id has a value which is a string
	external_source_date has a value which is a string
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

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
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
 


=head2 rna_sample_set

  $return = $obj->rna_sample_set($rna_sample_set_params)

=over 4

=item Parameter and return types

=begin html

<pre>
$rna_sample_set_params is a genome_transform.rna_sample_set_params
$return is a genome_transform.object_id
rna_sample_set_params is a reference to a hash where the following keys are defined:
	workspace has a value which is a genome_transform.workspace_id
	domain has a value which is a string
	sampleset_id has a value which is a string
	sampleset_desc has a value which is a string
	rnaSeqSample has a value which is a reference to a list where each element is a genome_transform.rnaseq_sequence_params
workspace_id is a string
rnaseq_sequence_params is a reference to a hash where the following keys are defined:
	reads_shock_ref has a value which is a genome_transform.shock_ref
	reads_handle_ref has a value which is a genome_transform.handle_ref
	reads_type has a value which is a string
	file_path_list has a value which is a reference to a list where each element is a string
	rnaSeqMetaData has a value which is a reference to a hash where the key is a string and the value is a genome_transform.rnaSeqMeta
	workspace has a value which is a genome_transform.workspace_id
	reads_id has a value which is a genome_transform.object_id
	outward has a value which is a string
	insert_size has a value which is a float
	std_dev has a value which is a float
	sra has a value which is an int
shock_ref is a string
handle_ref is a string
rnaSeqMeta is a reference to a hash where the following keys are defined:
	domain has a value which is a string
	platform has a value which is a string
	sample_id has a value which is a string
	condition has a value which is a string
	source has a value which is a string
	Library_type has a value which is a string
	publication_Id has a value which is a string
	external_source_date has a value which is a string
object_id is a string

</pre>

=end html

=begin text

$rna_sample_set_params is a genome_transform.rna_sample_set_params
$return is a genome_transform.object_id
rna_sample_set_params is a reference to a hash where the following keys are defined:
	workspace has a value which is a genome_transform.workspace_id
	domain has a value which is a string
	sampleset_id has a value which is a string
	sampleset_desc has a value which is a string
	rnaSeqSample has a value which is a reference to a list where each element is a genome_transform.rnaseq_sequence_params
workspace_id is a string
rnaseq_sequence_params is a reference to a hash where the following keys are defined:
	reads_shock_ref has a value which is a genome_transform.shock_ref
	reads_handle_ref has a value which is a genome_transform.handle_ref
	reads_type has a value which is a string
	file_path_list has a value which is a reference to a list where each element is a string
	rnaSeqMetaData has a value which is a reference to a hash where the key is a string and the value is a genome_transform.rnaSeqMeta
	workspace has a value which is a genome_transform.workspace_id
	reads_id has a value which is a genome_transform.object_id
	outward has a value which is a string
	insert_size has a value which is a float
	std_dev has a value which is a float
	sra has a value which is an int
shock_ref is a string
handle_ref is a string
rnaSeqMeta is a reference to a hash where the following keys are defined:
	domain has a value which is a string
	platform has a value which is a string
	sample_id has a value which is a string
	condition has a value which is a string
	source has a value which is a string
	Library_type has a value which is a string
	publication_Id has a value which is a string
	external_source_date has a value which is a string
object_id is a string


=end text

=item Description



=back

=cut

 sub rna_sample_set
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function rna_sample_set (received $n, expecting 1)");
    }
    {
	my($rna_sample_set_params) = @args;

	my @_bad_arguments;
        (ref($rna_sample_set_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"rna_sample_set_params\" (value was \"$rna_sample_set_params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to rna_sample_set:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'rna_sample_set');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "genome_transform.rna_sample_set",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'rna_sample_set',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method rna_sample_set",
					    status_line => $self->{client}->status_line,
					    method_name => 'rna_sample_set',
				       );
    }
}
 


=head2 reads_to_library

  $return = $obj->reads_to_library($reads_to_library_params)

=over 4

=item Parameter and return types

=begin html

<pre>
$reads_to_library_params is a genome_transform.reads_to_library_params
$return is a genome_transform.object_id
reads_to_library_params is a reference to a hash where the following keys are defined:
	file_path_list has a value which is a reference to a list where each element is a string
	file_path has a value which is a string
	fwd_file has a value which is a string
	rev_file has a value which is a string
	wsname has a value which is a string
	wsid has a value which is an int
	name has a value which is a string
	objid has a value which is an int
	interleaved has a value which is an int
	insert_size_mean has a value which is a float
	insert_size_std_dev has a value which is a float
	read_orientation_outward has a value which is an int
	sequencing_tech has a value which is a string
	single_genome has a value which is an int
	strain has a value which is a KBaseCommon.StrainInfo
	source has a value which is a KBaseCommon.SourceInfo
StrainInfo is a reference to a hash where the following keys are defined:
	genetic_code has a value which is an int
	genus has a value which is a string
	species has a value which is a string
	strain has a value which is a string
	organelle has a value which is a string
	source has a value which is a KBaseCommon.SourceInfo
	ncbi_taxid has a value which is an int
	location has a value which is a KBaseCommon.Location
SourceInfo is a reference to a hash where the following keys are defined:
	source has a value which is a string
	source_id has a value which is a KBaseCommon.source_id
	project_id has a value which is a KBaseCommon.project_id
source_id is a string
project_id is a string
Location is a reference to a hash where the following keys are defined:
	lat has a value which is a float
	lon has a value which is a float
	elevation has a value which is a float
	date has a value which is a string
	description has a value which is a string
object_id is a string

</pre>

=end html

=begin text

$reads_to_library_params is a genome_transform.reads_to_library_params
$return is a genome_transform.object_id
reads_to_library_params is a reference to a hash where the following keys are defined:
	file_path_list has a value which is a reference to a list where each element is a string
	file_path has a value which is a string
	fwd_file has a value which is a string
	rev_file has a value which is a string
	wsname has a value which is a string
	wsid has a value which is an int
	name has a value which is a string
	objid has a value which is an int
	interleaved has a value which is an int
	insert_size_mean has a value which is a float
	insert_size_std_dev has a value which is a float
	read_orientation_outward has a value which is an int
	sequencing_tech has a value which is a string
	single_genome has a value which is an int
	strain has a value which is a KBaseCommon.StrainInfo
	source has a value which is a KBaseCommon.SourceInfo
StrainInfo is a reference to a hash where the following keys are defined:
	genetic_code has a value which is an int
	genus has a value which is a string
	species has a value which is a string
	strain has a value which is a string
	organelle has a value which is a string
	source has a value which is a KBaseCommon.SourceInfo
	ncbi_taxid has a value which is an int
	location has a value which is a KBaseCommon.Location
SourceInfo is a reference to a hash where the following keys are defined:
	source has a value which is a string
	source_id has a value which is a KBaseCommon.source_id
	project_id has a value which is a KBaseCommon.project_id
source_id is a string
project_id is a string
Location is a reference to a hash where the following keys are defined:
	lat has a value which is a float
	lon has a value which is a float
	elevation has a value which is a float
	date has a value which is a string
	description has a value which is a string
object_id is a string


=end text

=item Description



=back

=cut

 sub reads_to_library
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function reads_to_library (received $n, expecting 1)");
    }
    {
	my($reads_to_library_params) = @args;

	my @_bad_arguments;
        (ref($reads_to_library_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"reads_to_library_params\" (value was \"$reads_to_library_params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to reads_to_library:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'reads_to_library');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "genome_transform.reads_to_library",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'reads_to_library',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method reads_to_library",
					    status_line => $self->{client}->status_line,
					    method_name => 'reads_to_library',
				       );
    }
}
 


=head2 sra_reads_to_library

  $return = $obj->sra_reads_to_library($reads_to_library_params)

=over 4

=item Parameter and return types

=begin html

<pre>
$reads_to_library_params is a genome_transform.reads_to_library_params
$return is a genome_transform.object_id
reads_to_library_params is a reference to a hash where the following keys are defined:
	file_path_list has a value which is a reference to a list where each element is a string
	file_path has a value which is a string
	fwd_file has a value which is a string
	rev_file has a value which is a string
	wsname has a value which is a string
	wsid has a value which is an int
	name has a value which is a string
	objid has a value which is an int
	interleaved has a value which is an int
	insert_size_mean has a value which is a float
	insert_size_std_dev has a value which is a float
	read_orientation_outward has a value which is an int
	sequencing_tech has a value which is a string
	single_genome has a value which is an int
	strain has a value which is a KBaseCommon.StrainInfo
	source has a value which is a KBaseCommon.SourceInfo
StrainInfo is a reference to a hash where the following keys are defined:
	genetic_code has a value which is an int
	genus has a value which is a string
	species has a value which is a string
	strain has a value which is a string
	organelle has a value which is a string
	source has a value which is a KBaseCommon.SourceInfo
	ncbi_taxid has a value which is an int
	location has a value which is a KBaseCommon.Location
SourceInfo is a reference to a hash where the following keys are defined:
	source has a value which is a string
	source_id has a value which is a KBaseCommon.source_id
	project_id has a value which is a KBaseCommon.project_id
source_id is a string
project_id is a string
Location is a reference to a hash where the following keys are defined:
	lat has a value which is a float
	lon has a value which is a float
	elevation has a value which is a float
	date has a value which is a string
	description has a value which is a string
object_id is a string

</pre>

=end html

=begin text

$reads_to_library_params is a genome_transform.reads_to_library_params
$return is a genome_transform.object_id
reads_to_library_params is a reference to a hash where the following keys are defined:
	file_path_list has a value which is a reference to a list where each element is a string
	file_path has a value which is a string
	fwd_file has a value which is a string
	rev_file has a value which is a string
	wsname has a value which is a string
	wsid has a value which is an int
	name has a value which is a string
	objid has a value which is an int
	interleaved has a value which is an int
	insert_size_mean has a value which is a float
	insert_size_std_dev has a value which is a float
	read_orientation_outward has a value which is an int
	sequencing_tech has a value which is a string
	single_genome has a value which is an int
	strain has a value which is a KBaseCommon.StrainInfo
	source has a value which is a KBaseCommon.SourceInfo
StrainInfo is a reference to a hash where the following keys are defined:
	genetic_code has a value which is an int
	genus has a value which is a string
	species has a value which is a string
	strain has a value which is a string
	organelle has a value which is a string
	source has a value which is a KBaseCommon.SourceInfo
	ncbi_taxid has a value which is an int
	location has a value which is a KBaseCommon.Location
SourceInfo is a reference to a hash where the following keys are defined:
	source has a value which is a string
	source_id has a value which is a KBaseCommon.source_id
	project_id has a value which is a KBaseCommon.project_id
source_id is a string
project_id is a string
Location is a reference to a hash where the following keys are defined:
	lat has a value which is a float
	lon has a value which is a float
	elevation has a value which is a float
	date has a value which is a string
	description has a value which is a string
object_id is a string


=end text

=item Description



=back

=cut

 sub sra_reads_to_library
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function sra_reads_to_library (received $n, expecting 1)");
    }
    {
	my($reads_to_library_params) = @args;

	my @_bad_arguments;
        (ref($reads_to_library_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"reads_to_library_params\" (value was \"$reads_to_library_params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to sra_reads_to_library:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'sra_reads_to_library');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "genome_transform.sra_reads_to_library",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'sra_reads_to_library',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method sra_reads_to_library",
					    status_line => $self->{client}->status_line,
					    method_name => 'sra_reads_to_library',
				       );
    }
}
 
  
sub status
{
    my($self, @args) = @_;
    if ((my $n = @args) != 0) {
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
                                   "Invalid argument count for function status (received $n, expecting 0)");
    }
    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
        method => "genome_transform.status",
        params => \@args,
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
                           code => $result->content->{error}->{code},
                           method_name => 'status',
                           data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
                          );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method status",
                        status_line => $self->{client}->status_line,
                        method_name => 'status',
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
                method_name => 'sra_reads_to_library',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method sra_reads_to_library",
            status_line => $self->{client}->status_line,
            method_name => 'sra_reads_to_library',
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



=head2 sra

=over 4



=item Description

Ref of the resulting object

typedef string object_ref;
        /*
sequence type


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 domain

=over 4



=item Description

Rna Seq metadata


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



=head2 platform

=over 4



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



=head2 sample_id

=over 4



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



=head2 condition

=over 4



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



=head2 source

=over 4



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



=head2 Library_type

=over 4



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



=head2 publication_Id

=over 4



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



=head2 external_source_date

=over 4



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



=head2 sampleset_id

=over 4



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



=head2 sampleset_desc

=over 4



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
html_link has a value which is a genome_transform.object_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genbank_shock_ref has a value which is a genome_transform.shock_ref
genbank_file_path has a value which is a genome_transform.file_path
workspace has a value which is a genome_transform.workspace_id
genome_id has a value which is a genome_transform.object_id
html_link has a value which is a genome_transform.object_id


=end text

=back



=head2 narrativeGenbank_to_genome_params

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genbank_file_path has a value which is a genome_transform.file_path
workspace has a value which is a genome_transform.workspace_id
genome_id has a value which is a genome_transform.object_id
html_link has a value which is a genome_transform.object_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genbank_file_path has a value which is a genome_transform.file_path
workspace has a value which is a genome_transform.workspace_id
genome_id has a value which is a genome_transform.object_id
html_link has a value which is a genome_transform.object_id


=end text

=back



=head2 File

=over 4



=item Description

genome_name - becomes the name of the object
workspace_name - the name of the workspace it gets saved to.
source - Source of the file typically something like RefSeq or Ensembl
taxon_ws_name - where the reference taxons are : ReferenceTaxons
    taxon_reference - if defined, will try to link the Genome to the specified
taxonomy object insteas of performing the lookup during upload
release - Release or version number of the data
  per example Ensembl has numbered releases of all their data: Release 31
generate_ids_if_needed - If field used for feature id is not there,
  generate ids (default behavior is raising an exception)
genetic_code - Genetic code of organism. Overwrites determined GC from
  taxon object
type - Reference, Representative or User upload


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
path has a value which is a string
shock_id has a value which is a string
ftp_url has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
path has a value which is a string
shock_id has a value which is a string
ftp_url has a value which is a string


=end text

=back



=head2 usermeta

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the key is a string and the value is a string
</pre>

=end html

=begin text

a reference to a hash where the key is a string and the value is a string

=end text

=back



=head2 genomeFileUtilInput

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
file has a value which is a genome_transform.File
file_path has a value which is a string
genome_name has a value which is a string
workspace_name has a value which is a string
source has a value which is a string
taxon_wsname has a value which is a string
taxon_reference has a value which is a string
release has a value which is a string
generate_ids_if_needed has a value which is a string
genetic_code has a value which is an int
type has a value which is a string
metadata has a value which is a genome_transform.usermeta

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
file has a value which is a genome_transform.File
file_path has a value which is a string
genome_name has a value which is a string
workspace_name has a value which is a string
source has a value which is a string
taxon_wsname has a value which is a string
taxon_reference has a value which is a string
release has a value which is a string
generate_ids_if_needed has a value which is a string
genetic_code has a value which is an int
type has a value which is a string
metadata has a value which is a genome_transform.usermeta


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



=head2 rnaSeqMeta

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
domain has a value which is a string
platform has a value which is a string
sample_id has a value which is a string
condition has a value which is a string
source has a value which is a string
Library_type has a value which is a string
publication_Id has a value which is a string
external_source_date has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
domain has a value which is a string
platform has a value which is a string
sample_id has a value which is a string
condition has a value which is a string
source has a value which is a string
Library_type has a value which is a string
publication_Id has a value which is a string
external_source_date has a value which is a string


=end text

=back



=head2 reads_to_assembly_params

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
reads_shock_ref has a value which is a genome_transform.shock_ref
reads_handle_ref has a value which is a genome_transform.handle_ref
reads_type has a value which is a string
file_path_list has a value which is a reference to a list where each element is a string
rnaSeqMetaData has a value which is a reference to a hash where the key is a string and the value is a genome_transform.rnaSeqMeta
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
rnaSeqMetaData has a value which is a reference to a hash where the key is a string and the value is a genome_transform.rnaSeqMeta
workspace has a value which is a genome_transform.workspace_id
reads_id has a value which is a genome_transform.object_id
outward has a value which is a string
insert_size has a value which is a float
std_dev has a value which is a float


=end text

=back



=head2 rnaseq_sequence_params

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
reads_shock_ref has a value which is a genome_transform.shock_ref
reads_handle_ref has a value which is a genome_transform.handle_ref
reads_type has a value which is a string
file_path_list has a value which is a reference to a list where each element is a string
rnaSeqMetaData has a value which is a reference to a hash where the key is a string and the value is a genome_transform.rnaSeqMeta
workspace has a value which is a genome_transform.workspace_id
reads_id has a value which is a genome_transform.object_id
outward has a value which is a string
insert_size has a value which is a float
std_dev has a value which is a float
sra has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
reads_shock_ref has a value which is a genome_transform.shock_ref
reads_handle_ref has a value which is a genome_transform.handle_ref
reads_type has a value which is a string
file_path_list has a value which is a reference to a list where each element is a string
rnaSeqMetaData has a value which is a reference to a hash where the key is a string and the value is a genome_transform.rnaSeqMeta
workspace has a value which is a genome_transform.workspace_id
reads_id has a value which is a genome_transform.object_id
outward has a value which is a string
insert_size has a value which is a float
std_dev has a value which is a float
sra has a value which is an int


=end text

=back



=head2 rna_sample_set_params

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a genome_transform.workspace_id
domain has a value which is a string
sampleset_id has a value which is a string
sampleset_desc has a value which is a string
rnaSeqSample has a value which is a reference to a list where each element is a genome_transform.rnaseq_sequence_params

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a genome_transform.workspace_id
domain has a value which is a string
sampleset_id has a value which is a string
sampleset_desc has a value which is a string
rnaSeqSample has a value which is a reference to a list where each element is a genome_transform.rnaseq_sequence_params


=end text

=back



=head2 reads_to_library_params

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
file_path_list has a value which is a reference to a list where each element is a string
file_path has a value which is a string
fwd_file has a value which is a string
rev_file has a value which is a string
wsname has a value which is a string
wsid has a value which is an int
name has a value which is a string
objid has a value which is an int
interleaved has a value which is an int
insert_size_mean has a value which is a float
insert_size_std_dev has a value which is a float
read_orientation_outward has a value which is an int
sequencing_tech has a value which is a string
single_genome has a value which is an int
strain has a value which is a KBaseCommon.StrainInfo
source has a value which is a KBaseCommon.SourceInfo

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
file_path_list has a value which is a reference to a list where each element is a string
file_path has a value which is a string
fwd_file has a value which is a string
rev_file has a value which is a string
wsname has a value which is a string
wsid has a value which is an int
name has a value which is a string
objid has a value which is an int
interleaved has a value which is an int
insert_size_mean has a value which is a float
insert_size_std_dev has a value which is a float
read_orientation_outward has a value which is an int
sequencing_tech has a value which is a string
single_genome has a value which is an int
strain has a value which is a KBaseCommon.StrainInfo
source has a value which is a KBaseCommon.SourceInfo


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
