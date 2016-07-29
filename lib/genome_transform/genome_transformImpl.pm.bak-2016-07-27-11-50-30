package genome_transform::genome_transformImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

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
use Data::Dumper;
use Test::More;
use Config::Simple;
use JSON;
use File::Path;
binmode STDOUT, ":utf8";
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

    $self->{'workspace-url'} = $wsInstance;

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
    print "check";
    my $relative_fp = "/data/bulktest/data/bulktest/".$file_path;

    print "complete-file-path  $file_path\n relative-file-path $relative_fp\n\n";
    my $tmpDir = "/kb/module/work/tmp";
    my $expDir = "/kb/module/work/tmp/Genomes";

    if (-d $expDir){

        print "temp/Genome directory exists, continuing..\n";
    }
    else{

        mkpath([$tmpDir], 1);
        mkpath([$expDir], 1);
        print "creating a temp/expDir direcotory for data processing, continuing..\n";
}

################################
system ("ls /data/");
system ("ls /data/bulktest/data/");
system ("ls /data/bulktest/data/bulktest/janakakbase/expmax/");
system ("ls /data/bulktest/data/bulktest/");
system ("ls /data/bulktest/data/bulktest/janakakbase/");
system ("ls /data/bulktest/data/bulktest/janakakbase/fasta/");

#system ("/kb/deployment/bin/trns_transform_Genbank_Genome_to_KBaseGenomes_Genome  --shock_service_url  https://ci.kbase.us/services/shock-api --workspace_service_url https://appdev.kbase.us/services/ws --workspace_name $workspace  --object_name $genome_id   --contigset_object_name  $contig_id --input_directory $file_path  --working_directory /kb/module/work/tmp/Genomes");
my $cmd = q{/kb/deployment/bin/trns_transform_Genbank_Genome_to_KBaseGenomes_Genome  --shock_service_url  https://ci.kbase.us/services/shock-api --workspace_service_url https://ci.kbase.us/services/ws --workspace_name $workspace  --object_name $genome_id   --contigset_object_name  $contig_id --input_directory $file_path  --working_directory /kb/module/work/tmp/Genomes};
system $cmd;
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
    print "complete-file-path  $file_path\n relative-file-path $relative_fp\n\n";


    if (-d $expDir){

        print "temp directory exists, continuing..\n";
    }
    else{

        mkpath([$tmpDir], 1);
        mkpath([$expDir], 1);
        print "creating a tmp/Genomes direcotory for data processing, continuing..\n";
}

    #$contig_id = $contig_id."";


################################
#system ('/kb/deployment/bin/trns_transform_Genbank_Genome_to_KBaseGenomes_Genome  --shock_service_url  https://ci.kbase.us/services/shock-api --workspace_service_url http://ci.kbase.us/services/ws --workspace_name  "janakakbase:1455821214132" --object_name NC_003197 --contigset_object_name  ContigNC_003197 --input_directory /kb/module/data/NC_003197.gbk --working_directory /kb/module/workdir/tmp/Genomes');
#system ('/kb/deployment/bin/trns_transform_Genbank_Genome_to_KBaseGenomes_Genome  --shock_service_url  https://ci.kbase.us/services/shock-api --workspace_service_url https://appdev.kbase.us/services/ws --workspace_name  "janakakbase:1464032798535" --object_name NC_003197 --contigset_object_name  ContigNC_003197 --input_directory /kb/module/data/NC_003197.gbk --working_directory /kb/module/workdir/tmp/Genomes');
system ("ls /data/");
system ("ls /data/bulktest/data/bulktest/");
system ("ls /data/bulktest/data/bulktest/janakakbase/");
system ("ls /data/bulktest/data/bulktest/janakakbase/fasta/");
my $cmd = q{/kb/deployment/bin/trns_transform_FASTA_DNA_Assembly_to_KBaseGenomes_ContigSet  --shock_service_url  https://ci.kbase.us/services/shock-api   --output_file_name $contig_id  --input_directory $file_path  --working_directory /kb/module/work/tmp/Genomes};
system $cmd;
#################################

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
    if ($@) {
        die "Error saving modified genome object to workspace:\n".$@;
    }

    #$return = {'file path input hash' => $genome_id};

    $return = $genome_id;


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

#my $expDirTest = "$expDir";
################################
#system ('/kb/deployment/bin/trns_transform_Genbank_Genome_to_KBaseGenomes_Genome  --shock_service_url  https://ci.kbase.us/services/shock-api --workspace_service_url http://ci.kbase.us/services/ws --workspace_name  "janakakbase:1455821214132" --object_name NC_003197 --contigset_object_name  ContigNC_003197 --input_directory /kb/module/data/NC_003197.gbk --working_directory /kb/module/workdir/tmp/Genomes');
#system ('/kb/deployment/bin/trns_transform_Genbank_Genome_to_KBaseGenomes_Genome  --shock_service_url  https://ci.kbase.us/services/shock-api --workspace_service_url https://appdev.kbase.us/services/ws --workspace_name  "janakakbase:1464032798535" --object_name NC_003197 --contigset_object_name  ContigNC_003197 --input_directory /kb/module/data/NC_003197.gbk --working_directory /kb/module/workdir/tmp/Genomes');
system ("ls /data/");
system ("ls /data/bulktest/data/bulktest/");
system ("ls /data/bulktest/data/bulktest/janakakbase/");
system ("ls /data/bulktest/data/bulktest/janakakbase/fasta/");

#my $cmd = q{/kb/deployment/bin/trns_transform_TSV_Exspression_to_KBaseFeatureValues_ExpressionMatrix  --workspace_service_url https://ci.kbase.us/services/ws  --workspace_name $workspace  --object_name $genome_id   --output_file_name  $exp_id --input_directory $file_path  --working_directory $expDirTest};
system ("/kb/deployment/bin/trns_transform_TSV_Exspression_to_KBaseFeatureValues_ExpressionMatrix  --workspace_service_url https://ci.kbase.us/services/ws  --workspace_name $workspace  --object_name $genome_id   --output_file_name  $exp_id --input_directory $file_path  --working_directory  $expDir ");

#system $cmd;
#################################

die;
my $json;

{
  local $/; #Enable 'slurp' mode
  open my $fh, "<", "/kb/module/work/tmp/Genomes/$exp_id";
  $json = <$fh>;
  close $fh;
}

my $exp_ob = decode_json($json);
    #print &Dumper ($exp_ob);

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
	file_path_list has a value which is a string
	workspace has a value which is a genome_transform.workspace_id
	reads_id has a value which is a genome_transform.object_id
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
	file_path_list has a value which is a string
	workspace has a value which is a genome_transform.workspace_id
	reads_id has a value which is a genome_transform.object_id
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
    print &Dumper ($reads_to_assembly_params);

    print "\n\nstarting reads to assembly method.....\n\n\n";
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

    my $filep1 = "/kb/module/data/frag_1.fastq";
    my $filep2 = "/kb/module/data/frag_2.fastq";

system ("ls /data/bulktest/data/bulktest/");
system ("ls /data/bulktest/data/bulktest/janakakbase/");
system ("ls /data/bulktest/data/bulktest/janakakbase/reads/");
system ("ls /data/bulktest/data/bulktest/janakakbase/fasta/");
system ("ls /kb/module/data/");

    my @cmd = ("/kb/deployment/bin/trns_transform_seqs_to_KBaseAssembly_type", "-t", $reads_type, "-f",$file_path->[0], "-f", $file_path->[1], "-o","/kb/module/work/tmp/Genomes/pereads.json", "--shock_service_url","http://ci.kbase.us/services/shock-api", "--handle_service_url","https://ci.kbase.us/services/handle_service", "--outward",0 );
    #my @cmd = ("/kb/deployment/bin/trns_transform_seqs_to_KBaseAssembly_type", "-t", $reads_type, "-f","/data/bulktest/data/bulktest/janakakbase/reads/frag_1.fastq", "-f","/data/bulktest/data/bulktest/janakakbase/reads/frag_2.fastq", "-o","/kb/module/work/tmp/Genomes/pereads.json", "--shock_service_url","http://ci.kbase.us/services/shock-api", "--handle_service_url","https://ci.kbase.us/services/handle_service");
    my $rc = system(@cmd);
    
    my $json;
    {
        local $/; #Enable 'slurp' mode
        open my $fh, "<", "/kb/module/work/tmp/Genomes/pereads.json";
        #open my $fh, "<", "/kb/module/data/pereads.json";
        $json = <$fh>;
        close $fh;
    }

    my $ro = decode_json($json); 
    print &Dumper ($ro);

    print "\n\n saving the object into the workspace\n";

    my $obj_info_list = undef;
        eval {
            $obj_info_list = $wsClient->save_objects({
                'id'=>7995,
                'objects'=>[{
                'type'=>'KBaseAssembly.PairedEndLibrary',
                'data'=>$ro,
                'name'=>$reads_id,
                'provenance'=>$provenance
                }]
            });
        };
    if ($@) {
        die "Error saving modified genome object to workspace:\n".$@;
    }

    $return = $reads_id;
    print &Dumper ($obj_info_list);

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




=head2 version 

  $return = $obj->version()

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

Return the module version. This is a Semantic Versioning number.

=back

=cut

sub version {
    return $VERSION;
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
file_path_list has a value which is a string
workspace has a value which is a genome_transform.workspace_id
reads_id has a value which is a genome_transform.object_id
insert_size has a value which is a float
std_dev has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
reads_shock_ref has a value which is a genome_transform.shock_ref
reads_handle_ref has a value which is a genome_transform.handle_ref
reads_type has a value which is a string
file_path_list has a value which is a string
workspace has a value which is a genome_transform.workspace_id
reads_id has a value which is a genome_transform.object_id
insert_size has a value which is a float
std_dev has a value which is a float


=end text

=back



=cut

1;
