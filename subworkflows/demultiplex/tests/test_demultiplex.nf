//
// Testing for subworkflow: create_meta.nf
//

include { DEMULTIPLEX } from '../demultiplex.nf'

workflow {
    DEMULTIPLEX (params.runinfo, params.runparams, params.samplesheet, params.run_dir, params.casava_dir)
}