
package us.kbase.genometransform;

import java.util.HashMap;
import java.util.Map;
import javax.annotation.Generated;
import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;


/**
 * <p>Original spec-file type: genbank_to_genome_params</p>
 * <pre>
 * Input parameters for the "genbank_to_genome" function.
 *         shock_ref genbank_shock_ref - optional URL to genbank file stored in Shock
 *         file_path genbank_file_path - optional path to genbank file on local file system
 *         workspace_id workspace - workspace where object will be saved
 *         object_id genome_id - workspace ID to which the genome object should be saved
 *         object_id contigset_id - workspace ID to which the contigs should be saved
 * </pre>
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "genbank_shock_ref",
    "genbank_file_path",
    "workspace",
    "genome_id",
    "html_link"
})
public class GenbankToGenomeParams {

    @JsonProperty("genbank_shock_ref")
    private String genbankShockRef;
    @JsonProperty("genbank_file_path")
    private String genbankFilePath;
    @JsonProperty("workspace")
    private String workspace;
    @JsonProperty("genome_id")
    private String genomeId;
    @JsonProperty("html_link")
    private String htmlLink;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("genbank_shock_ref")
    public String getGenbankShockRef() {
        return genbankShockRef;
    }

    @JsonProperty("genbank_shock_ref")
    public void setGenbankShockRef(String genbankShockRef) {
        this.genbankShockRef = genbankShockRef;
    }

    public GenbankToGenomeParams withGenbankShockRef(String genbankShockRef) {
        this.genbankShockRef = genbankShockRef;
        return this;
    }

    @JsonProperty("genbank_file_path")
    public String getGenbankFilePath() {
        return genbankFilePath;
    }

    @JsonProperty("genbank_file_path")
    public void setGenbankFilePath(String genbankFilePath) {
        this.genbankFilePath = genbankFilePath;
    }

    public GenbankToGenomeParams withGenbankFilePath(String genbankFilePath) {
        this.genbankFilePath = genbankFilePath;
        return this;
    }

    @JsonProperty("workspace")
    public String getWorkspace() {
        return workspace;
    }

    @JsonProperty("workspace")
    public void setWorkspace(String workspace) {
        this.workspace = workspace;
    }

    public GenbankToGenomeParams withWorkspace(String workspace) {
        this.workspace = workspace;
        return this;
    }

    @JsonProperty("genome_id")
    public String getGenomeId() {
        return genomeId;
    }

    @JsonProperty("genome_id")
    public void setGenomeId(String genomeId) {
        this.genomeId = genomeId;
    }

    public GenbankToGenomeParams withGenomeId(String genomeId) {
        this.genomeId = genomeId;
        return this;
    }

    @JsonProperty("html_link")
    public String getHtmlLink() {
        return htmlLink;
    }

    @JsonProperty("html_link")
    public void setHtmlLink(String htmlLink) {
        this.htmlLink = htmlLink;
    }

    public GenbankToGenomeParams withHtmlLink(String htmlLink) {
        this.htmlLink = htmlLink;
        return this;
    }

    @JsonAnyGetter
    public Map<String, Object> getAdditionalProperties() {
        return this.additionalProperties;
    }

    @JsonAnySetter
    public void setAdditionalProperties(String name, Object value) {
        this.additionalProperties.put(name, value);
    }

    @Override
    public String toString() {
        return ((((((((((((("GenbankToGenomeParams"+" [genbankShockRef=")+ genbankShockRef)+", genbankFilePath=")+ genbankFilePath)+", workspace=")+ workspace)+", genomeId=")+ genomeId)+", htmlLink=")+ htmlLink)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
