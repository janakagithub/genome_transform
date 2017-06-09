

function genome_transform(url, auth, auth_cb, timeout, async_job_check_time_ms, service_version) {
    var self = this;

    this.url = url;
    var _url = url;

    this.timeout = timeout;
    var _timeout = timeout;
    
    this.async_job_check_time_ms = async_job_check_time_ms;
    if (!this.async_job_check_time_ms)
        this.async_job_check_time_ms = 100;
    this.async_job_check_time_scale_percent = 150;
    this.async_job_check_max_time_ms = 300000;  // 5 minutes
    this.service_version = service_version;

    var _auth = auth ? auth : { 'token' : '', 'user_id' : ''};
    var _auth_cb = auth_cb;

     this.genbank_to_genome = function (genbank_to_genome_params, _callback, _errorCallback) {
        if (typeof genbank_to_genome_params === 'function')
            throw 'Argument genbank_to_genome_params can not be a function';
        if (_callback && typeof _callback !== 'function')
            throw 'Argument _callback must be a function if defined';
        if (_errorCallback && typeof _errorCallback !== 'function')
            throw 'Argument _errorCallback must be a function if defined';
        if (typeof arguments === 'function' && arguments.length > 1+2)
            throw 'Too many arguments ('+arguments.length+' instead of '+(1+2)+')';
        return json_call_ajax(_url, "genome_transform.genbank_to_genome",
            [genbank_to_genome_params], 1, _callback, _errorCallback);
    };
 
     this.narrative_genbank_to_genome = function (narrativeGenbank_to_genome_params, _callback, _errorCallback) {
        if (typeof narrativeGenbank_to_genome_params === 'function')
            throw 'Argument narrativeGenbank_to_genome_params can not be a function';
        if (_callback && typeof _callback !== 'function')
            throw 'Argument _callback must be a function if defined';
        if (_errorCallback && typeof _errorCallback !== 'function')
            throw 'Argument _errorCallback must be a function if defined';
        if (typeof arguments === 'function' && arguments.length > 1+2)
            throw 'Too many arguments ('+arguments.length+' instead of '+(1+2)+')';
        return json_call_ajax(_url, "genome_transform.narrative_genbank_to_genome",
            [narrativeGenbank_to_genome_params], 1, _callback, _errorCallback);
    };
 
     this.genbank_to_genome_GFU = function (genomeFileUtilInput, _callback, _errorCallback) {
        if (typeof genomeFileUtilInput === 'function')
            throw 'Argument genomeFileUtilInput can not be a function';
        if (_callback && typeof _callback !== 'function')
            throw 'Argument _callback must be a function if defined';
        if (_errorCallback && typeof _errorCallback !== 'function')
            throw 'Argument _errorCallback must be a function if defined';
        if (typeof arguments === 'function' && arguments.length > 1+2)
            throw 'Too many arguments ('+arguments.length+' instead of '+(1+2)+')';
        return json_call_ajax(_url, "genome_transform.genbank_to_genome_GFU",
            [genomeFileUtilInput], 1, _callback, _errorCallback);
    };
 
     this.fasta_to_contig = function (fasta_to_contig_params, _callback, _errorCallback) {
        if (typeof fasta_to_contig_params === 'function')
            throw 'Argument fasta_to_contig_params can not be a function';
        if (_callback && typeof _callback !== 'function')
            throw 'Argument _callback must be a function if defined';
        if (_errorCallback && typeof _errorCallback !== 'function')
            throw 'Argument _errorCallback must be a function if defined';
        if (typeof arguments === 'function' && arguments.length > 1+2)
            throw 'Too many arguments ('+arguments.length+' instead of '+(1+2)+')';
        return json_call_ajax(_url, "genome_transform.fasta_to_contig",
            [fasta_to_contig_params], 1, _callback, _errorCallback);
    };
 
     this.tsv_to_exp = function (tsv_to_exp_params, _callback, _errorCallback) {
        if (typeof tsv_to_exp_params === 'function')
            throw 'Argument tsv_to_exp_params can not be a function';
        if (_callback && typeof _callback !== 'function')
            throw 'Argument _callback must be a function if defined';
        if (_errorCallback && typeof _errorCallback !== 'function')
            throw 'Argument _errorCallback must be a function if defined';
        if (typeof arguments === 'function' && arguments.length > 1+2)
            throw 'Too many arguments ('+arguments.length+' instead of '+(1+2)+')';
        return json_call_ajax(_url, "genome_transform.tsv_to_exp",
            [tsv_to_exp_params], 1, _callback, _errorCallback);
    };
 
     this.reads_to_assembly = function (reads_to_assembly_params, _callback, _errorCallback) {
        if (typeof reads_to_assembly_params === 'function')
            throw 'Argument reads_to_assembly_params can not be a function';
        if (_callback && typeof _callback !== 'function')
            throw 'Argument _callback must be a function if defined';
        if (_errorCallback && typeof _errorCallback !== 'function')
            throw 'Argument _errorCallback must be a function if defined';
        if (typeof arguments === 'function' && arguments.length > 1+2)
            throw 'Too many arguments ('+arguments.length+' instead of '+(1+2)+')';
        return json_call_ajax(_url, "genome_transform.reads_to_assembly",
            [reads_to_assembly_params], 1, _callback, _errorCallback);
    };
 
     this.sra_reads_to_assembly = function (reads_to_assembly_params, _callback, _errorCallback) {
        if (typeof reads_to_assembly_params === 'function')
            throw 'Argument reads_to_assembly_params can not be a function';
        if (_callback && typeof _callback !== 'function')
            throw 'Argument _callback must be a function if defined';
        if (_errorCallback && typeof _errorCallback !== 'function')
            throw 'Argument _errorCallback must be a function if defined';
        if (typeof arguments === 'function' && arguments.length > 1+2)
            throw 'Too many arguments ('+arguments.length+' instead of '+(1+2)+')';
        return json_call_ajax(_url, "genome_transform.sra_reads_to_assembly",
            [reads_to_assembly_params], 1, _callback, _errorCallback);
    };
 
     this.rna_sample_set = function (rna_sample_set_params, _callback, _errorCallback) {
        if (typeof rna_sample_set_params === 'function')
            throw 'Argument rna_sample_set_params can not be a function';
        if (_callback && typeof _callback !== 'function')
            throw 'Argument _callback must be a function if defined';
        if (_errorCallback && typeof _errorCallback !== 'function')
            throw 'Argument _errorCallback must be a function if defined';
        if (typeof arguments === 'function' && arguments.length > 1+2)
            throw 'Too many arguments ('+arguments.length+' instead of '+(1+2)+')';
        return json_call_ajax(_url, "genome_transform.rna_sample_set",
            [rna_sample_set_params], 1, _callback, _errorCallback);
    };
 
     this.reads_to_library = function (reads_to_library_params, _callback, _errorCallback) {
        if (typeof reads_to_library_params === 'function')
            throw 'Argument reads_to_library_params can not be a function';
        if (_callback && typeof _callback !== 'function')
            throw 'Argument _callback must be a function if defined';
        if (_errorCallback && typeof _errorCallback !== 'function')
            throw 'Argument _errorCallback must be a function if defined';
        if (typeof arguments === 'function' && arguments.length > 1+2)
            throw 'Too many arguments ('+arguments.length+' instead of '+(1+2)+')';
        return json_call_ajax(_url, "genome_transform.reads_to_library",
            [reads_to_library_params], 1, _callback, _errorCallback);
    };
 
     this.sra_reads_to_library = function (reads_to_library_params, _callback, _errorCallback) {
        if (typeof reads_to_library_params === 'function')
            throw 'Argument reads_to_library_params can not be a function';
        if (_callback && typeof _callback !== 'function')
            throw 'Argument _callback must be a function if defined';
        if (_errorCallback && typeof _errorCallback !== 'function')
            throw 'Argument _errorCallback must be a function if defined';
        if (typeof arguments === 'function' && arguments.length > 1+2)
            throw 'Too many arguments ('+arguments.length+' instead of '+(1+2)+')';
        return json_call_ajax(_url, "genome_transform.sra_reads_to_library",
            [reads_to_library_params], 1, _callback, _errorCallback);
    };
  
    this.status = function (_callback, _errorCallback) {
        if (_callback && typeof _callback !== 'function')
            throw 'Argument _callback must be a function if defined';
        if (_errorCallback && typeof _errorCallback !== 'function')
            throw 'Argument _errorCallback must be a function if defined';
        if (typeof arguments === 'function' && arguments.length > 2)
            throw 'Too many arguments ('+arguments.length+' instead of 2)';
        return json_call_ajax(_url, "genome_transform.status",
            [], 1, _callback, _errorCallback);
    };


    /*
     * JSON call using jQuery method.
     */
    function json_call_ajax(srv_url, method, params, numRets, callback, errorCallback, json_rpc_context, deferred) {
        if (!deferred)
            deferred = $.Deferred();

        if (typeof callback === 'function') {
           deferred.done(callback);
        }

        if (typeof errorCallback === 'function') {
           deferred.fail(errorCallback);
        }

        var rpc = {
            params : params,
            method : method,
            version: "1.1",
            id: String(Math.random()).slice(2),
        };
        if (json_rpc_context)
            rpc['context'] = json_rpc_context;

        var beforeSend = null;
        var token = (_auth_cb && typeof _auth_cb === 'function') ? _auth_cb()
            : (_auth.token ? _auth.token : null);
        if (token != null) {
            beforeSend = function (xhr) {
                xhr.setRequestHeader("Authorization", token);
            }
        }

        var xhr = jQuery.ajax({
            url: srv_url,
            dataType: "text",
            type: 'POST',
            processData: false,
            data: JSON.stringify(rpc),
            beforeSend: beforeSend,
            timeout: _timeout,
            success: function (data, status, xhr) {
                var result;
                try {
                    var resp = JSON.parse(data);
                    result = (numRets === 1 ? resp.result[0] : resp.result);
                } catch (err) {
                    deferred.reject({
                        status: 503,
                        error: err,
                        url: srv_url,
                        resp: data
                    });
                    return;
                }
                deferred.resolve(result);
            },
            error: function (xhr, textStatus, errorThrown) {
                var error;
                if (xhr.responseText) {
                    try {
                        var resp = JSON.parse(xhr.responseText);
                        error = resp.error;
                    } catch (err) { // Not JSON
                        error = "Unknown error - " + xhr.responseText;
                    }
                } else {
                    error = "Unknown Error";
                }
                deferred.reject({
                    status: 500,
                    error: error
                });
            }
        });

        var promise = deferred.promise();
        promise.xhr = xhr;
        return promise;
    }
}


 