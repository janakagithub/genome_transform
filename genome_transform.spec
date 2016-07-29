/*
A KBase module: genome_transform
This sample module contains one small method - filter_contigs.
*/

module genome_transform {
/*
		URL to a shock node containing a data file for upload
	*/
	typedef string shock_ref;
	/*
		Path to a file containing a data file for upload on the local filesystem
	*/
	typedef string file_path;

	/*
		Type to a file containing a data file for upload on the local filesystem
	*/
	typedef string file_type;

	/*
		Name of an object in the KBase workspace
	*/
	typedef string object_id;

	/*
		Name of an report id
	*/
	typedef string report_id;

	/*
	    status of the reads pair point outward or not
	*/
	typedef string outward;


	/*
		Name of a KBase workspace
	*/
	typedef string workspace_id;


	/*
		Name of a KBase reads type
	*/
	typedef string reads_type;

	/*
		Name of a KBase reads_id
	*/
	typedef string reads_id;

	/*
		Name of a KBase file_path_list
	*/
	typedef string file_path_list;

    /*
		Name of a KBase handle ref
	*/
	typedef string handle_ref;

    /*
		Name of a standard deviation
	*/
	typedef float std_dev;

    /*
		Name of a insert size
	*/
	typedef float insert_size;




	/*
        Input parameters for the "genbank_to_genome" function.

		shock_ref genbank_shock_ref - optional URL to genbank file stored in Shock
		file_path genbank_file_path - optional path to genbank file on local file system
		workspace_id workspace - workspace where object will be saved
		object_id genome_id - workspace ID to which the genome object should be saved
		object_id contigset_id - workspace ID to which the contigs should be saved

	*/


	typedef structure {
		shock_ref genbank_shock_ref;
		file_path genbank_file_path;

		workspace_id workspace;
		object_id genome_id;
		object_id contigset_id;
   } genbank_to_genome_params;

   funcdef genbank_to_genome(genbank_to_genome_params) returns (object_id) authentication required;

   /*
        Input parameters for the "fasta_to_contig" function.

		shock_ref shock_ref - optional URL to fasta file stored in Shock
		file_path file_path - optional path to fasta file on local file system
		workspace_id workspace - workspace where object will be saved
		object_id genome_id - workspace ID to which the contigs object should be saved
		object_id contigset_id - workspace ID to which the contigs should be saved

	*/
	typedef structure {
		shock_ref fasta_shock_ref;
		file_path fasta_file_path;

		workspace_id workspace;
		object_id genome_id;
		object_id contigset_id;
   } fasta_to_contig_params;

   funcdef fasta_to_contig(fasta_to_contig_params) returns (object_id) authentication required;

   /*
        Input parameters for the "exp tsv to exp matirx" function.

		shock_ref shock_ref - optional URL to genbank file stored in Shock
		file_path file_path - optional path to genbank file on local file system
		workspace_id workspace - workspace where object will be saved
		object_id genome_id - workspace ID to which the genome object should be saved
		object_id contigset_id - workspace ID to which the contigs should be saved
   */

	typedef structure {
		shock_ref tsvexp_shock_ref;
		file_path tsvexp_file_path;

		workspace_id workspace;
		object_id genome_id;
		object_id expMaxId;
   }tsv_to_exp_params;

   funcdef tsv_to_exp(tsv_to_exp_params) returns (object_id) authentication required;



   /*
        Input parameters for the "reads to assembly" function.

        shock_ref shock_ref - optional URL to genbank file stored in Shock
        file_path file_path - optional path to genbank file on local file system
        workspace_id workspace - workspace where object will be saved
        object_id reads_id - workspace ID to which the genome object should be saved
        object_id contigset_id - workspace ID to which the contigs should be saved
   */

    typedef structure {
		shock_ref reads_shock_ref;
        handle_ref reads_handle_ref;
        string reads_type;
        list <string> file_path_list;
        workspace_id workspace;
        object_id reads_id;
        string outward;
        float insert_size;
        float std_dev;

   }reads_to_assembly_params;

   funcdef reads_to_assembly(reads_to_assembly_params) returns (object_id) authentication required;

   funcdef sra_reads_to_assembly(reads_to_assembly_params) returns (object_id) authentication required;

};
