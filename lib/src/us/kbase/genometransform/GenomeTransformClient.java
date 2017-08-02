package us.kbase.genometransform;

import com.fasterxml.jackson.core.type.TypeReference;
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import us.kbase.auth.AuthToken;
import us.kbase.common.service.JsonClientCaller;
import us.kbase.common.service.JsonClientException;
import us.kbase.common.service.RpcContext;
import us.kbase.common.service.UnauthorizedException;

/**
 * <p>Original spec-file module name: genome_transform</p>
 * <pre>
 * </pre>
 */
public class GenomeTransformClient {
    private JsonClientCaller caller;
    private String serviceVersion = null;


    /** Constructs a client with a custom URL and no user credentials.
     * @param url the URL of the service.
     */
    public GenomeTransformClient(URL url) {
        caller = new JsonClientCaller(url);
    }
    /** Constructs a client with a custom URL.
     * @param url the URL of the service.
     * @param token the user's authorization token.
     * @throws UnauthorizedException if the token is not valid.
     * @throws IOException if an IOException occurs when checking the token's
     * validity.
     */
    public GenomeTransformClient(URL url, AuthToken token) throws UnauthorizedException, IOException {
        caller = new JsonClientCaller(url, token);
    }

    /** Constructs a client with a custom URL.
     * @param url the URL of the service.
     * @param user the user name.
     * @param password the password for the user name.
     * @throws UnauthorizedException if the credentials are not valid.
     * @throws IOException if an IOException occurs when checking the user's
     * credentials.
     */
    public GenomeTransformClient(URL url, String user, String password) throws UnauthorizedException, IOException {
        caller = new JsonClientCaller(url, user, password);
    }

    /** Constructs a client with a custom URL
     * and a custom authorization service URL.
     * @param url the URL of the service.
     * @param user the user name.
     * @param password the password for the user name.
     * @param auth the URL of the authorization server.
     * @throws UnauthorizedException if the credentials are not valid.
     * @throws IOException if an IOException occurs when checking the user's
     * credentials.
     */
    public GenomeTransformClient(URL url, String user, String password, URL auth) throws UnauthorizedException, IOException {
        caller = new JsonClientCaller(url, user, password, auth);
    }

    /** Get the token this client uses to communicate with the server.
     * @return the authorization token.
     */
    public AuthToken getToken() {
        return caller.getToken();
    }

    /** Get the URL of the service with which this client communicates.
     * @return the service URL.
     */
    public URL getURL() {
        return caller.getURL();
    }

    /** Set the timeout between establishing a connection to a server and
     * receiving a response. A value of zero or null implies no timeout.
     * @param milliseconds the milliseconds to wait before timing out when
     * attempting to read from a server.
     */
    public void setConnectionReadTimeOut(Integer milliseconds) {
        this.caller.setConnectionReadTimeOut(milliseconds);
    }

    /** Check if this client allows insecure http (vs https) connections.
     * @return true if insecure connections are allowed.
     */
    public boolean isInsecureHttpConnectionAllowed() {
        return caller.isInsecureHttpConnectionAllowed();
    }

    /** Deprecated. Use isInsecureHttpConnectionAllowed().
     * @deprecated
     */
    public boolean isAuthAllowedForHttp() {
        return caller.isAuthAllowedForHttp();
    }

    /** Set whether insecure http (vs https) connections should be allowed by
     * this client.
     * @param allowed true to allow insecure connections. Default false
     */
    public void setIsInsecureHttpConnectionAllowed(boolean allowed) {
        caller.setInsecureHttpConnectionAllowed(allowed);
    }

    /** Deprecated. Use setIsInsecureHttpConnectionAllowed().
     * @deprecated
     */
    public void setAuthAllowedForHttp(boolean isAuthAllowedForHttp) {
        caller.setAuthAllowedForHttp(isAuthAllowedForHttp);
    }

    /** Set whether all SSL certificates, including self-signed certificates,
     * should be trusted.
     * @param trustAll true to trust all certificates. Default false.
     */
    public void setAllSSLCertificatesTrusted(final boolean trustAll) {
        caller.setAllSSLCertificatesTrusted(trustAll);
    }
    
    /** Check if this client trusts all SSL certificates, including
     * self-signed certificates.
     * @return true if all certificates are trusted.
     */
    public boolean isAllSSLCertificatesTrusted() {
        return caller.isAllSSLCertificatesTrusted();
    }
    /** Sets streaming mode on. In this case, the data will be streamed to
     * the server in chunks as it is read from disk rather than buffered in
     * memory. Many servers are not compatible with this feature.
     * @param streamRequest true to set streaming mode on, false otherwise.
     */
    public void setStreamingModeOn(boolean streamRequest) {
        caller.setStreamingModeOn(streamRequest);
    }

    /** Returns true if streaming mode is on.
     * @return true if streaming mode is on.
     */
    public boolean isStreamingModeOn() {
        return caller.isStreamingModeOn();
    }

    public void _setFileForNextRpcResponse(File f) {
        caller.setFileForNextRpcResponse(f);
    }

    public String getServiceVersion() {
        return this.serviceVersion;
    }

    public void setServiceVersion(String newValue) {
        this.serviceVersion = newValue;
    }

    /**
     * <p>Original spec-file function name: genbank_to_genome</p>
     * <pre>
     * </pre>
     * @param   arg1   instance of type {@link us.kbase.genometransform.GenbankToGenomeParams GenbankToGenomeParams} (original type "genbank_to_genome_params")
     * @return   instance of original type "object_id" (Name of an object in the KBase workspace)
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public String genbankToGenome(GenbankToGenomeParams arg1, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(arg1);
        TypeReference<List<String>> retType = new TypeReference<List<String>>() {};
        List<String> res = caller.jsonrpcCall("genome_transform.genbank_to_genome", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: narrative_genbank_to_genome</p>
     * <pre>
     * </pre>
     * @param   arg1   instance of type {@link us.kbase.genometransform.NarrativeGenbankToGenomeParams NarrativeGenbankToGenomeParams} (original type "narrativeGenbank_to_genome_params")
     * @return   instance of original type "object_id" (Name of an object in the KBase workspace)
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public String narrativeGenbankToGenome(NarrativeGenbankToGenomeParams arg1, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(arg1);
        TypeReference<List<String>> retType = new TypeReference<List<String>>() {};
        List<String> res = caller.jsonrpcCall("genome_transform.narrative_genbank_to_genome", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: genbank_to_genome_GFU</p>
     * <pre>
     * </pre>
     * @param   arg1   instance of type {@link us.kbase.genometransform.GenomeFileUtilInput GenomeFileUtilInput} (original type "genomeFileUtilInput")
     * @return   instance of original type "object_id" (Name of an object in the KBase workspace)
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public String genbankToGenomeGFU(GenomeFileUtilInput arg1, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(arg1);
        TypeReference<List<String>> retType = new TypeReference<List<String>>() {};
        List<String> res = caller.jsonrpcCall("genome_transform.genbank_to_genome_GFU", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: fasta_to_contig</p>
     * <pre>
     * </pre>
     * @param   arg1   instance of type {@link us.kbase.genometransform.FastaToContigParams FastaToContigParams} (original type "fasta_to_contig_params")
     * @return   instance of original type "object_id" (Name of an object in the KBase workspace)
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public String fastaToContig(FastaToContigParams arg1, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(arg1);
        TypeReference<List<String>> retType = new TypeReference<List<String>>() {};
        List<String> res = caller.jsonrpcCall("genome_transform.fasta_to_contig", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: tsv_to_exp</p>
     * <pre>
     * </pre>
     * @param   arg1   instance of type {@link us.kbase.genometransform.TsvToExpParams TsvToExpParams} (original type "tsv_to_exp_params")
     * @return   instance of original type "object_id" (Name of an object in the KBase workspace)
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public String tsvToExp(TsvToExpParams arg1, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(arg1);
        TypeReference<List<String>> retType = new TypeReference<List<String>>() {};
        List<String> res = caller.jsonrpcCall("genome_transform.tsv_to_exp", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: reads_to_assembly</p>
     * <pre>
     * </pre>
     * @param   arg1   instance of type {@link us.kbase.genometransform.ReadsToAssemblyParams ReadsToAssemblyParams} (original type "reads_to_assembly_params")
     * @return   instance of original type "object_id" (Name of an object in the KBase workspace)
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public String readsToAssembly(ReadsToAssemblyParams arg1, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(arg1);
        TypeReference<List<String>> retType = new TypeReference<List<String>>() {};
        List<String> res = caller.jsonrpcCall("genome_transform.reads_to_assembly", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: sra_reads_to_assembly</p>
     * <pre>
     * </pre>
     * @param   arg1   instance of type {@link us.kbase.genometransform.ReadsToAssemblyParams ReadsToAssemblyParams} (original type "reads_to_assembly_params")
     * @return   instance of original type "object_id" (Name of an object in the KBase workspace)
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public String sraReadsToAssembly(ReadsToAssemblyParams arg1, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(arg1);
        TypeReference<List<String>> retType = new TypeReference<List<String>>() {};
        List<String> res = caller.jsonrpcCall("genome_transform.sra_reads_to_assembly", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: rna_sample_set</p>
     * <pre>
     * </pre>
     * @param   arg1   instance of type {@link us.kbase.genometransform.RnaSampleSetParams RnaSampleSetParams} (original type "rna_sample_set_params")
     * @return   instance of original type "object_id" (Name of an object in the KBase workspace)
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public String rnaSampleSet(RnaSampleSetParams arg1, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(arg1);
        TypeReference<List<String>> retType = new TypeReference<List<String>>() {};
        List<String> res = caller.jsonrpcCall("genome_transform.rna_sample_set", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: reads_to_library</p>
     * <pre>
     * </pre>
     * @param   arg1   instance of type {@link us.kbase.genometransform.ReadsToLibraryParams ReadsToLibraryParams} (original type "reads_to_library_params")
     * @return   instance of original type "object_id" (Name of an object in the KBase workspace)
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public String readsToLibrary(ReadsToLibraryParams arg1, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(arg1);
        TypeReference<List<String>> retType = new TypeReference<List<String>>() {};
        List<String> res = caller.jsonrpcCall("genome_transform.reads_to_library", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    /**
     * <p>Original spec-file function name: sra_reads_to_library</p>
     * <pre>
     * </pre>
     * @param   arg1   instance of type {@link us.kbase.genometransform.ReadsToLibraryParams ReadsToLibraryParams} (original type "reads_to_library_params")
     * @return   instance of type {@link us.kbase.genometransform.SraReadsToLibraryOutput SraReadsToLibraryOutput} (original type "sraReadsToLibraryOutput")
     * @throws IOException if an IO exception occurs
     * @throws JsonClientException if a JSON RPC exception occurs
     */
    public SraReadsToLibraryOutput sraReadsToLibrary(ReadsToLibraryParams arg1, RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        args.add(arg1);
        TypeReference<List<SraReadsToLibraryOutput>> retType = new TypeReference<List<SraReadsToLibraryOutput>>() {};
        List<SraReadsToLibraryOutput> res = caller.jsonrpcCall("genome_transform.sra_reads_to_library", args, retType, true, true, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }

    public Map<String, Object> status(RpcContext... jsonRpcContext) throws IOException, JsonClientException {
        List<Object> args = new ArrayList<Object>();
        TypeReference<List<Map<String, Object>>> retType = new TypeReference<List<Map<String, Object>>>() {};
        List<Map<String, Object>> res = caller.jsonrpcCall("genome_transform.status", args, retType, true, false, jsonRpcContext, this.serviceVersion);
        return res.get(0);
    }
}
