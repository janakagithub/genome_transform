package genome_transform::genome_transformImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org
our $VERSION = '0.0.1';
our $GIT_URL = 'https://github.com/kbaseapps/genome_transform';
our $GIT_COMMIT_HASH = '4cac77ae725e05b5c120a8520ea00cdd98c74029';

=head1 NAME

genome_transform

=head1 DESCRIPTION

A KBase module: genome_transform
This sample module contains one small method - filter_contigs.

=cut

#BEGIN_HEADER
use Bio::KBase::AuthToken;
use Bio::KBase::workspace::Client;
use Config::IniFiles;
use Cwd;
use Data::Dumper;
use Test::More;
use Config::Simple;
use JSON;
use File::Basename;
use File::Compare qw( compare );
use File::Copy::Recursive qw( dircopy );
use File::MMagic;      # needs to be added to container via Dockerfile
                       # required by decompress_if_needed()
use File::Path;
use HTTP::Request;     # these two used for direct shock url from
use LWP::UserAgent;    # 302 redirect

binmode STDOUT, ":utf8";

# accepts either a single file or a directory of files to be potentially
# decompressed.   In either case, returns the path of the resultant file
# or directory to be uploaded (which will be the original path if no decompression
# is necessary)
sub  decompress_if_needed
   {
    my $inpath = shift;

    if ( -f $inpath )
       {  return( decompress_file_if_needed( $inpath ) );  }
    elsif ( -d $inpath )
       {  return( decompress_directory_contents_as_needed( $inpath ) ); }
    else
       {  die "decompress_if_needed: \"$inpath\" is neither regular file nor directory\n"; }
   }

# this is needed because some of the transform repo plugin scripts used here
# (such as trns_transform_Genbank_Genome_to_KBaseGenomes_Genome.py)
# accept a directory of input files, whereas others accept regular file
# (such as trns_transform_seqs_to_KBaseAssembly_type)
# so this code needs to decompress in either situation.  In the case of input directories
# its necessary to descend into the directory and handle each file therein.
# However, because the source directory may reside in a
# read-only partition, its necessary to duplicate the directory as a subdirectory in the
# jobs working area to allow the decompression to work.

sub  decompress_directory_contents_as_needed
   {
    my $srcpath = shift;
    my $destpath;

    if ( basename( $srcpath ) eq $srcpath )
       { $destpath = $srcpath }
    else
       {
        $destpath = basename( $srcpath );
        dircopy( $srcpath, $destpath );
       }
    my $save_cwd = getcwd();

    # right now this assumes the input directory is only 1 level deep containing
    # the actually files.

    chdir( $destpath );
    foreach my $file ( glob( "*" ) )
       { decompress_file_if_needed( $file ) if ( -f $file ); }    # hmm maybe we could do a recursive
                                                                  # call to decompress_if_needed()?
    chdir( $save_cwd );
    return( $destpath );
   }

#
# $uncompressed_filename = decompress_file_if_needed( $input_filename )
# this handles a single file. determines if the input file is a gzip or bzip2 compressed file,
# and if so, invokes the appropriate decompress program (gunzip or bunzip2)
# and returns the decompressed filename (minus the suffix) -
# -- also any initial directory path is removed.  The newly uncompressed
# file is created and left in the awe job working directory, and that filename
# is returned.
#
# If the file is not identified as a compressed file, no action is taken
# and the original filename is returned
#
sub  decompress_file_if_needed
   {
    my $infilename = shift;

    my @gzip_suffs = ('.gz', '.gzip' );
    my @bzip_suffs = ('.bz2', '.bzip2', '.bz', '.bzip' );

    # make the decision based on the mime magic type
    my $mm = new File::MMagic;
    my $mimetype = $mm->checktype_filename( $infilename );
    print "file $infilename mimetype is [$mimetype]\n";

    if ( $mimetype eq 'application/x-gzip' || $mimetype eq 'application/gzip' )
       {
        print "using gunzip\n";
        my ($outfilename, $suff) = uncompressed_name( $infilename, @gzip_suffs );
        system_and_check( "gunzip -S suff -c $infilename > $outfilename" );  # construct forced filename
        die_if_unsupported( $outfilename);
        return( $outfilename );                                 # because gunzip strips suffix
       }
    elsif ( $mimetype eq 'application/x-bzip2' )
       {
        print "using bunzip2\n";
        my ($outfilename, $suff) = uncompressed_name( $infilename, @bzip_suffs );
        system_and_check( "bunzip2 -c $infilename  > $outfilename" );
        die_if_unsupported( $outfilename );
        return( $outfilename );
       }
    else
       {
        die_if_unsupported( $infilename );
        print "no action - return original filename\n";
        # possible further checks here?  ie what if file has .gz extension but
        # was not identified as such with MMagic?
        return( $infilename );
       }
   }

# create a new name for the uncompressed file, which will be in
# the working directory

sub  uncompressed_name
   {
    my ( $infilename, @exts ) = @_;

    my ( $outfilename, $dirs, $suffix ) = fileparse( $infilename, @exts );
    $outfilename .= "_uncompressed" if ( compare( $outfilename, $infilename ) == 0 );  # ensure its different from original
    return( ($outfilename, $suffix) );
   }


# this examines the mimetype of the input file and dies with an error
# message if its our our list of aggregated file types (tar, zip etc)
sub  die_if_unsupported
   {
    my $filename = shift;
    my @unsp_list = ( 'application/gtar',
                      'application/x-gtar',
                      'application/stuffit',
                      'application/x-stuffit',
                      'application/stuffitx',
                      'application/x-stuffitx',
                      'application/tar',
                      'application/x-tar',
                      'application/zip',
                      'application/x-zip'
                   );
    my $mm = new File::MMagic;

    my $type = $mm->checktype_filename( $filename );
    print "checking if \"$filename\", of \"$type\" is unsupported\n";
    #print "spec [", join( ",", grep( $type eq $_, @unsp_list ) ), "]\n";
    my @spec = grep( $type eq $_, @unsp_list );
    #print "spec [", join( ",", @spec ), "]\n";
    if ( @spec  )
       {
        $spec[0] =~ s=^application/(x-)?==;
        print STDERR "Error: $filename is of type $spec[0] which is not supported by KBase bulk upload.\n" ;
        die "We're sorry, but $filename is of type $spec[0] which is not supported by KBase bulk upload.\n" ;
       }

   }
#
# These are two routines used by sra_reads_to_assembly() and decompress_if_needed()
#

# system_and_check( $cmd)
#    issue system( $cmd ) then check for error return

sub  system_and_check
   {
    my $cmd = shift;
    print "system_and_check [$cmd]\n";
    if ( system( $cmd ) != 0 )
       {
        if ( $? == -1 )
           {  die "system() cmd failed to execute: $!\n";  }
        elsif ( $? & 127 )
           {  printf STDERR "system() cmd died with signal %d, %s coredump\n",
                   ($? & 127), ($? & 128 ) ? "with" : "without";
           }
        else
           {  printf STDERR "system() cmd exited with value %d\n", $? >> 8;  }
        die "$0 terminating\n";
       }
    #print "### looks like successful return\n";
   }


# convert_sra( $filename, $type)
#    $filename is SRA filename (string)
#    (may have different path, but output will be in current working directory)
#    $type is 'SingleEndLibrary' or 'PairedEndLibrary'
# runs SRA conversion, converted files (fastq) will be left
# in working directory, returns converted file name(s)
#  - with .fastq extention, in a list

my $sra_convert_program = "/kb/deployment/bin/fastq-dump";

sub  convert_sra
   {
    my ( $file, $type ) = @_;

    my $fileroot = $file;
    $fileroot =~ s/.sra$//;  # remove any .sra extension

    if ( $type eq 'SingleEndLibrary' )
       {
        my $outfile = basename( $fileroot ) . ".fastq";
        system_and_check( "$sra_convert_program $file" );
        if ( -e $outfile )
           { return( ( $outfile ) ); }
        else
           { # maybe try a few other tricks here before bailing
             die "did not file expected $outfile from $sra_convert_program\n";
           }
       }
    elsif ( $type eq 'PairedEndLibrary' )
       {
        my @outfiles = map( basename( $fileroot ). "_" . $_ . ".fastq", (1,2) );
        system_and_check( "$sra_convert_program --split-files $file" );
        if ( -e $outfiles[0] && -e $outfiles[1] )
           { return( @outfiles ); }
        else
           { # maybe try a few other tricks here before bailing
             die "did not file expected @outfiles from $sra_convert_program\n";
           }
       }
    else
       { die "$0: convert_sra() did not get correct type:  '$type' should be either 'SingleEndLibrary' or 'PairedEndLibrary'.\n";}
   }

# $shock_url = determine_relevant_shock_url() is invoked by various methods below to determine
# URL for fastq uploads to shock based on the runtime environment.   We want to use the direct
# http: url to the shock server because the nginx proxy won't handle extremely large files,
# but the direct URL won't work for docker container testing.   This examines the
# redirect provided by Dan Olson and Shane Conan and returns the value
#

sub  determine_relevant_shock_url
   {
    my $self = shift;
    my $shock_url = $self->{'shock-url'};

    # Is far as I know, the shock-direct link is not in the configuration.
    # So, we start with the shock URL from the configuration, ie "https://ci.kbase.us/services/shock-api"
    # and reform the shock-direct link from that into "https://ci.kbase.us/services/shock-direct"

    my $shock_direct = $shock_url;                 # create shock-direct url based on
    $shock_direct =~ s/shock-api/shock-direct/;    # current shock url
    my $ua = LWP::UserAgent->new;
    my $req = HTTP::Request->new( GET=>$shock_direct );
    my $res = $ua->request( $req );
    if ( $res->is_success && $res->previous )
       {
        print $req->url, ' redirected to ', $res->request->uri, "\n";
        $shock_url = $res->request->uri;
       }
    else
       { print $req->url, ": not redirected\n"; }

    print "relevant shock URL is [$shock_url]\n";

    return( $shock_url );
   }

sub curl_genome {
    my ($file_link) = @_ ;
    my $cmd   = 'curl --connect-timeout 100 -si ';
    $cmd     .= $file_link;
    my ($head, $body)  = split( m{\r?\n\r?\n}, `$cmd`) or die "Connection timed out retreving Genome:\n";
    my ($code) = $head =~m{\A\S+ (\d+)};
    #$code == 200 or die "Error retreving data from nodejs service: Return code $code \n".$body."\n";
    #my $json  = decode_json($head);
    return $head;
}

#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR

    my $config_file = $ENV{ KB_DEPLOYMENT_CONFIG };
    my $cfg = Config::IniFiles->new(-file=>$config_file);
    my $wsInstance = $cfg->val('genome_transform','workspace-url');
    die "no workspace-url defined" unless $wsInstance;
    my $ShockInstance = $cfg->val('genome_transform','shock-url');
    die "no shock-url defined" unless $ShockInstance;
    my $HandleInstance = $cfg->val('genome_transform','handle-service-url');
    die "no handle-service-url defined" unless $HandleInstance;

    $self->{'workspace-url'} = $wsInstance;
    $self->{'shock-url'} = $ShockInstance;
    $self->{'handle-service-url'} = $HandleInstance;

    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



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
    my $self = shift;
    my($genbank_to_genome_params) = @_;

    my @_bad_arguments;
    (ref($genbank_to_genome_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"genbank_to_genome_params\" (value was \"$genbank_to_genome_params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to genbank_to_genome:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'genbank_to_genome');
    }

    my $ctx = $genome_transform::genome_transformServer::CallContext;
    my($return);
    #BEGIN genbank_to_genome

    print $genbank_to_genome_params->{genbank_file_path};
    print &Dumper ($genbank_to_genome_params);
    my $file_path = $genbank_to_genome_params->{genbank_file_path};
    my $workspace = $genbank_to_genome_params->{workspace};
    my $genome_id = $genbank_to_genome_params->{genome_id};
    my $contig_id = $genbank_to_genome_params->{contigset_id};

        $genome_id = $genome_id."";

    print "file-path  $file_path\n\n";
    my $tmpDir = "/kb/module/work/tmp";
    my $expDir = "/kb/module/work/tmp/Genomes";

    if (-d $expDir){
        print "temp/Genome directory exists, continuing..\n";
    }
    else{
        mkpath([$tmpDir], 1);
        mkpath([$expDir], 1);
        print "creating a temp/Genomes direcotory for data processing, continuing..\n";
    }

    $file_path = decompress_if_needed( $file_path );
    ################################

    #my @cmd = ("/kb/deployment/bin/trns_transform_seqs_to_KBaseAssembly_type", "-t", $reads_type, "-f","/data/bulktest/data/bulktest/janakakbase/reads/frag_1.fastq", "-f","/data/bulktest/data/bulktest/janakakbase/reads/frag_2.fastq", "-o","/kb/module/work/tmp/Genomes/pereads.json", "--shock_service_url","http://ci.kbase.us/services/shock-api", "--handle_service_url","https://ci.kbase.us/services/handle_service");
    my @cmd = ("/kb/deployment/bin/trns_transform_Genbank_Genome_to_KBaseGenomes_Genome",
               "--shock_service_url", determine_relevant_shock_url($self),
               "--workspace_service_url", $self->{'workspace-url'},
               "--workspace_name", $workspace,
               "--object_name", $genome_id,
               "--contigset_object_name", $contig_id,
               "--input_directory",$file_path,
               "--working_directory", "/kb/module/work/tmp/Genomes");
    my $rc = system_and_check( join( " ", @cmd ) );
    #system ("/kb/deployment/bin/trns_transform_Genbank_Genome_to_KBaseGenomes_Genome  --shock_service_url  https://ci.kbase.us/services/shock-api --workspace_service_url https://appdev.kbase.us/services/ws --workspace_name $workspace  --object_name $genome_id   --contigset_object_name  $contig_id --input_directory $file_path  --working_directory /kb/module/work/tmp/Genomes");
    #my $cmd = q{/kb/deployment/bin/trns_transform_Genbank_Genome_to_KBaseGenomes_Genome  --shock_service_url  https://ci.kbase.us/services/shock-api --workspace_service_url https://ci.kbase.us/services/ws --workspace_name $workspace  --object_name $genome_id   --contigset_object_name  $contig_id --input_directory $file_path  --working_directory /kb/module/work/tmp/Genomes};
    #system $cmd;
    #################################

    #$return = {'file path input hash' => $genome_id};
    $return = $genome_id;

    #END genbank_to_genome
    my @_bad_returns;
    (!ref($return)) or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to genbank_to_genome:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'genbank_to_genome');
    }
    return($return);
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
    my $self = shift;
    my($narrativeGenbank_to_genome_params) = @_;

    my @_bad_arguments;
    (ref($narrativeGenbank_to_genome_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"narrativeGenbank_to_genome_params\" (value was \"$narrativeGenbank_to_genome_params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to narrative_genbank_to_genome:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'narrative_genbank_to_genome');
    }

    my $ctx = $genome_transform::genome_transformServer::CallContext;
    my($return);
    #BEGIN narrative_genbank_to_genome
    print &Dumper ($narrativeGenbank_to_genome_params);

    my $file_path = "/data/bulk/".$ctx->{user_id}."/".$narrativeGenbank_to_genome_params->{genbank_file_path};
    my $workspace = $narrativeGenbank_to_genome_params->{workspace};
    my $genome_id = $narrativeGenbank_to_genome_params->{genome_id};
    my $html_link = $narrativeGenbank_to_genome_params->{html_link};
    my $contig_id = $genome_id."_Contig";

    $genome_id = $genome_id."";
    #print "file-path  $file_path\n\n";
    my $tmpDir = "/kb/module/work/tmp";
    my $expDir = "/kb/module/work/tmp/Genomes";
    my $genomeDir = "/kb/module/work/tmp/GenomesDir";

    if (-d $expDir){
        print "temp/Genome directory exists, continuing..\n";
    }
    else{
        mkpath([$tmpDir], 1);
        mkpath([$expDir], 1);
        mkpath([$genomeDir], 1);
        print "creating a temp/Genomes direcotory for data processing, continuing..\n";
    }

    if ($narrativeGenbank_to_genome_params->{genbank_file_path} eq 'ftp_url' && defined ($narrativeGenbank_to_genome_params->{html_link})){
      my $genome_out = curl_genome($html_link);
      open OUTFILE, ">".$genomeDir."/".$genome_id.".gbk" or die "Couldn't write the expression file : $!";
      print OUTFILE $genome_out;
      $file_path = $genomeDir.'/'.$genome_id.'.gbk';
    }
    elsif ($narrativeGenbank_to_genome_params->{genbank_file_path} eq 'ftp_url' && !defined ($narrativeGenbank_to_genome_params->{html_link})){
      die "FTP URL is not defined, terminating..\n";
    }
    else{
      print "continuing using genome file $narrativeGenbank_to_genome_params->{genbank_file_path}\n";
    }

    $file_path = decompress_if_needed($file_path);
    ################################
    my @cmd = ("/kb/deployment/bin/trns_transform_Genbank_Genome_to_KBaseGenomes_Genome",
               "--shock_service_url", determine_relevant_shock_url($self),
               "--workspace_service_url", $self->{'workspace-url'},
               "--workspace_name", $workspace,
               "--object_name", $genome_id,
               "--contigset_object_name", $contig_id,
               "--input_directory",$file_path,
               "--working_directory", "/kb/module/work/tmp/Genomes");
    my $rc = system_and_check( join( " ", @cmd ) );
    #################################
    #$return = {'file path input hash' => $genome_id};
    $return = $genome_id;

    #END narrative_genbank_to_genome
    my @_bad_returns;
    (!ref($return)) or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	   my $msg = "Invalid returns passed to narrative_genbank_to_genome:\n" . join("", map { "\t$_\n" } @_bad_returns);
	   Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'narrative_genbank_to_genome');
    }
    return($return);
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
    my $self = shift;
    my($fasta_to_contig_params) = @_;

    my @_bad_arguments;
    (ref($fasta_to_contig_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"fasta_to_contig_params\" (value was \"$fasta_to_contig_params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to fasta_to_contig:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'fasta_to_contig');
    }

    my $ctx = $genome_transform::genome_transformServer::CallContext;
    my($return);
    #BEGIN fasta_to_contig
    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    my $wsClient=Bio::KBase::workspace::Client->new($self->{'workspace-url'},token=>$token);

    my $file_path = $fasta_to_contig_params->{fasta_file_path};
    my $workspace = $fasta_to_contig_params->{workspace};
    my $genome_id = $fasta_to_contig_params->{genome_id};
    my $contig_id = $fasta_to_contig_params->{contigset_id};
    print &Dumper ($fasta_to_contig_params);
    my $tmpDir = "/kb/module/work/tmp";
    my $expDir = "/kb/module/work/tmp/Genomes";

    my $relative_fp = "/data/bulktest/data/bulktest/".$file_path;
    #print "complete-file-path  $file_path\n relative-file-path $relative_fp\n\n";

    if (-d $expDir){
        print "temp directory exists, continuing..\n";
    }
    else{

        mkpath([$tmpDir], 1);
        mkpath([$expDir], 1);
        print "creating a tmp/Genomes direcotory for data processing, continuing..\n";
}

    $file_path = decompress_if_needed( $file_path );
    my $cmd = "/kb/deployment/bin/trns_transform_FASTA_DNA_Assembly_to_KBaseGenomes_ContigSet  --shock_service_url  " . determine_relevant_shock_url($self) . " --output_file_name $contig_id  --input_directory $file_path  --working_directory /kb/module/work/tmp/Genomes";
    print "cmd is ", Dumper( $cmd );
    system_and_check( $cmd );

    my $json;
    {
      local $/; #Enable 'slurp' mode
      open my $fh, "<", "/kb/module/work/tmp/Genomes/$contig_id";
      $json = <$fh>;
      close $fh;
    }
    #print &Dumper ($json);
    #die;

    my $contig_set = decode_json($json);
    eval {  $contig_set = decode_json($json);  };
    if ( $@ )
       { print STDERR "decode_json failed: $@\njson is ", Dumper( $json );  }
    else
       {
        my $obj_info_list = undef;
        eval {
              $obj_info_list = $wsClient->save_objects({
                 'workspace'=>$workspace,
                 'objects'=>[{
                              'type'=>'KBaseGenomes.ContigSet',
                              'data'=>$contig_set,
                              'name'=>$genome_id,
                              'provenance'=>$provenance
                            }]
               });
             };
        if ( $@ )
           {  die "Error saving modified genome object to workspace:\n".$@;  }

        #$return = {'file path input hash' => $genome_id};
        $return = $genome_id;
       }

    #END fasta_to_contig
    my @_bad_returns;
    (!ref($return)) or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to fasta_to_contig:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'fasta_to_contig');
    }
    return($return);
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
    my $self = shift;
    my($tsv_to_exp_params) = @_;

    my @_bad_arguments;
    (ref($tsv_to_exp_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"tsv_to_exp_params\" (value was \"$tsv_to_exp_params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to tsv_to_exp:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'tsv_to_exp');
    }

    my $ctx = $genome_transform::genome_transformServer::CallContext;
    my($return);
    #BEGIN tsv_to_exp
    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    my $wsClient=Bio::KBase::workspace::Client->new($self->{'workspace-url'},token=>$token);

    my $file_path = $tsv_to_exp_params->{tsvexp_file_path};
    my $workspace = $tsv_to_exp_params->{workspace};
    my $genome_id = $tsv_to_exp_params->{genome_id};
    my $exp_id = $tsv_to_exp_params->{expMaxId};
    print &Dumper ($tsv_to_exp_params);
    my $tmpDir = "/kb/module/work/tmp";
    my $expDir = "/kb/module/work/tmp/GenomesData";

############################### check for shock exe

my $insert_size = 300+0;
my $std = 60+0;
#system ("/kb/deployment/bin/trns_transform_seqs_to_KBaseAssembly_type -t PairedEndLibrary  -f /kb/module/data/frag_1.fastq -f /kb/module/data/frag_2.fastq  -o /kb/module/work/tmp/GenomesData/pereads.json --shock_service_url http://ci.kbase.us/services/shock-api --handle_service_url https://ci.kbase.us/services/handle_service");
#system ("cat /kb/module/work/tmp/GenomesData/pe.reads.json");
#########################################################

    if($expDir =~ m/\s+/g)#check for space
         {
          $expDir =~ s/\s+/\\ /g;#replace space by slash
         }
    my $relative_fp = "/data/bulktest/data/bulktest/".$file_path;
    print "complete-file-path  $file_path\n relative-file-path $relative_fp\n\n";

    if (-d $expDir){
        print "temp/Genomes directory exists, continuing..\n";
    }
    else{
        mkpath([$tmpDir], 1);
        mkpath([$expDir], 1);
        print "creating a temp/Genomes direcotory for data processing, continuing..\n";
    }

    $file_path = decompress_if_needed( $file_path );

    #my $expDirTest = "$expDir";
    ################################
    #system ('/kb/deployment/bin/trns_transform_Genbank_Genome_to_KBaseGenomes_Genome  --shock_service_url  https://ci.kbase.us/services/shock-api --workspace_service_url http://ci.kbase.us/services/ws --workspace_name  "janakakbase:1455821214132" --object_name NC_003197 --contigset_object_name  ContigNC_003197 --input_directory /kb/module/data/NC_003197.gbk --working_directory /kb/module/workdir/tmp/Genomes');
    #system ('/kb/deployment/bin/trns_transform_Genbank_Genome_to_KBaseGenomes_Genome  --shock_service_url  https://ci.kbase.us/services/shock-api --workspace_service_url https://appdev.kbase.us/services/ws --workspace_name  "janakakbase:1464032798535" --object_name NC_003197 --contigset_object_name  ContigNC_003197 --input_directory /kb/module/data/NC_003197.gbk --working_directory /kb/module/workdir/tmp/Genomes');
    #system ("ls /data/bulktest/");
    #my $cmd = q{/kb/deployment/bin/trns_transform_TSV_Exspression_to_KBaseFeatureValues_ExpressionMatrix  --workspace_service_url https://ci.kbase.us/services/ws  --workspace_name $workspace  --object_name $genome_id   --output_file_name  $exp_id --input_directory $file_path  --working_directory $expDirTest};
    system_and_check("/kb/deployment/bin/trns_transform_TSV_Exspression_to_KBaseFeatureValues_ExpressionMatrix  --workspace_service_url https://ci.kbase.us/services/ws  --workspace_name $workspace  --object_name $genome_id   --output_file_name  $exp_id --input_directory $file_path  --working_directory  $expDir ");
    #system $cmd;
    #################################

    my $json;
    {
      local $/; #Enable 'slurp' mode
      open my $fh, "<", "/kb/module/work/tmp/Genomes/$exp_id";
      $json = <$fh>;
      close $fh;
    }

    my $exp_ob;

    eval { $exp_ob = decode_json( $json ); };
    if ( $@ )
       {  print STDERR "decode_json failed: $@\njson is ", Dumper( $json );  }
    else
       {
        print "decode_json succeed:", Dumper ($exp_ob);

        print "\n\n saving the object into the workspace\n";

        my $obj_info_list = undef;
        eval {
            $obj_info_list = $wsClient->save_objects({
                'workspace'=>$workspace,
                'objects'=>[{
                'type'=>'KBaseFeatureValues.ExpressionMatrix',
                'data'=>$exp_ob,
                'name'=>$genome_id,
                'provenance'=>$provenance
                }]
            });
        };
        if ($@) {
            die "Error saving modified genome object to workspace:\n".$@;
           }
         print &Dumper ($obj_info_list);
       }
    return $exp_id;
    #END tsv_to_exp
    my @_bad_returns;
    (!ref($return)) or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to tsv_to_exp:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'tsv_to_exp');
    }
    return($return);
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
    my $self = shift;
    my($reads_to_assembly_params) = @_;

    my @_bad_arguments;
    (ref($reads_to_assembly_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"reads_to_assembly_params\" (value was \"$reads_to_assembly_params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to reads_to_assembly:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'reads_to_assembly');
    }

    my $ctx = $genome_transform::genome_transformServer::CallContext;
    my($return);
    #BEGIN reads_to_assembly

    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    my $wsClient=Bio::KBase::workspace::Client->new($self->{'workspace-url'},token=>$token);

    my $file_path = $reads_to_assembly_params->{file_path_list};
    my $workspace = $reads_to_assembly_params->{workspace};
    my $reads_id = $reads_to_assembly_params->{reads_id};
    my $reads_type = $reads_to_assembly_params->{reads_type};
    my $std = $reads_to_assembly_params->{std_dev};
    my $is = $reads_to_assembly_params->{insert_size};
    my $RNASeqSampleSetMeta = $reads_to_assembly_params->{rnaSeqMetaData};

    print &Dumper ($reads_to_assembly_params);

    print "\n\nstarting reads to assembly method.....\n\n";
    my $tmpDir = "/kb/module/work/tmp";
    my $expDir = "/kb/module/work/tmp/Genomes";

    if (-d $expDir){

        print "temp/Genomes directory exists, continuing..\n";
    }
    else{

        mkpath([$tmpDir], 1);
        mkpath([$expDir], 1);
        print "creating a temp/Genomes direcotory for data processing, continuing..\n";
    }

    #For debug purposes
    #my $filep1 = "/kb/module/data/frag_1.fastq";
    #my $filep2 = "/kb/module/data/frag_2.fastq";

    # decompress any gz or bzip2 files - capture new names of files in
    # the process
    foreach my $i ( 0..$#{$file_path} )
        { $file_path->[$i] = decompress_if_needed( $file_path->[$i] ); }

    my @cmd = ("/kb/deployment/bin/trns_transform_seqs_to_KBaseAssembly_type",
               "-t", $reads_type,
               "-f",$file_path->[0],
               "-o","/kb/module/work/tmp/Genomes/pereads.json",
               "--shock_service_url", determine_relevant_shock_url($self),
               "--handle_service_url", $self->{'handle-service-url'},
               "--outward",0 );

    push( @cmd, "-f", $file_path->[1], ) if ( @$file_path == 2 );
    my $rc = system_and_check( join( " ", @cmd ) );

    my $handle_type;
    if ( $reads_type eq 'SingleEndLibrary' ){
       $handle_type = 'KBaseAssembly.SingleEndLibrary';
    }
    elsif ( $reads_type eq 'PairedEndLibrary' ){
       $handle_type = 'KBaseAssembly.PairedEndLibrary';
    }
    else{

        print "KBase reads type is missing, resubmit with the correct type";
        die;
    }
    print "finished the assembly scripts, now writing to output file\n";
    my $json;
    {
        local $/; #Enable 'slurp' mode
        open my $fh, "<", "/kb/module/work/tmp/Genomes/pereads.json";
        $json = <$fh>;
        close $fh;
    }
    my $ro;

    eval { $ro = decode_json( $json ); };
    if ( $@ )
       {  print STDERR "decode_json failed: $@\njson is ", Dumper( $json );  }
    else
       {
        print "decode_json succeed:", Dumper ($ro);

        print "\n\n saving the object into the workspace\n";

        my $obj_info_list = undef;
        eval {
            $obj_info_list = $wsClient->save_objects({
                'workspace'=>$workspace,
                'objects'=>[{
                'type'=> $handle_type,
                'data'=>$ro,
                'name'=>$reads_id,
                'provenance'=>$provenance,
                'meta'=>$RNASeqSampleSetMeta
                }]
            });
          };
        if ($@) {
           die "Error saving modified genome object to workspace:\n".$@;
        }

        my $robj=$wsClient->get_objects([{workspace=>$workspace, name=>$reads_id}])->[0];

        $return = $obj_info_list->[0]->[6]."/".$obj_info_list->[0]->[0]."/".$obj_info_list->[0]->[4];
       }
    #print &Dumper ($robj);

    #END reads_to_assembly
    my @_bad_returns;
    (!ref($return)) or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to reads_to_assembly:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'reads_to_assembly');
    }
    return($return);
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
    my $self = shift;
    my($reads_to_assembly_params) = @_;

    my @_bad_arguments;
    (ref($reads_to_assembly_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"reads_to_assembly_params\" (value was \"$reads_to_assembly_params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to sra_reads_to_assembly:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'sra_reads_to_assembly');
    }

    my $ctx = $genome_transform::genome_transformServer::CallContext;
    my($return);
    #BEGIN sra_reads_to_assembly

    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    #print "in sra_reads_to_assembly()\n";
    #print "workspace is ", $self->{'workspace-url'}, "\ntoken is ", $token, "\n";
    my $wsClient=Bio::KBase::workspace::Client->new($self->{'workspace-url'},token=>$token);

    my $file_path = $reads_to_assembly_params->{file_path_list};
    my $workspace = $reads_to_assembly_params->{workspace};
    my $reads_id = $reads_to_assembly_params->{reads_id};
    my $reads_type = $reads_to_assembly_params->{reads_type};
    my $std = $reads_to_assembly_params->{std_dev};
    my $is = $reads_to_assembly_params->{insert_size};
    print &Dumper ($reads_to_assembly_params);

    print "\n\nstarting SRA reads to assembly method.....\n\n";
    my $tmpDir = "/kb/module/work/tmp";
    my $expDir = "/kb/module/work/tmp/Genomes";

    if (-d $expDir)
       {   print "temp/Genomes directory exists, continuing..\n";  }
    else
       {
        mkpath([$tmpDir], 1);
        mkpath([$expDir], 1);
        print "creating a temp/Genomes direcotory for data processing, continuing..\n";
       }

    chdir( $tmpDir ) || die "Can't chdir to $tmpDir: $!\n";

    $file_path->[0] = decompress_if_needed( $file_path->[0] );

    my @fq_files = convert_sra( $file_path->[0], $reads_type );   # convert
    print "after convert_sra( ", $file_path->[0], ", ", $reads_type, "), result fq_files are ", join( ",", @fq_files), "\n";
    #system( "ls");

    # there may be one or two fastq files resultant from the SRA conversion, depending on
    # whether or not this is a single or paired end library.  Construct the transform script
    # command line with one file, and append 2nd file argument if it exists

    my @cmd = ("/kb/deployment/bin/trns_transform_seqs_to_KBaseAssembly_type", "-t", $reads_type,
                "-o","/kb/module/work/tmp/Genomes/pereads.json",
                "--shock_service_url", determine_relevant_shock_url($self),
                "--handle_service_url", $self->{'handle-service-url'},
                "--outward", 0,
                "-f", $fq_files[0]
                );
    push( @cmd, "-f", $fq_files[1], ) if ( @fq_files == 2 );
    #print "transform command is ", join( " ", @cmd ), "\n";

    # run the transform script (same as with reads_to_assembly() )

    my $rc = system_and_check( join( " ", @cmd ) );

    my $json;
    {
        local $/; #Enable 'slurp' mode
        open my $fh, "<", "/kb/module/work/tmp/Genomes/pereads.json";
        #open my $fh, "<", "/kb/module/data/pereads.json";
        $json = <$fh>;
        close $fh;
        #print "json is\n$json\n";
    }

    my $ro;

    eval { $ro = decode_json( $json ); };
    if ( $@ )
       {  print STDERR "decode_json failed: $@\njson is ", Dumper( $json );  }
    else
       {
        print "decode_json succeed:", Dumper ($ro);

        my $handle_type = 'KBaseAssembly.PairedEndLibrary';
        if ( $reads_type eq 'SingleEndLibrary' )
           {  $handle_type = 'KBaseAssembly.SingleEndLibrary'; }

        print "\n\n saving the object, handle type [$handle_type], into the workspace\n";

        my $obj_info_list = undef;
        eval {
            $obj_info_list = $wsClient->save_objects({
                'workspace'=>$workspace,
                'objects'=>[{
                'type'=>$handle_type,
                'data'=>$ro,
                'name'=>$reads_id,
                'provenance'=>$provenance
                }]
            });
        };
        if ($@) {
            #print "Error saving modified genome object to workspace:\n", $@;
            die "Error saving modified genome object to workspace:\n".$@;
        }

        $return = $reads_id;
        #print &Dumper ($obj_info_list);
      }
    print "\n\nending SRA reads to assembly method.....\n\n";

    #END sra_reads_to_assembly
    my @_bad_returns;
    (!ref($return)) or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to sra_reads_to_assembly:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'sra_reads_to_assembly');
    }
    return($return);
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
    my $self = shift;
    my($rna_sample_set_params) = @_;

    my @_bad_arguments;
    (ref($rna_sample_set_params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"rna_sample_set_params\" (value was \"$rna_sample_set_params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to rna_sample_set:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'rna_sample_set');
    }

    my $ctx = $genome_transform::genome_transformServer::CallContext;
    my($return);
    #BEGIN rna_sample_set
    my $implr = new genome_transform::genome_transformImpl();
    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    my $wsClient=Bio::KBase::workspace::Client->new($self->{'workspace-url'},token=>$token);

    print "starting creating a RNA sample set....\n";

    my @sample_refs;
    my @sample_conditions;
    my $num_samples=0;
    my $num_replicates=0;

    print &Dumper ($rna_sample_set_params);

    foreach my $r (@{$rna_sample_set_params->{rnaSeqMeta}}){

      print "now uploading $r->{reads_id} \n";

      if ($r->{sra} == 0){


          my $reads_upload_status = $implr->reads_to_assembly($r);

          if (defined $reads_upload_status){

            print "Reads id $r->{reads_id} referenced $reads_upload_status sucessfully uploaded... continuing\n";
            push (@sample_refs, $r->{reads_id});
            push (@sample_conditions, $r->{rnaSeqSample}->{rnaSeqMetaData}->{condition});
            $num_samples++;
            $num_replicates++;
          }
           else{

            print "Reads id $r->{reads_id} did not upload properly into the narrative and will not be included in the RnaSeq Sample Set\n";
            next;
          }
      }
      elsif ($r->{sra} == 1){
          my $reads_upload_status = $implr->sra_reads_to_assembly($r);

          if (defined $reads_upload_status){

            print "Reads id $r->{reads_id} referenced $reads_upload_status sucessfully uploaded... continuing\n";
            push (@sample_refs, $r->{reads_id});
            push (@sample_conditions, $r->{rnaSeqSample}->{rnaSeqMetaData}->{condition});
            $num_samples++;
            $num_replicates++;
          }
           else{
            print "Reads id $r->{reads_id} did not upload properly into the narrative and will not be included in the RnaSeq Sample Set\n";
            next;
          }
      }
      else{
        print "reads classification (sra or none-sra) not given, moving to next read set..\n";
        next;
      }
    }

    print "$num_samples reads samples uploaded \n";

    $num_samples = $num_samples + 0;
    my $rnaSeqSet = {

        domain => $rna_sample_set_params->{sampleset_id},
        Library_type => 'PairedEnd/SingleEnd',
        sampleset_id => $rna_sample_set_params->{sampleset_id},
        num_samples => $num_samples,
        sample_ids => \@sample_refs,
        condition => \@sample_conditions,
        publication_id => '',
        source => 'prokaryote',
        sampleset_desc => $rna_sample_set_params->{sampleset_desc},
        platform => 'illumina'

      };

      print "\n saving the Rna-Seq sampleSet to the narrative - $rna_sample_set_params->{workspace}\n ";
      my $obj_info_list = undef;
        eval {
            $obj_info_list = $wsClient->save_objects({
                'workspace'=>$rna_sample_set_params->{workspace},
                'objects'=>[{
                'type'=>'KBaseRNASeq.RNASeqSampleSet',
                'data'=>$rnaSeqSet,
                'name'=>$rna_sample_set_params->{sampleset_id},
                'provenance'=>$provenance

                }]
            });
        };
    if ($@) {
        die "Error saving modified genome object to workspace:\n".$@;
    }

     print "\n\nfinishing the method uploading reads sets and creating a RnaSeq sample set $obj_info_list->[0]->[1]\n\n";
     print &Dumper ($obj_info_list);

    $return = $rnaSeqSet->{sampleset_id};
    #END rna_sample_set
    my @_bad_returns;
    (!ref($return)) or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to rna_sample_set:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'rna_sample_set');
    }
    return($return);
}




=head2 status

  $return = $obj->status()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module status. This is a structure including Semantic Versioning number, state and git info.

=back

=cut

sub status {
    my($return);
    #BEGIN_STATUS
    $return = {"state" => "OK", "message" => "", "version" => $VERSION,
               "git_url" => $GIT_URL, "git_commit_hash" => $GIT_COMMIT_HASH};
    #END_STATUS
    return($return);
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



=cut

1;
